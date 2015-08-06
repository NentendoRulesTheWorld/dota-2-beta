Log = {}

TYPE_BASE = 0
TYPE_VECTOR = 1

local isDebug = true

function Log:D(info,type)
	if isDebug then 
		if type == 0 or type == nil
			print("DOPO_Debug: " .. info)
		else if type == 1
			print("DOPO_Debug_Vector: " .. info.x .. " " .. info.y .. " " .. info.z)
		end
	end
end

function Log:A(info)
		print("DOPO_INFO: " .. info)
end