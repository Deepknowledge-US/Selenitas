if not arg[2] then
    print("Usage: love . [path to source code file of the simulation]")
    love.event.quit()
else
    -- Run main file without the .lua extension
    local path, _ = string.gsub(arg[2], ".lua", "")
    require(path)
end