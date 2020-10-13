local ResourceManager = require("Thirdparty.cargo.cargo").init("Resources")
local View = require "Visual.view"
local math = require "math"

local Draw = {}

local coord_scale = 16 -- 16 px = 1 unit
--local grid_cell_size = 64
--local grid_size = 1024 * 16

function Draw.init()
    love.graphics.setNewFont(7) -- Default font for labels
end

function Draw.draw_agents_family(family)
    for _, a in pairs(family.agents) do

        -- Handle agent visibility
        if a.visible then

            -- Handle agent color
            love.graphics.setColor(a.color)

            local x = a:xcor() * coord_scale
            local y = - a:ycor() * coord_scale -- Invert Y-axis to have its positive side point up

            -- Handle agent shape, scale and rotation
            -- Base resources are 128x128 px, using 16x16 px as base scale (0.125 factor)
            local rot = -( a.heading - (math.pi/2) )
            local scl = 0.125 * a.scale
            local shift = 64 -- pixels to shift to center the figure
            local shape_img = ResourceManager.images.circle -- Default to circle
            if a.shape == "triangle" then
                shape_img = ResourceManager.images.triangle
            elseif a.shape == "triangle_2" then
                shape_img = ResourceManager.images.triangle_hole
            elseif a.shape == "square" then
                shape_img = ResourceManager.images.rectangle
            elseif a.shape == "house" then
                shape_img = ResourceManager.images.house
            elseif a.shape == "person" then
                shape_img = ResourceManager.images.person
            elseif a.shape == "tree" then
                shape_img = ResourceManager.images.tree
            end

            love.graphics.draw(shape_img, x, y, rot, scl, scl, shift, shift)

            -- Handle agent label
            love.graphics.setColor(a.label_color)
            love.graphics.printf(a.label, x - 45, y + 10, 100, 'center')
        end
    end
end

function Draw.draw_links_family(family)
    for _, l in pairs(family.agents) do
        -- Handle link visibility
        if l.visible then
            -- Handle link color
            love.graphics.setColor(l.color)
            -- Link thickness
            love.graphics.setLineWidth(l.thickness)
            -- Agent coordinate is scaled and shifted in its x coordinate
            -- to account for UI column
            local sx = l.source:xcor() * coord_scale
            local sy = - l.source:ycor() * coord_scale -- Invert Y-axis to have its positive side point up
            local tx = l.target:xcor() * coord_scale
            local ty = - l.target:ycor() * coord_scale -- Invert Y-axis to have its positive side point up
            -- Draw line
            love.graphics.line(sx, sy, tx, ty)
            -- Draw label
            love.graphics.setColor(l.label_color)
            local dirx = tx - sx
            local diry = ty - sy
            local midx = sx + dirx * 0.5
            local midy = sy + diry * 0.5
            love.graphics.printf(l.label, midx - 45, midy, 100, 'center')
        end
    end
end

---------
function Draw.draw_cells_family(family)
    for _, c in pairs(family.agents) do
        if c.visible then
            -- Handle cell color
            love.graphics.setColor(c.color)

            local x = c:xcor() * coord_scale
            local y = - c:ycor() * coord_scale -- Invert Y-axis to have its positive side point up
            if c.shape == "square" then
                
                love.graphics.rectangle('fill', x - (0.5 * coord_scale), y + (0.5 * coord_scale), 1*coord_scale, 1*coord_scale )

            elseif c.shape == "triangle" then
                -- Each triangle is 3 lines
                local top = {x, y - (0.5 * coord_scale)}
                local left = {x - (0.5 * coord_scale), y + (0.5 * coord_scale)}
                local right = {x + (0.5 * coord_scale), y + (0.5 * coord_scale)}
                love.graphics.line(top[1], top[2], left[1], left[2]) -- Left line
                love.graphics.line(top[1], top[2], right[1], right[2]) -- Right line
                love.graphics.line(left[1], left[2], right[1], right[2]) -- Bottom line
            elseif c.shape == "circle" then
                -- Circle of radius=0.5
                love.graphics.circle("line", x, y, 0.5 * coord_scale)
            else
                -- Shape is a generic polygon
                love.graphics.polygon("line", c.shape)
            end

            -- Draw label
            love.graphics.setColor(c.label_color)
            love.graphics.printf(c.label, x - 45, y, 100, 'center')
        end
    end
end

-- function Draw.draw_cells_family(family)
--     for _, c in pairs(family.agents) do
--         if c.visible then
--             -- Handle cell color
--             love.graphics.setColor(c.color)

--             local x = c:xcor() * coord_scale
--             local y = - c:ycor() * coord_scale -- Invert Y-axis to have its positive side point up
--             if c.shape == "square" then
--                 -- Squares are assumed to be 1x1
--                 -- Each square is 4 lines
--                 local top_left = {x - (0.5 * coord_scale), y - (0.5 * coord_scale)}
--                 local top_right = {x + (0.5 * coord_scale), y - (0.5 * coord_scale)}
--                 local bottom_left = {x - (0.5 * coord_scale), y + (0.5 * coord_scale)}
--                 local bottom_right = {x + (0.5 * coord_scale), y + (0.5 * coord_scale)}
--                 love.graphics.line(top_left[1], top_left[2], top_right[1], top_right[2]) -- Top line
--                 love.graphics.line(top_left[1], top_left[2], bottom_left[1], bottom_left[2]) -- Left line
--                 love.graphics.line(bottom_left[1], bottom_left[2], bottom_right[1], bottom_right[2]) -- Bottom line
--                 love.graphics.line(top_right[1], top_right[2], bottom_right[1], bottom_right[2]) -- Right line
--             elseif c.shape == "triangle" then
--                 -- Each triangle is 3 lines
--                 local top = {x, y - (0.5 * coord_scale)}
--                 local left = {x - (0.5 * coord_scale), y + (0.5 * coord_scale)}
--                 local right = {x + (0.5 * coord_scale), y + (0.5 * coord_scale)}
--                 love.graphics.line(top[1], top[2], left[1], left[2]) -- Left line
--                 love.graphics.line(top[1], top[2], right[1], right[2]) -- Right line
--                 love.graphics.line(left[1], left[2], right[1], right[2]) -- Bottom line
--             elseif c.shape == "circle" then
--                 -- Circle of radius=0.5
--                 love.graphics.circle("line", x, y, 0.5 * coord_scale)
--             else
--                 -- Shape is a generic polygon
--                 love.graphics.polygon("line", c.shape)
--             end

--             -- Draw label
--             love.graphics.setColor(c.label_color)
--             love.graphics.printf(c.label, x - 45, y, 100, 'center')
--         end
--     end
-- end

local function draw_grid(grid_size, cell_size, alpha, line_width)
    local lines = grid_size / cell_size
    local x = - ((lines / 2) * cell_size)
    local y = (lines / 2) * cell_size
    local alpha_scaled = alpha * 0.3
    if line_width < 0.9 then
        love.graphics.setLineStyle("rough")
    else
        love.graphics.setLineStyle("smooth")
    end
    local previous_line_width = love.graphics.getLineWidth()
    love.graphics.setLineWidth(line_width)
    -- Horizontal lines
    for i = 0, lines do
        love.graphics.setColor(0.3, 0.3, 0.3, alpha_scaled)
        if y == 0 then
            love.graphics.setColor(1, 0, 0, 0.5)
        end
        love.graphics.line(-grid_size / 2, y, grid_size / 2, y)
        y = y - cell_size
    end
    -- Vertical lines
    for i = 0, lines do
        love.graphics.setColor(0.3, 0.3, 0.3, alpha_scaled)
        if x == 0 then
            love.graphics.setColor(0, 1,  0, 0.5)
        end
        love.graphics.line(x, grid_size / 2, x, -grid_size / 2)
        x = x + cell_size
    end
    -- Revert line config
    love.graphics.setLineWidth(previous_line_width)
    love.graphics.setLineStyle("smooth")
end

function Draw.draw_scalable_grid(base)
    local grid_size = 1
    while grid_size * base <= 20000 do -- 20000 -> max grid size
        grid_size = grid_size * base
    end
    local cell_size = 1
    while cell_size * base <= 100 do
        cell_size = cell_size * base
    end
    local z = Observer:get_zoom()
    local current_k = math.min(math.floor(z), 4)
    local next_k = math.min(math.ceil(z), 5)
    local rem = z - math.floor(z)
    local curr_alpha = next_k >= 5 and 1 or 1 - rem
    local next_alpha = 1 - (curr_alpha + 0.3)
    draw_grid(grid_size, cell_size / math.pow(base, current_k), curr_alpha, 1 / z)
    if next_k < 5 then
        draw_grid(grid_size, cell_size / math.pow(base, next_k), next_alpha, 1 / z)
    end
end

return Draw