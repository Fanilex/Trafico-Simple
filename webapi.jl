"webapi.jl":

include("simple.jl")
using Genie, Genie.Renderer.Json, Genie.Requests, HTTP
using UUIDs


# Guarda las instancias
const instances = Dict{String, TrafficModel}()


route("/simulations", method = POST) do
model = initialize_model()
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
model = instances[id]
# actualiza los agentes
for car in model.agents
agent_step!(car, model)
end
# semaforos
light_horizontal, light_vertical = model.traffic_lights
cycle_light!(light_horizontal)
cycle_light!(light_vertical)
# posiciones de los coches
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