using Agents, Random
using StaticArrays: SVector
using LinearAlgebra 

mutable struct Car
    id::Int
    pos::SVector{2, Float64}
    vel::SVector{2, Float64}
    accelerating::Bool
end

mutable struct TrafficLight
    state::Symbol 
    timer::Int     
end

struct TrafficModel
    agents::Vector{Car}  
    space::ContinuousSpace{2, true, Float64, typeof(Agents.no_vel_update)}
    traffic_lights::Tuple{TrafficLight, TrafficLight}
end

function cycle_light!(light::TrafficLight)
    if light.timer >= 20
        light.timer = 0
        light.state = light.state == :green ? :yellow :
                      light.state == :yellow ? :red : :green
    else
        light.timer += 1
    end
end

function initialize_traffic_lights()
    light_horizontal = TrafficLight(:green, 0) 
    light_vertical = TrafficLight(:red, 0)     
    return light_horizontal, light_vertical
end

accelerate(agent::Car) = agent.vel[1] + 0.05
decelerate(agent::Car) = agent.vel[1] - 0.1

function car_ahead(agent::Car, model::TrafficModel)
    for neighbor in model.agents
        if agent.direction == neighbor.direction && neighbor.pos != agent.pos &&
           norm(neighbor.pos - agent.pos) < 1.0 
            return neighbor
        end
    end
    return nothing
end

function agent_step!(agent::Car, model::TrafficModel)
    light_horizontal, light_vertical = model.traffic_lights
    horizontal_intersection_position = 12.5  
    vertical_intersection_position = 5.0    

    if agent.pos[2] == 0
        if agent.pos[1] <= horizontal_intersection_position  # Antes del semaforo
            current_light = light_horizontal
            if current_light.state == :red
                agent.vel = SVector(0.0, 0.0)  # Detiene en el semaforo
            else
                agent.vel = SVector(clamp(accelerate(agent), 0.0, 1.0), 0.0)  
            end
        else
            # Después del semaforo les vale respetarlo
            agent.vel = SVector(clamp(accelerate(agent), 0.0, 1.0), 0.0)
        end
    end

    if agent.pos[1] == 12.5  
        if abs(agent.pos[2]) <= vertical_intersection_position 
            current_light = light_vertical
            if current_light.state == :red
                agent.vel = SVector(0.0, 0.0) 
            else
                agent.vel = SVector(0.0, clamp(accelerate(agent), 0.0, 1.0)) 
            end
        else
            agent.vel = SVector(0.0, clamp(accelerate(agent), 0.0, 1.0))
        end
    end

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
    scaling_factor = 0.4
    if agent.pos[2] == 0  # Calle horizontal
        new_pos = agent.pos + SVector(agent.vel[1] * scaling_factor, 0.0)
    else  # Calle vertical
        new_pos = agent.pos + SVector(0.0, agent.vel[2] * scaling_factor)
    end
    agent.pos = wrap_position!(new_pos, model.space)
end

function initialize_model(extent = (25, 10))
    space2d = ContinuousSpace(extent; spacing = 0.5, periodic = true)
    rng = Random.MersenneTwister()

    light_horizontal, light_vertical = initialize_traffic_lights()

    agents = Vector{Car}()

    for i in 1:5
        pos = SVector(rand(Uniform(0.0, 25.0)), 0.0)  # Calle horizontal
        vel = SVector(rand(Uniform(0.2, 1.0)), 0.0)
        accelerating = true
        push!(agents, Car(i, pos, vel, accelerating))
    end

    for i in 6:10
        pos = SVector(12.5, rand(Uniform(0.0, 10.0)))  # Calle vertical
        vel = SVector(0.0, rand(Uniform(0.2, 1.0)))  # Movimiento en el eje Y
        accelerating = true
        push!(agents, Car(i, pos, vel, accelerating))
    end

    return TrafficModel(agents, space2d, (light_horizontal, light_vertical))
end