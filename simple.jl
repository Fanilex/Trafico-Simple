using Agents, Random
using Agents: GridAgent
using StaticArrays: SVector
using LinearAlgebra

<<<<<<< HEAD
@enum LightColor green yellow red

@agent TrafficLight GridAgent{2} begin
    color::LightColor
    timer::Int
end

function agent_step!(agent::TrafficLight, model)
    agent.timer += 1
    total_cycle = 28  # 10 verde + 4 amarillo + 14 rojo

    local_time = agent.timer % total_cycle

    if local_time < 10
        agent.color = green
    elseif local_time < 14
        agent.color = yellow
    else
        agent.color = red
    end
end

function initialize_model(extent = (25, 25))
    space = GridSpaceSingle(extent; periodic = false)
    rng = Random.MersenneTwister()

    model = StandardABM(TrafficLight, space; rng, agent_step!, scheduler = Schedulers.Randomly())

    add_agent!((12, 13), model; color=green, timer=0)
    add_agent!((13, 12), model; color=red, timer=14)  # Comienza en rojo

    return model
=======
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

# Traffic light cycling
function cycle_light!(light::TrafficLight)
    if light.timer >= 20
        light.timer = 0
        light.state = light.state == :green ? :yellow :
                      light.state == :yellow ? :red : :green
    else
        light.timer += 1
    end
end

# Initialize traffic lights
function initialize_traffic_lights()
    light_horizontal = TrafficLight(:green, 0)
    light_vertical = TrafficLight(:red, 0)
    return light_horizontal, light_vertical
end

# Accelerate and decelerate functions
function accelerate(agent::Car, speed::Float64)
    if agent.pos[2] == 0  # Horizontal cars
        return SVector(clamp(agent.vel[1] + 0.05 * speed, 0.0, 1.0), 0.0)
    else  # Vertical cars
        return SVector(0.0, clamp(agent.vel[2] + 0.05 * speed, 0.0, 1.0))
    end
end

function decelerate(agent::Car, speed::Float64)
    if agent.pos[2] == 0  # Horizontal cars
        return SVector(clamp(agent.vel[1] - 0.1 * speed, 0.0, 1.0), 0.0)
    else  # Vertical cars
        return SVector(0.0, clamp(agent.vel[2] - 0.1 * speed, 0.0, 1.0))
    end
end

# Car behavior
function agent_step!(agent::Car, model::TrafficModel, speed::Float64)
    light_horizontal, light_vertical = model.traffic_lights
    horizontal_intersection_position = 12.5
    vertical_intersection_position = 5.0

    if agent.pos[2] == 0  # Horizontal street
        if agent.pos[1] <= horizontal_intersection_position  # Before traffic light
            current_light = light_horizontal
            if current_light.state == :red
                agent.vel = SVector(0.0, 0.0)  # Stop at red light
            else
                agent.vel = accelerate(agent, speed)  # Accelerate at green light
            end
        else
            agent.vel = accelerate(agent, speed)  # Accelerate after crossing the light
        end
    end

    if agent.pos[1] == 12.5  # Vertical street
        if abs(agent.pos[2]) <= vertical_intersection_position
            current_light = light_vertical
            if current_light.state == :red
                agent.vel = SVector(0.0, 0.0)  # Stop at red light
            else
                agent.vel = accelerate(agent, speed)  # Accelerate at green light
            end
        else
            agent.vel = accelerate(agent, speed)  # Accelerate after crossing the light
        end
    end

    move_agent!(agent, model, speed)
end

# Wrap position around the space
function wrap_position!(pos::SVector{2, Float64}, space::ContinuousSpace{2, true, Float64, typeof(Agents.no_vel_update)})
    xmin, xmax = 0.0, space.extent[1]
    ymin, ymax = 0.0, space.extent[2]

    # Wrap around the x-coordinate
    new_x = if pos[1] > xmax
        pos[1] - xmax
    elseif pos[1] < xmin
        pos[1] + xmax
    else
        pos[1]
    end

    # Wrap around the y-coordinate
    new_y = if pos[2] > ymax
        pos[2] - ymax
    elseif pos[2] < ymin
        pos[2] + ymax
    else
        pos[2]
    end

    return SVector(new_x, new_y)
end

# Move agent in space with speed adjustment
function move_agent!(agent::Car, model::TrafficModel, speed::Float64)
    scaling_factor = 0.4 * speed  # Scale movement with speed value
    if agent.pos[2] == 0  # Horizontal street
        new_pos = agent.pos + SVector(agent.vel[1] * scaling_factor, 0.0)
    else  # Vertical street
        new_pos = agent.pos + SVector(0.0, agent.vel[2] * scaling_factor)
    end
    agent.pos = wrap_position!(new_pos, model.space)
end

# Initialize model with agents, streets, and traffic lights
function initialize_model(speed::Float64, extent = (25, 10))
    space2d = ContinuousSpace(extent; spacing = 0.5, periodic = true)
    rng = Random.MersenneTwister()

    light_horizontal, light_vertical = initialize_traffic_lights()

    agents = Vector{Car}()

    # 5 cars on the horizontal street
    for i in 1:5
        pos = SVector(rand(Uniform(0.0, 25.0)), 0.0)  # Horizontal street
        vel = SVector(speed, 0.0)  # Uniform speed
        accelerating = true
        push!(agents, Car(i, pos, vel, accelerating))
    end

    # 5 cars on the vertical street
    for i in 6:10
        pos = SVector(12.5, rand(Uniform(0.0, 10.0)))  # Vertical street
        vel = SVector(0.0, speed)  # Uniform speed in Y
        accelerating = true
        push!(agents, Car(i, pos, vel, accelerating))
    end

    return TrafficModel(agents, space2d, (light_horizontal, light_vertical))
>>>>>>> f9e86c053a4930bc58ac781ef32d4b589a0dabdb
end
