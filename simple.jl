using Agents, Random
using StaticArrays: SVector
using LinearAlgebra  # La importo por el error de `norm`, no borrar

# Define al coche como mutable struct
mutable struct Car
    id::Int
    pos::SVector{2, Float64}
    vel::SVector{2, Float64}
    accelerating::Bool
end

# Define el semáforo como mutable struct
mutable struct TrafficLight
    state::Symbol  # verde, amarillo o rojo
    timer::Int     # tiempo en cada estado
end

# Define el modelo de tráfico
struct TrafficModel
    agents::Vector{Car}   
    space::ContinuousSpace{2, true, Float64, typeof(Agents.no_vel_update)}
    traffic_lights::Tuple{TrafficLight, TrafficLight}
end

# Ciclo de los semáforos
function cycle_lights!(horizontal_light::TrafficLight, vertical_light::TrafficLight)
    if horizontal_light.state == :green && horizontal_light.timer >= 120
        horizontal_light.state = :yellow
        vertical_light.state = :red  # Asegura que el vertical esté en rojo
        horizontal_light.timer = 0
    elseif horizontal_light.state == :yellow && horizontal_light.timer >= 20
        horizontal_light.state = :red
        vertical_light.state = :green  # Cambia el vertical a verde
        horizontal_light.timer = 0
    elseif horizontal_light.state == :red && horizontal_light.timer >= 120
        horizontal_light.state = :green
        vertical_light.state = :red
        horizontal_light.timer = 0
    else
        horizontal_light.timer += 1
        vertical_light.timer += 1
    end
end

# Inicializa los semáforos
function initialize_traffic_lights()
    light_horizontal = TrafficLight(:green, 0)  # Semáforo horizontal empieza en verde
    light_vertical = TrafficLight(:red, 0)      # Semáforo vertical empieza en rojo
    return light_horizontal, light_vertical
end

# Funciones para acelerar y frenar
accelerate(agent::Car) = agent.vel[1] + 0.05
decelerate(agent::Car) = agent.vel[1] - 0.1

# Detecta si hay un coche adelante
function car_ahead(agent::Car, model::TrafficModel)
    for neighbor in model.agents
        if neighbor.pos[1] > agent.pos[1] && norm(neighbor.pos - agent.pos) < 1.0
            return neighbor
        end
    end
    return nothing
end

# Actualiza el comportamiento del agente (coche)
function agent_step!(agent::Car, model::TrafficModel)
    axis = agent.axis
    
    # Detecta si hay un coche o semáforo adelante
    car_ahead_detected = car_ahead(agent, model)
    light_ahead_detected = light_ahead(agent, model)
    
    new_velocity = agent.vel[axis]
    
    if !isnothing(car_ahead_detected)
        new_velocity = decelerate(agent, axis)
    elseif !isnothing(light_ahead_detected)
        # Si el semáforo está en amarillo o rojo, frenar
        if light_ahead_detected.state in [:yellow, :red]
            new_velocity = decelerate(agent, axis)
        else
            new_velocity = accelerate(agent, axis)
        end
    else
        new_velocity = accelerate(agent, axis)
    end
    
    # Limitar velocidad
    new_velocity = clamp(new_velocity, 0.0, 0.4)

    # Actualiza la posición del coche según el eje
    if axis == 1
        agent.vel = SVector(new_velocity, 0.0)
    else
        agent.vel = SVector(0.0, new_velocity)
    end

    # Mueve el coche
    move_agent!(agent, model)
end

# Función para hacer que las posiciones de los coches se "envuelvan" en el espacio
function wrap_position!(pos::SVector{2, Float64}, space::ContinuousSpace{2, true, Float64, typeof(Agents.no_vel_update)})
    xmin, xmax = 0.0, space.extent[1]
    ymin, ymax = 0.0, space.extent[2]

    new_x = if pos[1] > xmax
        pos[1] - xmax
    elseif pos[1] < xmin
        pos[1] + xmax
    else
        pos[1]
    end

    new_y = if pos[2] > ymax
        pos[2] - ymax
    elseif pos[2] < ymin
        pos[2] + ymax
    else
        pos[2]
    end

    return SVector(new_x, new_y)
end

# Mueve al agente (coche)
function move_agent!(agent::Car, model::TrafficModel)
    new_pos = agent.pos + agent.vel * 0.4  # Aplica la velocidad para actualizar la posición

    agent.pos = wrap_position!(new_pos, model.space)
end

# Inicializa el modelo con agentes (coches) y semáforos
function initialize_model(extent = (40, 40))
    space2d = ContinuousSpace(extent; spacing = 1.5, periodic = true)
    rng = Random.MersenneTwister()

    light_horizontal, light_vertical = initialize_traffic_lights()

    agents = Vector{Car}()
    for i in 1:5
        pos = SVector(rand(Uniform(0.0, 25.0)), 0.0)  # Coches empezando en posiciones aleatorias
        vel = SVector(rand(Uniform(0.2, 1.0)), 0.0)
        accelerating = true
        push!(agents, Car(i, pos, vel, accelerating))
    end

    return TrafficModel(agents, space2d, (light_horizontal, light_vertical))
end

# Realiza un paso de la simulación
function simulation_step!(model::TrafficModel)
    # Actualiza los semáforos
    cycle_light!(model.traffic_lights[1])  # Semáforo horizontal
    cycle_light!(model.traffic_lights[2])  # Semáforo vertical

    # Actualiza todos los coches
    for agent in model.agents
        agent_step!(agent, model)
    end
end

# Ejecuta la simulación por un número determinado de pasos
function run_simulation(steps::Int)
    model = initialize_model()

    for _ in 1:steps
        simulation_step!(model)
    end
end

route("/simulations/:id") do
    model = instances[payload(:id)]
    run!(model, 1)

    # Actualizar estado de los semáforos
    lights_status = []
    for agent in allagents(model)
        if agent isa Light
            push!(lights_status, Dict("state" => agent.state, "pos" => agent.pos))
        end
    end

    json(Dict("cars" => cars, "traffic_lights" => lights_status))
end

