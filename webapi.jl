include("simple.jl")
using Genie, Genie.Renderer.Json, Genie.Requests, HTTP
using UUIDs


# Store the instances
const instances = Dict{String, TrafficModel}()


route("/simulations", method = POST) do
   payload = jsonpayload()


   # Get the speed from the payload
   speed = get(payload, "speed", 1.0)


   # Handle the case where speed is a string or int
   if typeof(speed) == String
       speed = parse(Float64, speed)
   elseif typeof(speed) == Int64
       speed = Float64(speed)
   end


   model = initialize_model(speed)
   id = string(uuid1())
   instances[id] = model
   cars = []
   for car in model.agents
       push!(cars, Dict("id" => car.id, "pos" => car.pos, "velocity" => norm(car.vel)))  # Add velocity
   end
   json(Dict("Location" => "/simulations/$id", "cars" => cars))
end


route("/simulations/:id", method = GET) do
   id = params(:id)
   if haskey(instances, id)
       # Handle speed correctly
       speed = get(params(), "speed", 1.0)
       if typeof(speed) == String
           speed = parse(Float64, speed)
       elseif typeof(speed) == Int64
           speed = Float64(speed)
       end


       model = instances[id]
      
       # Update agents and traffic lights
       for car in model.agents
           agent_step!(car, model, speed)
       end


       light_horizontal, light_vertical = model.traffic_lights
       cycle_light!(light_horizontal)
       cycle_light!(light_vertical)


       # Calculate average velocity
       avg_velocity = calculate_average_velocity(model)


       cars = []
       for car in model.agents
           push!(cars, Dict("id" => car.id, "pos" => car.pos, "velocity" => norm(car.vel)))
       end


       json(Dict(
           "cars" => cars,
           "traffic_lights" => Dict(
               "horizontal" => light_horizontal.state,
               "vertical" => light_vertical.state
           ),
           "avg_velocity" => avg_velocity  # Include average velocity
       ))
   else
       HTTP.status(404)
       json(Dict("error" => "Simulation with ID $id not found"))
   end
end


Genie.config.run_as_server = true
Genie.config.cors_headers["Access-Control-Allow-Origin"] = "*"
Genie.config.cors_headers["Access-Control-Allow-Headers"] = "Content-Type"
Genie.config.cors_headers["Access-Control-Allow-Methods"] = "GET,POST,PUT,DELETE,OPTIONS"
Genie.config.cors_allowed_origins = ["*"]


up()



