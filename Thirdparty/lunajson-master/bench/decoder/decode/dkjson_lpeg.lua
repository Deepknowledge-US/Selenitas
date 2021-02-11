local dk = require 'dkjson'
dk.use_lpeg()
return function(json, nv)
	local obj, msg = dk.decode(json, 1, nv)
	if obj == nil then
		error(msg)
	end
	return obj
end
