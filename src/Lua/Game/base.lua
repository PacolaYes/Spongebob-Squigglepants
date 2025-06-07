
-- handles the base functionality
-- maybe the name isn't that self-explanatory
-- not sure what else to call it though :P
-- -pac

Squigglepants.gametype = 1
local ogVars = Squigglepants.require("Game/voting.lua")

addHook("MapChange", function()
	Squigglepants = $.copyTo(ogVars.global, $) -- reset variables that we should :D
	Squigglepants.hud.changeState("base", true)
	
	if gametype ~= GT_SQUIGGLEPANTS then
		Squigglepants.gametype = 1 -- reset it back :D
	end
	
	for p in players.iterate do
		p.squigglepants = Squigglepants.copy(ogVars.player)
	end
end)

/*addHook("MapLoad", function()
	Squigglepants.startVote()
end)*/

/*addHook("PlayerSpawn", function(p)
	p.squigglepants = Squigglepants.copy(ogVars.player)
end)*/

addHook("PlayerThink", function(p)
	if p.squigglepants == nil then
		p.squigglepants = Squigglepants.copy(ogVars.player)
	end
end)

COM_AddCommand("startvote", function()
	Squigglepants.startVote()
end, COM_ADMIN)