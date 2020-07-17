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
        love.graphics.setColor(1, 1, 1, 1) -- TODO: agent color
        love.graphics.circle("fill", a.x, a.y, 5)
    end
end

GraphicEngine = {
    init = init,
    set_agents = set_agents,
    set_viewport_size = set_viewport_size,
}

return GraphicEngine