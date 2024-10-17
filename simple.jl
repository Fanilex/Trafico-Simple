using Agents, Random
using StaticArrays: SVector
using LinearAlgebra  # la importo por el error de `norm`, no borrar

# define al coche como mutable struct
mutable struct Car
    id::Int
    pos::SVector{2, Float64}
    vel::SVector{2, Float64}
    accelerating::Bool
end

# tambien es mutable struct
mutable struct TrafficLight
    state::Symbol  # verde, amarillo o rojo
    timer::Int     # tiempo en cada estado
end

struct TrafficModel
    agents::Vector{Car}   
    space::ContinuousSpace{2, true, Float64, typeof(Agents.no_vel_update)}
    traffic_lights::Tuple{TrafficLight, TrafficLight}
end

# funcionamiento de los semaforos
function cycle_light!(light::TrafficLight)
    if light.timer >= 10
        light.timer = 0
        light.state = light.state == :green ? :yellow :
                      light.state == :yellow ? :red : :green
    else
        light.timer += 1
    end
end

function initialize_traffic_lights()
    light_horizontal = TrafficLight(:green, 0)  # Green light initially
    light_vertical = TrafficLight(:red, 0)      # Red light initially
    return light_horizontal, light_vertical
end

accelerate(agent::Car) = agent.vel[1] + 0.05
decelerate(agent::Car) = agent.vel[1] - 0.1

function car_ahead(agent::Car, model::TrafficModel)
    for neighbor in model.agents
        if neighbor.pos[1] > agent.pos[1] && norm(neighbor.pos - agent.pos) < 1.0  # norm encuentra la distancia
            return neighbor
        end
    end
    return nothing
end

# agent_step!
function agent_step!(agent::Car, model::TrafficModel)
    light_horizontal, light_vertical = model.traffic_lights

    current_light = agent.pos[1] > 0 ? light_horizontal : light_vertical

    # segun que esto cambia la velocidad del auto segun el estado del semaforo, pero apenas estoy probando
    if current_light.state == :red
        new_velocity = 0.0
    else
        new_velocity = isnothing(car_ahead(agent, model)) ? accelerate(agent) : decelerate(agent)
    end

    new_velocity = clamp(new_velocity, 0.0, 1.0)

    agent.vel = SVector(new_velocity, 0.0)
    move_agent!(agent, model)
end

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

function move_agent!(agent::Car, model::TrafficModel)
    new_pos = agent.pos + SVector(agent.vel[1] * 0.4, 0.0)

    agent.pos = wrap_position!(new_pos, model.space)
end

function initialize_model(extent = (25, 10))
    space2d = ContinuousSpace(extent; spacing = 0.5, periodic = true)
    rng = Random.MersenneTwister()

    light_horizontal, light_vertical = initialize_traffic_lights()

    agents = Vector{Car}()
    for i in 1:5
        pos = SVector(rand(Uniform(0.0, 25.0)), 0.0)  # Cars starting at random x on the horizontal street
        vel = SVector(rand(Uniform(0.2, 1.0)), 0.0)
        accelerating = true
        push!(agents, Car(i, pos, vel, accelerating))
    end

    return TrafficModel(agents, space2d, (light_horizontal, light_vertical))
end
