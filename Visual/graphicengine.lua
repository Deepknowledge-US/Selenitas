local agents = nil
local initialized = false
local coord_scale = 1 -- coordinate scaling for better visualization
local step_func = nil

local function init()
    -- TODO: read user settings
    -- TODO: setup UI
    initialized = true
    love.window.setTitle("Selenitas")
end

local function update(dt)
    -- TODO: update UI
end

local function set_agents(p_agents)
    agents = p_agents
end

local function set_step_function(f)
    step_func = f
end

local function set_viewport_size(w, h)
    love.window.setMode(w, h, {})
end

local function set_world_dimensions(x, y)
    set_viewport_size(x * coord_scale, y * coord_scale)
end

local function set_coordinate_scale(f)
    coord_scale = f
end

local function set_background_color(r, g, b)
    love.graphics.setBackgroundColor(r, g, b)
end

local function get_rgb_color(p_color_str)
    if p_color_str == "red" then
        return {1, 0, 0, 1}
    elseif p_color_str == "green" then
        return {0, 1, 0, 1}
    elseif p_color_str == "blue" then
        return {0, 0, 1, 1}
    elseif p_color_str == "green" then
        return {0, 1, 0, 1}
    elseif p_color_str == "yellow" then
        return {1, 1, 0, 1}
    elseif p_color_str == "cyan" then
        return {0, 1, 1, 1}
    elseif p_color_str == "magenta" then
        return {1, 0, 1, 1}
    elseif p_color_str == "black" then
        return {0, 0, 0, 1}
    else
        -- Default to white
        return {1, 1, 1, 1}
    end
end

function love.update(dt)
    if not initialized then
        do return end
    end
    update(dt)
    if step_func then
        step_func()
    end
end

function love.draw()
    if (not initialized) or (not agents) then
        do return end
    end

    for _, a in pairs(agents) do
        love.graphics.setColor(get_rgb_color(a.color))
        local x = a.xcor * coord_scale
        local y = a.ycor * coord_scale
        if a.shape == "triangle" then
            love.graphics.polygon("fill",
                x, y - 5,
                x + 5, y + 5,
                x - 5, y + 5
            )
        elseif a.shape == "rectangle" then
            love.graphics.polygon("fill",
                x - 5, y - 5,
                x + 5, y - 5,
                x + 5, y + 5,
                x - 5, y + 5
            )
        else
            -- Default to circle
            love.graphics.circle("fill", x, y, 5)
        end
    end
end

GraphicEngine = {
    init = init,
    set_agents = set_agents,
    set_world_dimensions = set_world_dimensions,
    set_background_color = set_background_color,
    set_coordinate_scale = set_coordinate_scale,
    set_step_function = set_step_function
}

return GraphicEngine