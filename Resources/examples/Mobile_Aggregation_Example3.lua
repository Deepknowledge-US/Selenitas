-- Interface
Interface:create_slider('Num_Particles', 0, 3000, 1, 500)
Interface:create_slider('Radius', 0.0001, 3, .1, 2)

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
      pos         = {math.random(0,100),math.random(0,100)},
      heading     = random_float(0,__2pi),
      shape       = "circle",
      scale       = Interface:get_value("Radius"),
      color       = random_color(),
      myleader    = nil,
      group       = Collection(),
--      g_size      = 1,
--      label       = 1,
--      label_color = color('white')
    })
  end
  
  -- Initially, each particle's leader is itself
  for _,p in ordered(Particles) do
    p.group:add(p)
    p.myleader = p
   -- p.z_order = 4
  end

  leaders = Particles:with(function(p) return true end)

end


local next = next

local any = function(t)
  return next(t) ~= nil
end

---------------
--  STEP
---------------
STEP = function()

  local r = Interface:get_value("Radius")
  -- Leaders turn randomly and followers follow
  for _,p in ordered(leaders) do
    p:rt(random_float(-0.2,0.2))
  end

  -- Everybody move
  for _,p in ordered(Particles) do
    p.heading = p.myleader.heading
    p:fd(r/10)
    pos_to_torus(p,100,100)
  end

  -- Every particle look for collision
    for _,p in ordered(Particles) do
      -- p_collisions are the particles from other groups that collide with p
      local p_group = p.myleader.group
      -- to reduce computations, we firstly restrict by Manhattan distance (easier to compute)
      local PMan = Particles:with(function(p2) return (p2:dist_manh_to(p) < 1.5*r) end)
      -- then, we take those in other groups
      local in_other_groups = PMan:with(function(p2) return (p.myleader ~= p2.myleader) end)
      -- finally, we compute the particles colliding
      local p_collisions    = in_other_groups:with(function(p2) return (p2:dist_euc2_to(p) < r*r) end)
      if any(p_collisions) then                 -- if it collides...
        for _,p2 in ordered(p_collisions) do    -- take every particle that collides with p
          if p2.myleader ~= p.myleader then     -- check again, maybe it was already added by some 
                                                -- other particle from the same group
            local p2_group = p2.myleader.group  -- take the group of that particle
--            sg2 = p2.myleader.g_size            -- take the size of the group
            leaders:remove(p2.myleader)         -- remove its leader from the leaders collection
--            p2.myleader.label = ""              -- remove its label
--            p2.myleader.z_order = 3
            for _,p3 in ordered(p2_group) do    -- change the leader and color of the group
              p3.myleader = p.myleader
              p3.color = p.myleader.color
            end
            p_group:union(p2_group)                        -- add the group to p.group
--            p.myleader.g_size = p.myleader.g_size + sg2    -- count the new members
--            p.myleader.label = p.myleader.g_size           -- update the label
          end
        end
      end
    end
end