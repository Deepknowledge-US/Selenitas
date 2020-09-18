-- Interface

Config:create_slider('Num_mobiles', 0, 500, 1, 10)


-- pos_to_torus relocate the agents as they are living in a torus
local function pos_to_torus(agent, size_x, size_y)
    local x,y = agent:xcor(),agent:ycor()

    if x > size_x then
        agent.pos[1] = agent.pos[1] - size_x
    elseif x < 0 then
        agent.pos[1] = agent.pos[1] + size_x
    end

    if y > size_y then
        agent.pos[2] = agent.pos[2] - size_y
    elseif y < 0 then
        agent.pos[2] = agent.pos[2] + size_y
    end
end

local function random_float(a,b)
    return a + (b-a) * math.random();
end

local function merge(ag,lead)
    ag.leader = lead
    ag.heading = lead.heading
    ag.color = {0,0,1,1}

    local e0 = ag:link_neighbors(Links)
    print("e0 COUNT", e0.count)
    local extend = e0:with(
        function(other)
            return other.leader ~= lead
        end)

    if extend.count > 0 then
        for _,ag2 in pairs(extend.agents) do
            merge(ag2,lead)
        end
    end
end

SETUP = function()
    -- Test collection
    Checkpoints = FamilyMobil()
    Checkpoints:add({ ['pos'] = {0, 100} })
    Checkpoints:add({ ['pos'] = {0,0} })
    Checkpoints:add({ ['pos'] = { 100,0} })
    Checkpoints:add({ ['pos'] = { 100, 100} })

    for _, ch in pairs(Checkpoints.agents) do
        ch.shape = 'circle'
        ch.scale = 5
        ch.color = {1,0,0,1}
        ch.label = ch:xcor() .. ',' .. ch:ycor()
    end

    -- Create a new collection
    Mobiles = FamilyMobil()
    Links   = FamilyRelational()

    -- Populate the collection with Agents.
    Mobiles:create_n( Config.Num_mobiles, function()
        return {
            ['pos']          = {math.random(0,100),math.random(0,100)}
            ,['heading']     = math.random(__2pi)
            ,['shape']       = "circle"
            ,['scale']       = 1
            ,['color']       = {0,0,1,1}
            ,['speed']       = math.random()
            ,['turn_amount'] = 0
        }
    end)

    for _ , ag in pairs(Mobiles.agents) do
        ag.leader = ag
        -- Links:add({
        --     ['source']  = ag
        --     ,['target'] = ag
        --     ,['color']  = {1,0,0,1}
        --     --,['visible'] = false
        --     })
    end

    Config.go = true

end

-- This function is executed until the stop condition is reached, 
-- or the button go/stop is stop
RUN = function()

    local alone = Mobiles:with(function(ag)
        return ag.leader == ag
    end)
    for _,ag in pairs(alone.agents) do
        ag.turn_amount = math.random(-0.2,0.2)
    end

    for _,ag in pairs(Mobiles.agents) do
        ag:rt(ag.leader.turn_amount)
        ag:fd(0.5)
        pos_to_torus(ag,100,100)
    end

    for _,ag in pairs(Mobiles.agents) do
        local candidates = Mobiles:with(function(other)
            return (ag:dist_euc_to(other) < 1) and (ag.leader ~= other.leader)
        end)
        if candidates.count > 0 then
            for _,ag2 in ordered(candidates) do
                Links:add({
                    ['source']  = ag
                    ,['target'] = ag2
                    ,['color']  = {1,0,0,1}
                    --,['visible'] = false
                    })
                merge(ag2,ag.leader)
            end
        end
    end
end

-- Setup and start visualization
-- GraphicEngine.set_setup_function(SETUP)
-- GraphicEngine.set_step_function(RUN)