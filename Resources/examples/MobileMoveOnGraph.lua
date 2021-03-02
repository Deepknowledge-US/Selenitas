--[[
    Creates a random cycle-graph and one mobile agent, and moves 
    the agent through the graph.
    It offers two ways:
    1) Jump directly from one node to another
    2) Move continuously crossing the edges

]]

-----------------
-- Interface 
-----------------
Interface:create_slider('N_nodes', 0, 50, 1, 20)
Interface:create_slider('Speed', 0, 4.00001, .01, 1)
Interface:create_boolean('Jump', true)

-----------------
-- Setup function 
-----------------

SETUP = function()

  Simulation:reset()
  
  declare_FamilyMobile('Nodes')
  declare_FamilyRel('Edges')
  declare_FamilyMobile('Walkers')
  -- By default, all mobile families have a z_order = 3, by increasing it, 
  -- walkers will be painted over the other Mobil agents
  Walkers.z_order = 4 

  local N_nodes = Interface:get_value('N_nodes')
  
  for i=1,N_nodes do
    Nodes:new({
      pos        = {0,0},
      shape      = 'circle',
      heading    = 2 * i * math.pi/N_nodes,
      color      = color('red'),
      shade      = 0,
      scale      = 3,
      label      = i,
      show_label = true
    })
  end

  for _,nod in ordered(Nodes) do
    nod:fd(math.random(20,30))
  end

  -- Create a list of nodes
  local list_of_nodes = fam_to_list(Nodes)

  -- Create edges between nodes following the order of the list
  for i=1,N_nodes do
    nx = i + 1
    if i == N_nodes then nx = 1 end
    Edges:new({
      source = list_of_nodes[i],
      target = list_of_nodes[nx]
    })
  end

  -- New method for Walkers: from current node take next node
  -- to move (the next one in the cycle)
  Walkers:add_method(
    'search_next_node',
    function(self)
      self.next_node = one_of(self.curr_node:get_out_neighs()) -- take the next node
      self:face(self.next_node)                                -- face to it
    end)

  -- Select one of nodes (starting node)
  local node = one_of(Nodes)

  -- Create one walker and locate it in the selected node
  Wlkr = Walkers:new({
    pos       = copy(node.pos),
    curr_node = node,
    color     = color('yellow'),
    scale     = 1.5,
    shape     = 'triangle',
    next_node = node
  })
end

-----------------
-- Step function 
-----------------

STEP = function()
  -- In every step:
  sp =  Interface:get_value('Speed')
  if Interface:get_value('Jump') then
    -- with jumping movements
    Wlkr:move_to(Wlkr.next_node.pos)       -- Move the walker to the goal-node
    Wlkr.curr_node.color = color('red')
    Wlkr.curr_node       = Wlkr.next_node  -- Change the current node to be the goal
    Wlkr.curr_node.color = shade_of(color('red'),1)
    Wlkr:search_next_node()                -- Search for the next movement
  else
    -- with continuous movements 
    -- If we are close enough
    if Wlkr:dist_euc_to(Wlkr.next_node) < sp then 
      Wlkr:move_to(Wlkr.next_node)      -- Move directly to the goal
  --    Wlkr.curr_node.color = color('red')
      Wlkr.curr_node = Wlkr.next_node   -- Change current node for the goal
      Wlkr.curr_node.shade = 1
--      Wlkr.curr_node.color = shade_of(color('red'),1)
      Wlkr:search_next_node()           -- Search the next one
    else
      Wlkr:fd(sp)          -- Advance in the current direction
    end
    for _,nod in ordered(Nodes) do
    nod.color = shade_of(color('red'),nod.shade)
    nod.shade = nod.shade - .01
    end
  end

end