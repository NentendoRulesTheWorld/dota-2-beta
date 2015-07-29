Log = {}

local isDebug = true

function Log:D(info)
	if isDebug then 
		print("DOPO_Debug: " .. info)
	end
end

function Log:A(info)
		print("DOPO_INFO: " .. info)
end