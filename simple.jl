using Agents, Random
using StaticArrays: SVector

struct Car
    id::Int
    pos::SVector{2, Float64}
    vel::SVector{2, Float64}
    accelerating::Bool
end

struct TrafficLight
    state::Symbol 
    timer::Int   
end

struct TrafficModel
    agents::Vector{Car}   
    space::ContinuousSpace{2, true, Float64, typeof(Agents.no_vel_update)}
    traffic_lights::Tuple{TrafficLight, TrafficLight}
end

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
    light_horizontal = TrafficLight(:green, 0)  
    light_vertical = TrafficLight(:red, 0)      
    return light_horizontal, light_vertical
end

accelerate(agent::Car) = agent.vel[1] + 0.05
decelerate(agent::Car) = agent.vel[1] - 0.1

function car_ahead(agent::Car, model::TrafficModel)
    for neighbor in model.agents
        if neighbor.pos[1] > agent.pos[1] && norm(neighbor.pos - agent.pos) < 1.0
            return neighbor
        end
    end
    return nothing
end

function agent_step!(agent::Car, model::TrafficModel)
    light_horizontal, light_vertical = model.traffic_lights

    current_light = agent.pos[1] > 0 ? light_horizontal : light_vertical

    if current_light.state == :red
        new_velocity = 0.0
    else
        new_velocity = isnothing(car_ahead(agent, model)) ? accelerate(agent) : decelerate(agent)
    end

    new_velocity = clamp(new_velocity, 0.0, 1.0)

    agent.vel = SVector(new_velocity, 0.0)
    move_agent!(agent, model)
end

function move_agent!(agent::Car, model::TrafficModel)
    new_pos = agent.pos + SVector(agent.vel[1] * 0.4, 0.0)
    agent.pos = wrap_position(new_pos, model.space)
end

function initialize_model(extent = (25, 10))
    space2d = ContinuousSpace(extent; spacing = 0.5, periodic = true)
    rng = Random.MersenneTwister()

    light_horizontal, light_vertical = initialize_traffic_lights()

    agents = Vector{Car}()
    for i in 1:5
        pos = SVector(rand(Uniform(0.0, 25.0)), 0.0) 
        vel = SVector(rand(Uniform(0.2, 1.0)), 0.0)
        accelerating = true
        push!(agents, Car(i, pos, vel, accelerating))
    end

    return TrafficModel(agents, space2d, (light_horizontal, light_vertical))
end
