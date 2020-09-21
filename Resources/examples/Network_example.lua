-----------------
local radius = 20
Config:create_slider('nodes', 0, 100, 1, 22)
Config:create_slider('links', 0, 10000, 1, 15)


local function layout_circle(collection, rad)
    local step = 2*math.pi / collection.count
    local angle = 0

    for _,ag in pairs(collection.agents) do
        ag:lt(angle)
        ag:fd(rad)
        angle = angle + step
    end

end

SETUP = function()

    Config.go = true

    Nodes = FamilyMobil()
    Nodes:create_n( Config.nodes, function()
        return {
            ['pos']     = {0,0}
            ,['scale']   = 1.5
            ,['shape']   = 'circle'
            ,['color']   = {0,1,0,0.5}
        }
    end)

    layout_circle(Nodes, radius)

    -- A new collection to store the links
    Links = nil
    Links = FamilyRelational()

end


RUN = function()

    local node_1 = one_of(Nodes)
    local node_2 = one_of(Nodes:others(node_1))

    Links:add({
        ['source'] = node_1,
        ['target'] = node_2,
        --['label'] = node_1.id .. '->' .. node_2.id,
        ['color'] = {0.75, 0, 0, .2},
        ['visible'] = true
    })

    while Links.count > Config.links do
        Links:kill_and_purge(one_of(Links))
    end

end

-- GraphicEngine.set_setup_function(SETUP)
-- GraphicEngine.set_step_function(RUN)