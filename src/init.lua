
-- initialize !!
-- for what i call
-- codename Spongebob Squigglepants
-- -pac

freeslot("TOL_SQUIGGLEPANTS")

G_AddGametype({ -- get us our gametype
    name = "SRB2: Epic Minigames",
    identifier = "squigglepants",
    typeoflevel = TOL_COOP|TOL_SQUIGGLEPANTS,
    rules = GTR_EMERALDTOKENS|GTR_EMERALDHUNT|GTR_SPAWNENEMIES,
    intermissiontype = int_none,
    headercolor = 103,
    description = "temp"
})

rawset(_G, "Squigglepants", { -- and our variable! below is also variable stuff
	sync = {},
	hud = {}
})

addHook("NetVars", function(net)
	Squigglepants.sync = net($)
end)

local function newindexFunc(self, key, val)
	if type(val) ~= "function" then -- i think this is the only Big thing that i'd want to use like this?
		self.sync[key] = val
	else
		rawset(self, key, val)
	end
end

local mt = { -- pls make it so Squigglepants = Squigglepants.sync if its a variable that can be synched :D
	__index = function(self, key)
		--if type(self[key]) ~= "function" then
		if self.sync[key] ~= nil then
			return self.sync[key]
		end
	end,
	__newindex = newindexFunc,
	__usedindex = newIndexFunc
}

setmetatable(Squigglepants, mt) -- note for self: maybe make a reverse of this for sync so sync absolutely CAN'T get functions if we modify it directly? might be a bit unnecessary, whoever does that is STUPID (hopefully not me :D)
registerMetatable(mt)

-- actual dofiling
-- until it becomes Squigglepants.dofiling, atleast
dofile("functions.lua")

Squigglepants.dofile("Freeslots/voting.lua")

Squigglepants.dofile("Game/Gametypes/base.lua") -- base of the seperate gametypes
Squigglepants.dofile("Game/base.lua") -- base of the whole thing
Squigglepants.dofile("Game/voting.lua")

-- Squigglepants.dofile("Game/Gametypes/Evil Leafy/definition.lua") -- TODO: make this one
Squigglepants.dofile("Game/Gametypes/Co-op/base.lua")

Squigglepants.dofile("HUD/system.lua")
Squigglepants.dofile("HUD/discordlink.lua")

Squigglepants.dofile("HUD/Voting Screen/voting.lua")
Squigglepants.dofile("HUD/Voting Screen/voted.lua")
