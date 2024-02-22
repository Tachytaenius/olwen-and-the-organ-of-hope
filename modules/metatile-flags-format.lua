-- TODO

local metatileFlagsFormat = {}

function metatileFlagsFormat.decodeMetatileFlags(byte)
	local ret = {}
	-- TODO
	ret.solid = byte == 1
	return ret
end

function metatileFlagsFormat.encodeMetatileFlags(metatile)
	local ret = 0
	if metatile.solid then
		ret = ret + 1
	end
	return ret
end

return metatileFlagsFormat
