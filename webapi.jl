include("simple.jl")
using Genie, Genie.Renderer.Json, Genie.Requests, HTTP
using UUIDs

# Store the instances
const instances = Dict{String, TrafficModel}()

route("/simulations", method = POST) do
   payload = jsonpayload()
   speed = parse(Float64, get(payload, "speed", "1.0"))  # Parse the speed from the payload
   model = initialize_model(speed)
   id = string(uuid1())
   instances[id] = model
   cars = []
   for car in model.agents
       push!(cars, Dict("id" => car.id, "pos" => car.pos))
   end
   json(Dict("Location" => "/simulations/$id", "cars" => cars))
end

route("/simulations/:id", method = GET) do
   id = params(:id)
   if haskey(instances, id)
       speed = parse(Float64, get(params(), "speed", "1.0"))  # Ensure speed is parsed correctly
       model = instances[id]
       # Update agents with the given speed
       for car in model.agents
           agent_step!(car, model, speed)
       end
       # Update traffic lights
       light_horizontal, light_vertical = model.traffic_lights
       cycle_light!(light_horizontal)
       cycle_light!(light_vertical)
       # Car positions
       cars = []
       for car in model.agents
           push!(cars, Dict("id" => car.id, "pos" => car.pos))
       end
       json(Dict(
           "cars" => cars,
           "traffic_lights" => Dict(
               "horizontal" => light_horizontal.state,
               "vertical" => light_vertical.state
           )
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
