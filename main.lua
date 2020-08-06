if not arg[2] then
    print("Usage: love . [path to source code file of the simulation]")
    love.event.quit()
else
    dofile(arg[2])
end