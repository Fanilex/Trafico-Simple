using Agents, Random
using Agents: GridAgent
using StaticArrays: SVector

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
end
