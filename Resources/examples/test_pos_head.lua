-----------------
Config:create_slider('nodes', 0, 100, 1.0, 12)
Config:create_boolean('rt_lt', true)
Config:create_boolean('pos_ang', true)

local function layout_circle(collection, rad)
    local step = 2*math.pi / collection.count
    local angle = 0

    for _,ag in pairs(collection.agents)do
        ag:move_to({0,0})
        ag:lt(angle)
        ag:fd(rad)
        angle = angle + step
    end

end

local function round(x, n)
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end

SETUP = function()

    Nodes = FamilyMobil()
    Nodes:create_n( Config.nodes, function()
        return {
            ['pos']     = {0,0}
            ,['scale']   = 1.5
        }
    end)

    layout_circle(Nodes, 10)

    for _,ag in pairs(Nodes.agents) do
        ag.label = '(' .. round(ag:xcor(),1) .. ' , ' .. round(ag:ycor(),1) .. ')'
    end

    -- A new collection to store the links
    Links = FamilyRelational()

    -- Each agent will create a link with the other agents.
    for _, agent in pairs(Nodes.agents) do
        for _, another_agent in pairs((Nodes:others(agent)).agents) do
            Links:add({
                ['source'] = agent
                ,['target'] = another_agent
                ,['color'] = {0.75, 0, 0, 0.2}
            })
        end
    end

    Agents = FamilyMobil()
    Agents:add({
        ['pos'] = {0,0}
        ,['color'] = {0,0,1,1}
        ,['shape'] = "triangle_2"
        ,['scale'] = 2
    })

    central = one_of (Agents)

end


RUN = function()

    if Config.rt_lt then
        central:rt(2*math.pi/Nodes.count)
    else
        central:lt(2*math.pi/Nodes.count)
    end
    central.heading = math.fmod(central.heading,__2pi)
    central.label   = '(' .. round(central.heading,1) .. ' , ' .. round(math.deg(central.heading),1) .. ')'

    if Config.pos_ang then
        for _,ag in pairs(Nodes.agents) do
            ag.label = '(' .. round(ag:xcor(),1) .. ' , ' .. round(ag:ycor(),1) .. ')'
        end
    else
        for _,ag in pairs(Nodes.agents) do
            ag.label = '(' .. round(ag.heading,1) .. ' , ' .. round(math.deg(ag.heading),1) .. ')'
        end
    end

end

-- Setup and start visualization
-- GraphicEngine.set_setup_function(SETUP)
-- GraphicEngine.set_step_function(RUN)