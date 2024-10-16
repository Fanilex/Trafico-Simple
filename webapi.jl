include("simple.jl")
using Genie, Genie.Renderer.Json, Genie.Requests, HTTP
using UUIDs

instances = Dict()

route("/simulations", method = POST) do
    payload = jsonpayload()

    model = initialize_model()
    id = string(uuid1())
    instances[id] = model

    traffic_lights = []
    for light in allagents(model)
        light_data = Dict(
            "id" => string(light.id),
            "pos" => Tuple(light.pos),
            "color" => string(light.color)
        )
        push!(traffic_lights, light_data)
        println("Enviando datos del semáforo (setup): ", light_data)
    end

    json(Dict("Location" => "/simulations/$id", "traffic_lights" => traffic_lights))
end

route("/simulations/:id") do
    model = instances[payload(:id)]
    run!(model, 1)

    traffic_lights = []
    for light in allagents(model)
        light_data = Dict(
            "id" => string(light.id),
            "pos" => Tuple(light.pos),
            "color" => string(light.color)
        )
        push!(traffic_lights, light_data)
        println("Enviando datos del semáforo (actualización): ", light_data)
    end

    json(Dict("traffic_lights" => traffic_lights))
end

Genie.config.run_as_server = true
Genie.config.cors_headers["Access-Control-Allow-Origin"] = "*"
Genie.config.cors_headers["Access-Control-Allow-Headers"] = "Content-Type"
Genie.config.cors_headers["Access-Control-Allow-Methods"] = "GET,POST,PUT,DELETE,OPTIONS"
Genie.config.cors_allowed_origins = ["*"]

up()
