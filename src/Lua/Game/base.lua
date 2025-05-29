
-- handles the base functionality
-- maybe the name isn't that self-explanatory
-- not sure what else to call it though :P
-- -pac

local ogVars = Squigglepants.require("Game/voting.lua")

addHook("MapChange", function()
	Squigglepants = $.copyTo(ogVars.global, $) -- reset variables that we should :D
	Squigglepants.hud.changeState("base", true)
end)

addHook("MapLoad", function()
	Squigglepants.startVote()
end)

addHook("PlayerSpawn", function(p)
	p.squigglepants = Squigglepants.copy(ogVars.player)
end)

addHook("PlayerThink", function(p)
	if p.squigglepants == nil then
		p.squigglepants = Squigglepants.copy(ogVars.player)
	end
end)