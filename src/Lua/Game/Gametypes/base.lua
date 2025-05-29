
-- base code for shtuff
-- like handling gamemodes!
-- for Squigglepants!
-- -pac

-- lil template for what the function can have:
-- name: self-explanatory, the gametype's name; default: "Unknown"
-- identifier: the name for the SGT_ constant; obligatory
-- description: self-explanatory, the gametype's description; default: none
-- exclusive: true or false, whether the maps has to have the gametype in its list, like normal gametypes; default: false

-- you can directly change this, go ahead!!
-- i still reccomend the function though :D
Squigglepants.gametypes = {}

function Squigglepants.addGametype(t)
	if t.identifier == nil then
		error("Please inform an identifier.")
		return
	end
	
	if t.name == nil then
		t.name = "Unknown"
	end
	
	if t.exclusive == nil then
		t.exclusive = true
	end
	
	local curIdentifier = #Squigglepants.gametypes + 1
	t.identifier = tostring($):upper()
	rawset(_G, "SGT_"+t.identifier, curIdentifier)
	
	Squigglepants.gametypes[curIdentifier] = Squigglepants.copy(t)
end

function Squigglepants.getGametypeDef(num)
	if tostring(num):lower() == "random" then
		num = P_RandomRange(1, #Squigglepants.gametypes)
	end
	num = tonumber($) or 1
	
	return Squigglepants.gametypes[num] or Squigglepants.gametypes[1]
end
/*
for i = 1, 10 do
	Squigglepants.addGametype({
		name = "Test "+i,
		identifier = "test"+i,
		description = "i'm testing",
		exclusive = false
	})
end*/