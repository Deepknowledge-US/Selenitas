require 'Engine.utilities.utl_main'

local radius = 20
Config:create_slider('nodes', 0, 100, 1, 22)
Config:create_slider('links', 0, 30, 1, 15)


local function layout_circle(collection, rad)
    local num = collection.count
    local step = 2*math.pi / num
    local degrees = 0

    for k,v in pairs(collection.agents)do
        local current_agent = collection.agents[k]
        current_agent:lt(degrees)
        current_agent:fd(rad)
        degrees = degrees + step
    end

end

SETUP = function()

    Config.go = true

    Nodes = FamilyMobil()
    Nodes:create_n( Config.nodes, function()
        return {
            ['pos']     = {0,0},
            ['scale']   = 1.5,
            ['head']    = {0,0}
        }
    end)


    layout_circle(Nodes, radius - 1 )

    -- A new collection to store the links
    Links = FamilyRelational()

end


RUN = function()

    -- -- Each agent will create a link with the other agents.
    -- ask(Nodes, function(agent)
    --     ask(Nodes:others(agent), function(another_agent)
    --         Links:add({
    --                 ['source'] = agent,
    --                 ['target'] = another_agent,
    --                 ['label'] = "",--agent.id .. ',' .. another_agent.id,
    --                 ['visible'] = true,
    --                 ['color'] = {0.75, 0, 0, 1}
    --             }
    --         )
    --     end)
    -- end)

    ask(one_of(Nodes), function(node_1)

        local node_2 = one_of(Nodes:others(node_1))

        Links:add({
            ['source'] = node_1,
            ['target'] = node_2,
            ['label'] = "",--agent.id .. ',' .. another_agent.id,
            ['visible'] = true,
            ['color'] = {0.75, 0, 0, 1}
        })

        if Links.count > Config.links then
            Links:kill(one_of(Links))
            purge_agents(Links) -- If this line is commented, links killed are drawn (they are dead, but remains in the system until been purged)
        end

    end)

end

GraphicEngine.set_setup_function(SETUP)
GraphicEngine.set_step_function(RUN)