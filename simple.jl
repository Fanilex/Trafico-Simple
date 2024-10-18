using Agents, Random
using StaticArrays: SVector
using LinearAlgebra  # Import LinearAlgebra for `norm`

# Define a mutable Car agent to allow field modifications
mutable struct Car
    id::Int
    pos::SVector{2, Float64}
    vel::SVector{2, Float64}
    direction::Symbol  # :horizontal or :vertical
    accelerating::Bool
end

# Change TrafficLight to a mutable struct to allow changes
mutable struct TrafficLight
    state::Symbol  # :green, :yellow, or :red
    timer::Int     # Tracks the time spent in the current state
end

# Custom model type to hold agents, space, and traffic lights
struct TrafficModel
    agents::Vector{Car}   # List of Car agents
    space::ContinuousSpace{2, true, Float64, typeof(Agents.no_vel_update)}
    traffic_lights::Tuple{TrafficLight, TrafficLight}
end

# Traffic light cycling function
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
    light_horizontal = TrafficLight(:green, 0)  # Green light initially for horizontal street
    light_vertical = TrafficLight(:red, 0)      # Red light initially for vertical street
    return light_horizontal, light_vertical
end

# Velocity control functions
accelerate(agent::Car) = agent.vel[1] + 0.05
decelerate(agent::Car) = agent.vel[1] - 0.1

# Find if there's a car ahead (checks within 1.0 distance)
function car_ahead(agent::Car, model::TrafficModel)
    for neighbor in model.agents
        if agent.direction == neighbor.direction && neighbor.pos != agent.pos &&
           norm(neighbor.pos - agent.pos) < 1.0  # Use norm to find distance
            return neighbor
        end
    end
    return nothing
end

# Function to update agent step by step
function agent_step!(agent::Car, model::TrafficModel)
    # Access the traffic lights from the model
    light_horizontal, light_vertical = model.traffic_lights

<<<<<<< HEAD
    # Modify car velocity based on light state
    if agent.direction == :horizontal
        # Horizontal cars respect the horizontal traffic light
        current_light = light_horizontal
    else
        # Vertical cars respect the vertical traffic light
        current_light = light_vertical
    end

    # Adjust velocity based on traffic light and cars ahead
=======
    # Decidir el semáforo basado en la posición
    current_light = agent.pos[2] == 0 ? light_horizontal : light_vertical  # Cambia si están en el eje Y

>>>>>>> kong
    if current_light.state == :red
        new_velocity = 0.0
    else
        new_velocity = isnothing(car_ahead(agent, model)) ? accelerate(agent) : decelerate(agent)
    end

    # Limit the velocity
    new_velocity = clamp(new_velocity, 0.0, 1.0)

<<<<<<< HEAD
    # Update agent's velocity and position
    if agent.direction == :horizontal
        agent.vel = SVector(new_velocity, 0.0)
    else
        agent.vel = SVector(0.0, new_velocity)
    end
    move_agent!(agent, model)
end

# Custom function to wrap the position within space boundaries
=======
    # Actualiza la velocidad dependiendo de la dirección (eje X o Y)
    if agent.pos[2] == 0  # Calle horizontal
        agent.vel = SVector(new_velocity, 0.0)
    else  # Calle vertical
        agent.vel = SVector(0.0, new_velocity)
    end

    move_agent!(agent, model)
end


>>>>>>> kong
function wrap_position!(pos::SVector{2, Float64}, space::ContinuousSpace{2, true, Float64, typeof(Agents.no_vel_update)})
    # Get the space's extents (limits)
    xmin, xmax = 0.0, space.extent[1]
    ymin, ymax = 0.0, space.extent[2]

    # Apply wrapping logic based on whether the space is periodic
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

# Move the agent in the space
function move_agent!(agent::Car, model::TrafficModel)
<<<<<<< HEAD
    # Move the agent based on the velocity and update position
    if agent.direction == :horizontal
        new_pos = agent.pos + SVector(agent.vel[1] * 0.4, 0.0)
    else
=======
    if agent.pos[2] == 0  # Calle horizontal
        new_pos = agent.pos + SVector(agent.vel[1] * 0.4, 0.0)
    else  # Calle vertical
>>>>>>> kong
        new_pos = agent.pos + SVector(0.0, agent.vel[2] * 0.4)
    end

    # Wrap the position using custom logic
    agent.pos = wrap_position!(new_pos, model.space)
end

<<<<<<< HEAD
# Initialize the model with agents, streets, and traffic lights
=======

>>>>>>> kong
function initialize_model(extent = (25, 10))
    # Create a 2D continuous space for the agents
    space2d = ContinuousSpace(extent; spacing = 0.5, periodic = true)
    rng = Random.MersenneTwister()

    # Initialize traffic lights
    light_horizontal, light_vertical = initialize_traffic_lights()

    # Create agents (Cars)
    agents = Vector{Car}()
    
<<<<<<< HEAD
    # Create 5 horizontal cars (starting at random x on the horizontal street)
    for i in 1:5
        pos = SVector(rand(Uniform(0.0, 25.0)), 0.0)  # Positioned along the horizontal street
=======
    # Carros en la calle horizontal
    for i in 1:5
        pos = SVector(rand(Uniform(0.0, 25.0)), 0.0)  # Calle horizontal
>>>>>>> kong
        vel = SVector(rand(Uniform(0.2, 1.0)), 0.0)
        push!(agents, Car(i, pos, vel, :horizontal, true))
    end
    
    # Create 5 vertical cars (starting at random y on the vertical street)
    vertical_street_x = 12.5  # The x-coordinate of the vertical street (middle of the space horizontally)
    for i in 6:10
        pos = SVector(vertical_street_x, rand(Uniform(0.0, 10.0)))  # Positioned along the vertical street
        vel = SVector(0.0, rand(Uniform(0.2, 1.0)))
        push!(agents, Car(i, pos, vel, :vertical, true))
    end
    
    # Carros en la calle vertical (modificamos el eje Y y la dirección de velocidad)
    for i in 6:10
        pos = SVector(0.0, rand(Uniform(0.0, 10.0)))  # Calle vertical
        vel = SVector(0.0, rand(Uniform(0.2, 1.0)))  # Movimiento en el eje Y
        accelerating = true
        push!(agents, Car(i, pos, vel, accelerating))
    end

    # Return the TrafficModel with agents, space, and traffic lights
    return TrafficModel(agents, space2d, (light_horizontal, light_vertical))
end

