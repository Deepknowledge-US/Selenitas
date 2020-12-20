require 'Engine.utilities.utl_main'

-- local g = require('luagraphs.data.graph').create(0,true)
-- g:addEdge(0, 5) -- bidirectional edge connecting 0 and 5
-- g:addEdge(2, 4)
-- g:addEdge(2, 3)
-- g:addEdge(1, 2)
-- g:addEdge(0, 1)
-- g:addEdge(3, 4)
-- g:addEdge(3, 5)
-- g:addEdge(0, 2)

-- print(g:vertexCount()) -- return 6

-- -- code below prints the adjacency list 
-- for k = 0, g:vertexCount() -1 do -- iterate through all vertices in g
--     local v = g:vertexAt(k)
--     local adj_v = g:adj(v) -- adjacency list for vertex v
--     local text = v .. ': '
--     for i = 0, adj_v:size()-1 do
--         local e = adj_v:get(i)
--         text = text .. e:other(v) .. '(' .. e.weight .. ')' 
--     end
--     print(text)
-- end

local dijkstra = dijkstra.create()
local g = graph.create(8, true)

-- local g = graph

-- g.create(8, true);

g:addEdge(0, 1, 5.0) -- edge from 0 to 1 is 5.0 in distance
g:addEdge(0, 4, 9.0)
g:addEdge(0, 7, 8.0)
g:addEdge(1, 2, 12.0)
g:addEdge(1, 3, 15.0)
g:addEdge(1, 7, 4.0)
g:addEdge(2, 3, 3.0)
g:addEdge(2, 6, 11.0)
g:addEdge(3, 6, 9.0)
g:addEdge(4, 5, 5.0)
g:addEdge(4, 6, 20.0)
g:addEdge(4, 7, 5.0)
g:addEdge(5, 2, 1.0)
g:addEdge(5, 6, 13.0)
g:addEdge(7, 5, 6.0)
g:addEdge(7, 2, 7.0)

local source = 0
dijkstra:run(g, source) -- 0 is the id of the source node in the path search
for k = 0,g:vertexCount()-1 do
    local v = g:vertexAt(k)
    if v ~= source and dijkstra:hasPathTo(v) then
        print('path from 0 to ' .. v .. ' ( cost: '  .. dijkstra:getPathLength(v) .. ' )')
        local path = dijkstra:getPathTo(v)
        for i = 0,path:size()-1 do
            print('# from ' .. path:get(i):from() .. ' to ' .. path:get(i):to() .. ' ( distance: ' .. path:get(i).weight .. ' )')
        end
    end
end










-- local g = require('luagraphs.data.graph').create(6)
-- g:addEdge(0, 5)
-- g:addEdge(2, 4)
-- g:addEdge(2, 3)
-- g:addEdge(1, 2)
-- g:addEdge(0, 1)
-- g:addEdge(3, 4)
-- g:addEdge(3, 5)
-- g:addEdge(0, 2)
-- local dfs = require('luagraphs.search.DepthFirstSearch').create()
-- local s = 0
-- dfs:run(g, s)

-- for k = 0, g:vertexCount()-1 do
--     local v = g:vertexAt(k)
--     if v ~= s and dfs:hasPathTo(v) then
--         print('has path to ' .. v)
--         local path = dfs:getPathTo(v)
--         local pathText = ''
--         while path:isEmpty() == false do
--             local x = path:pop()
--             if pathText == '' then
--                 pathText = pathText .. x
--             else
--                 pathText = pathText .. ' -> ' .. x
--             end
--         end
--         print(pathText)

--     end
-- end




-- local mst = require('luagraphs.mst.KruskalMST').create() 
-- g = require('luagraphs.data.graph').create(8) -- undirected graph with weighted edges
-- g:addEdge(0, 7, 0.16) -- 0.16 is the weight of the edge between 0 and 7
-- g:addEdge(2, 3, 0.17)
-- g:addEdge(1, 7, 0.19)
-- g:addEdge(0, 2, 0.26)
-- g:addEdge(5, 7, 0.28)
-- g:addEdge(1, 3, 0.29)
-- g:addEdge(1, 5, 0.32)
-- g:addEdge(2, 7, 0.34)
-- g:addEdge(4, 5, 0.35)
-- g:addEdge(1, 2, 0.36)
-- g:addEdge(4, 7, 0.37)
-- g:addEdge(0, 4, 0.38)
-- g:addEdge(6, 2, 0.4)
-- g:addEdge(3, 6, 0.52)
-- g:addEdge(6, 0, 0.58)
-- g:addEdge(6, 4, 0.93)

-- mst:run(g)

-- local path = mst.path

-- print(path:size()) -- return 7
-- for i=0,path:size()-1 do
--     local e = path:get(i)
--     print(e:from() .. ' -> ' .. e:to() .. ' (' .. e.weight .. ')')
-- end



