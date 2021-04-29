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
            , turn        = 0
            , leader      = true -- True if a particle is acting as a group leader
        })
    end

    -- Initially, each particle's leader is itself
    for _,ag in ordered(Particles) do
        ag.myleader = ag
    end

end

---------------
--  STEP
---------------
STEP = function()

    -- Compute Leaders and Followers
    local leaders   = Particles:with(function(ag) return ag.leader == true end)
    local followers = Particles:with(function(ag) return ag.leader == false end)

    -- Leaders turn randomly
    for _,ag in ordered(leaders) do
        ag:rt(random_float(-0.1,0.1))
    end

    -- Followers face the same direction of their leaders
    for _,ag in ordered(followers) do
        ag.heading = ag.myleader.heading
    end

    -- Everybody move
    for _,ag in ordered(Particles) do
        ag:fd(.1)
        pos_to_torus(ag,100,100)
    end

    -- Only on access to interface
    local at = Interface:get_value("Attraction_radius")

    -- Every particle look for collision
    for _,ag in ordered(Particles) do
        local ag_collided = Particles:with(function(o) return  (ag.myleader ~= o.myleader) and (o:dist_euc_to(ag) < at) end)
        -- if it collides...
        if ag_collided.count > 0 then
            for _,ag2 in ordered(ag_collided) do
                -- Take the group of every collision
                local group_of_ag2 = Particles:with(function(other) return ag2.myleader == other.myleader end)
                -- and change the leaders of all the particles in the group (also the color)
                for _,ag3 in ordered(group_of_ag2) do
                    ag3.myleader = ag.myleader
                    ag3.leader   = false
                    ag3.color    = ag.color
                end
            end
        end
    end
end