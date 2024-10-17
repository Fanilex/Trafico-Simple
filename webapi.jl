include("simple.jl")
using Genie, Genie.Renderer.Json, Genie.Requests, HTTP
using UUIDs

instances = Dict()

route("/simulations", method = POST) do
    payload = jsonpayload()

    model = initialize_model()
    id = string(uuid1())
    instances[id] = model

    cars = []
    for car in model.agents  
        push!(cars, car)
    end

    json(Dict("Location" => "/simulations/$id", "cars" => cars))
end

route("/simulations/:id") do
    println(payload(:id))
    model = instances[payload(:id)]
    
    for car in model.agents
        agent_step!(car, model)
    end
    
    light_horizontal, light_vertical = model.traffic_lights
    cycle_light!(light_horizontal)
    cycle_light!(light_vertical)

    cars = []
    for car in model.agents 
        push!(cars, car)
    end

    json(Dict(
        "cars" => cars,
        "traffic_lights" => Dict(
            "horizontal" => light_horizontal.state,
            "vertical" => light_vertical.state
        )
    ))
end

Genie.config.run_as_server = true
Genie.config.cors_headers["Access-Control-Allow-Origin"] = "*"
Genie.config.cors_headers["Access-Control-Allow-Headers"] = "Content-Type"
Genie.config.cors_headers["Access-Control-Allow-Methods"] = "GET,POST,PUT,DELETE,OPTIONS"
Genie.config.cors_allowed_origins = ["*"]

up()
