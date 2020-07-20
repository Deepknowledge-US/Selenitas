local agents = nil
local initialized = false

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

local function set_viewport_size(w, h)
    love.window.setMode(w, h, {})
end

local function set_background_color(r, g, b)
    love.graphics.setBackgroundColor(r, g, b)
end

function love.update(dt)
    if not initialized then
        do return end
    end
    update(dt)
end

function love.draw()
    if (not initialized) or (not agents) then
        do return end
    end

    for _, a in pairs(agents) do
        if a.color and #(a.color) == 4 then
            love.graphics.setColor(a.color[1], a.color[2], a.color[3], a.color[4])
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        local x = a.x
        local y = a.y
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
            love.graphics.circle("fill", a.x, a.y, 5)
        end
    end
end

GraphicEngine = {
    init = init,
    set_agents = set_agents,
    set_viewport_size = set_viewport_size,
    set_background_color = set_background_color
}

return GraphicEngine