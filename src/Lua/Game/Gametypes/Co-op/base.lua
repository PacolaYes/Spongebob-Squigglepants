
-- who needs to play coop
-- when you can play coop
-- -pac

Squigglepants.addGametype({
	name = "Co-op",
	identifier = "COOP",
	description = "coop :D",
	exclusive = false,
	typeoflevel = TOL_COOP
})

local voteScreen = Squigglepants.voteScreen

addHook("ThinkFrame", function()
	for p in players.iterate do
		if not Squigglepants.inMode(SGT_COOP)
		or not (p.mo and p.mo.valid) then continue end
		
		if P_MobjTouchingSectorSpecial(p.mo, 4, 2)
		and not ((p.pflags & PF_FINISHED) or p.exiting)
		and not voteScreen.isVoting then
			P_DoPlayerFinish(p)
		elseif (p.exiting or (p.pflags & PF_FINISHED))
		and voteScreen.isVoting then
			p.exiting = 0
			p.pflags = $ & ~PF_FINISHED
		end
	end
	
	if G_EnoughPlayersFinished() then
		Squigglepants.startVote()
	end
end)