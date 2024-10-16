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


# Ciclo de los semáforos
function cycle_light!(light::TrafficLight)
   if light.timer >= 20
       light.timer = 0
       light.state = light.state == :green ? :yellow :
                     light.state == :yellow ? :red : :green
   else
       light.timer += 1
   end
end


# Inicializar los semáforos
function initialize_traffic_lights()
   light_horizontal = TrafficLight(:green, 0)
   light_vertical = TrafficLight(:red, 0)
   return light_horizontal, light_vertical
end


# Funciones para acelerar y desacelerar
function accelerate(agent::Car, speed::Float64)
   if agent.pos[2] == 0  # Coches en la calle horizontal
       return SVector(clamp(agent.vel[1] + 0.05 * speed, 0.0, 1.0), 0.0)
   else  # Coches en la calle vertical
       return SVector(0.0, clamp(agent.vel[2] + 0.05 * speed, 0.0, 1.0))
   end
end


function decelerate(agent::Car, speed::Float64)
   if agent.pos[2] == 0  # Coches en la calle horizontal
       return SVector(clamp(agent.vel[1] - 0.1 * speed, 0.0, 1.0), 0.0)
   else  # Coches en la calle vertical
       return SVector(0.0, clamp(agent.vel[2] - 0.1 * speed, 0.0, 1.0))
   end
end


# Comportamiento del coche
function agent_step!(agent::Car, model::TrafficModel, speed::Float64)
   light_horizontal, light_vertical = model.traffic_lights
   horizontal_intersection_position = 12.5
   vertical_intersection_position = 5.0


   if agent.pos[2] == 0  # Calle horizontal
       if agent.pos[1] <= horizontal_intersection_position  # Antes del semáforo
           current_light = light_horizontal
           if current_light.state == :red
               agent.vel = SVector(0.0, 0.0)  # Detener en el semáforo en rojo
           else
               agent.vel = accelerate(agent, speed)  # Acelerar en luz verde
           end
       else
           agent.vel = accelerate(agent, speed)  # Acelerar después de cruzar el semáforo
       end
   elseif agent.pos[1] == 12.5  # Calle vertical
       if abs(agent.pos[2]) <= vertical_intersection_position
           current_light = light_vertical
           if current_light.state == :red
               agent.vel = SVector(0.0, 0.0)  # Detener en el semáforo en rojo
           else
               agent.vel = accelerate(agent, speed)  # Acelerar en luz verde
           end
       else
           agent.vel = accelerate(agent, speed)  # Acelerar después de cruzar el semáforo
       end
   end
   move_agent!(agent, model, speed)
end


# Envolver la posición dentro del espacio
function wrap_position!(pos::SVector{2, Float64}, space::ContinuousSpace{2, true, Float64, typeof(Agents.no_vel_update)})
   xmin, xmax = 0.0, space.extent[1]
   ymin, ymax = 0.0, space.extent[2]


   # Envolver alrededor de la coordenada x (calle horizontal)
   new_x = if pos[1] > xmax
       pos[1] - xmax
   elseif pos[1] < xmin
       pos[1] + xmax
   else
       pos[1]
   end


   # Envolver alrededor de la coordenada y (calle vertical)
   new_y = if pos[2] > ymax
       0.0  # Reiniciar al inicio de la calle vertical
   elseif pos[2] < ymin
       ymax  # Si van en dirección contraria, aparecen desde el final
   else
       pos[2]
   end


   return SVector(new_x, new_y)
end


# Mover el coche en el espacio con ajuste de velocidad
function move_agent!(agent::Car, model::TrafficModel, speed::Float64)
   scaling_factor = max(0.1, 0.4 * speed)  # Mínimo factor de escala de 0.1 para asegurar movimiento
   if agent.pos[2] == 0  # Calle horizontal
       new_pos = agent.pos + SVector(agent.vel[1] * scaling_factor, 0.0)
   else  # Calle vertical
       new_pos = agent.pos + SVector(0.0, agent.vel[2] * scaling_factor)
   end


   agent.pos = wrap_position!(new_pos, model.space)
end


# Calcular la velocidad promedio
function calculate_average_velocity(model::TrafficModel)
   total_velocity = 0.0
   for agent in model.agents
       total_velocity += norm(agent.vel)  # Obtener la magnitud de la velocidad
   end
   return total_velocity / length(model.agents)  # Devolver el promedio de las velocidades
end


# Function to initialize the model with cars, streets, and traffic lights
# Default extent parameter added to the method
function initialize_model(speed::Float64, extent::Tuple{Int, Int} = (25, 10))
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
end
