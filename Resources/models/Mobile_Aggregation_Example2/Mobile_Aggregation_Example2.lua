-- Interface
Interface:create_slider('Num_Particles', 0, 3000, 1, 100)
Interface:create_slider('Attraction_radius', 0, 3, 1, 1)

panels_channel:push(Interface.windows)

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

local leaders = Collection()

SETUP = function()

    Simulation:reset()

    -- Create a new collection
    declare_FamilyMobile('Particles')

    -- Populate the collection with Agents.
    for i = 1,Interface:get_value("Num_Particles") do
        Particles:new({
              pos         = {math.random(0,100),math.random(0,100)}
            , heading     = random_float(0,__2pi)
            , shape       = "circle"
            , scale       = 1
            , color       = {random_float(0,1),random_float(0,1),random_float(0,1),1}
            , myleader    = nil
            , group       = Collection()
        })
    end

    -- Initially, each particle's leader is itself
    for _,p in ordered(Particles) do
        p.group:add(p)
        p.myleader = p
    end

    leaders = Particles:with(function(p) return true end)

end

---------------
--  STEP
---------------
STEP = function()

    -- Leaders turn randomly and followers follow
    for _,p in ordered(leaders) do
        p:rt(random_float(-0.1,0.1))
        for _, fol in ordered(p.group) do
            fol.heading = p.heading
        end
    end

    -- Everybody move
    for _,p in ordered(Particles) do
        p:fd(.1)
        pos_to_torus(p,100,100)
    end

    -- Only on access to interface
    local at = Interface:get_value("Attraction_radius")

    -- Every particle look for collision
    for _,p in ordered(Particles) do
        -- p_collisions are the particles from other groups that collide with p
        local in_other_groups = Particles:with(function(p2) return (p.myleader ~= p2.myleader) end)
        local p_collisions    = in_other_groups:with(function(p2) return (p2:dist_euc_to(p) < at) end)
        -- if it collides...
        if p_collisions.count > 0 then
            for _,p2 in ordered(p_collisions) do        -- take every collision with p
                if p2.myleader ~= p.myleader then       -- if it has not been considered before 
                                                        -- (it still has a different leader)
                    local p2_group = p2.myleader.group  --      take the group that collides
                    leaders:remove(p2.myleader)         --      remove its leader from the collection
                    for _,p3 in ordered(p2_group) do    --      add the group to p.group
                        p.myleader.group:add(p3)
                        p3.myleader = p.myleader
                        p3.color = p.myleader.color
                    end
                end
            end
        end
    end
end