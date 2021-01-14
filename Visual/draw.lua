------------------
-- Class for handling drawing
-- @module
-- draw

local Draw = {}

local ResourceManager = require("Thirdparty.cargo.cargo").init("Resources")
local math            = require "math"
local coord_scale     = 10 -- 10 px = 1 unit

------------------
-- Get coordinate scale factor
-- @function get_coord_scale
-- @return coord_scale Returns coordinate scale of the drawing system. 1 unit = `coord_scale` pixels
function Draw.get_coord_scale()
    return coord_scale
end

------------------
-- Init draw module
-- @function init
function Draw.init()
    love.graphics.setNewFont(7) -- Default font for labels
end

------------------
-- Draws agent family
-- @function draw_agents_family
-- @param family agent family to be drawn.
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
            local   rot       = -( a.heading - (math.pi/2) )
            local   scl       = 10/128 * a.scale
            local   shift     = 64 -- pixels to shift to center the figure
            local   shape_img = ResourceManager.images.triangle -- Default to triangle
            if      a.shape == "circle" then
                    shape_img = ResourceManager.images.circle
            elseif  a.shape == "triangle_2" then
                    shape_img = ResourceManager.images.triangle_hole
            elseif  a.shape == "square" then
                    shape_img = ResourceManager.images.rectangle
            elseif  a.shape == "house" then
                    shape_img = ResourceManager.images.house
            elseif  a.shape == "person" then
                    shape_img = ResourceManager.images.person
            elseif  a.shape == "tree" then
                    shape_img = ResourceManager.images.tree
            end

            love.graphics.draw(shape_img, x, y, rot, scl, scl, shift, shift)

            -- Handle agent label
            love.graphics.setColor(a.label_color)
            love.graphics.printf(a.label, x - 45, y + 10, 100, 'center')
        end
    end
end

------------------
-- Draws link family
-- @function draw_links_family
-- @param family link family to be drawn.
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
            local sx =  l.source:xcor() * coord_scale
            local sy = -l.source:ycor() * coord_scale -- Invert Y-axis to have its positive side point up
            local tx =  l.target:xcor() * coord_scale
            local ty = -l.target:ycor() * coord_scale -- Invert Y-axis to have its positive side point up
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

------------------
-- Draws cells family
-- @function draw_cells_family
-- @param family cell family to be drawn.
function Draw.draw_cells_family(family)
    for _, c in pairs(family.agents) do
        if c.visible then
            -- Handle cell color
            love.graphics.setColor(c.color)
            local x         = c:xcor() * coord_scale
            local y         = - c:ycor() * coord_scale -- Invert Y-axis to have its positive side point up
            if    c.shape == "square" then
                love.graphics.rectangle('fill', x - (0.5 * coord_scale), y - (0.5 * coord_scale), 1*coord_scale, 1*coord_scale )
            elseif c.shape == "triangle" then
                -- Each triangle is 3 lines
                local top   = {x, y - (0.5 * coord_scale)}
                local left  = {x - (0.5 * coord_scale), y + (0.5 * coord_scale)}
                local right = {x + (0.5 * coord_scale), y + (0.5 * coord_scale)}
                love.graphics.line(top[1], top[2], left[1], left[2]) -- Left line
                love.graphics.line(top[1], top[2], right[1], right[2]) -- Right line
                love.graphics.line(left[1], left[2], right[1], right[2]) -- Bottom line
            elseif c.shape == "circle" then
                local fill = c.fill == true and 'fill' or 'line'
                love.graphics.circle(fill, x, y, c.radius * coord_scale)
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

return Draw