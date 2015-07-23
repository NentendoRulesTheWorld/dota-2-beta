Log = {}

local isDebug = true

function Log:D(info)
	if isDebug then 
		print(info)
	end
end

function Log:A(info)
		print(info)
end