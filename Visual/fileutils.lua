local fileutils = {}

-- Checks if file or directory exists
function fileutils.exists(path)
    local ok, err, code = os.rename(path, path)
    if not ok then
       if code == 13 then
          -- Permission denied, but it exists
          return true
       end
    end
    return ok, err
end

-- Copy file. Fails if paths don't exist or access is denied
function fileutils.copy(srcpath, dstpath)
    local infile = io.open(srcpath, "r")
    local content = infile:read("*a")
    infile:close()
    local outfile = io.open(dstpath, "w")
    outfile:write(content)
    outfile:close()
end

-- Copy to LOVE2D's Save Directory.
-- Source path must be accesible to LOVE2D, meaning the
-- path must be a child of project's root directory
function fileutils.copy_to_save_dir(src, dst)
    local info = love.filesystem.getInfo(src)
    local contents, size = love.filesystem.read(src, info.size)
    local ok, err = love.filesystem.write(dst, contents, size)
end

-- Opens file in system's default text editor
function fileutils.open_in_editor(path)
    local os_str = love.system.getOS()
    if os_str == "Windows" then
        os.execute("start " .. path)
    elseif os_str == "Linux" then
        os.execute("xdg-open " .. path)
    elseif os_str == "OS X" then
        os.execute("open " .. path)
    end
end

-- Gets the filename of an specified path
-- path/to/my/file.lua -> file.lua
function fileutils.get_filename_from_path(path)
    local split = {}
    local sep = "/"
    for str in string.gmatch(path, "([^"..sep.."]+)") do
        table.insert(split, str)
    end
    return split[#split] -- last item is filename
end

return fileutils