
-- handles voting
-- apparently it's like mk8
-- idk, i cant even play that :P
-- -pac

-- return val:
-- init values
-- for the global variable

local voteTime = 10*TICRATE

local globalVars = {
	voteScreen = {
		isVoting = false,
		selectedMaps = {},
		tics = 0
	}
}

local playerVars = {
	votingScreen = {
		selected = 1, -- might be a bit confusing, this is which map the player has selected
		hasSelected = false, -- while this is whether the player has selected it or not
		
		-- last tic stuff
		lastsidemove = 0,
		lastbuttons = 0
	}
}

Squigglepants = $.copyTo(globalVars, $)
local voteScreen = Squigglepants.voteScreen
local HUD = Squigglepants.hud

local function isSpecialStage(map)
	if map == nil then map = gamemap end
	
	return (map >= sstage_start and map <= sstage_end)
	or (map >= smpstage_start and map <= smpstage_end)
end

-- gets a random map and gametype
-- self is a table, in which the stuff will be stored
-- doMap is whether you want maps or not (true by default)
-- doGametype is whether you want gametypes or not (true by default)
-- mapBlacklist is a function that gets the map number as an argument, returning true means that the map is blacklisted.
-- gtBlacklist is a function that gets the gametype number as an argument, returning true means that the gametype is blacklisted.
function Squigglepants.getRandomMap(self, doMap, doGametype, mapBlacklist, gtBlacklist)
	if self == nil then self = {} end
	if doMap == nil then doMap = true end
	if doGametype == nil then doGametype = true end
	
	if doMap then
		self.map = 0
		local i = 0
		while not mapheaderinfo[self.map]
		or (type(mapBlacklist) == "function" and mapBlacklist(self.map)) do
			self.map = P_RandomRange(1, 1035)
		end
	end
	
	if doGametype then
		self.gametype = P_RandomRange(1, #Squigglepants.gametypes)
		local i = 0
		while Squigglepants.getGametypeDef(self.gametype).exclusive -- add map mechanism stuff l8r
		or (type(gtBlacklist) == "function" and gtBlacklist(self.gametype)) do
			self.gametype = P_RandomRange(1, #Squigglepants.gametypes)
			
			i = $+1
			if i > 9999 then error("Timeout! No gametypes were found, did you screw up something?") break end
		end
	end
	
	return self
end

-- starts a vote, preferred as only setting
-- voteScreen.isVoting to true is not all that a vote wants.
-- mapBlacklist and gtBlacklist are the same as above soo
-- mapBlacklist is a function that gets the map number as an argument, returning true means that the map is blacklisted.
-- gtBlacklist is a function that gets the gametype number as an argument, returning true means that the gametype is blacklisted.
-- these blacklists DO NOT apply to the random selection, that's always random

-- reminder to self: update this if changing the top one
-- otherwise just go read the top one :P
function Squigglepants.startVote(mapBlacklist, gtBlacklist)
	if not Squigglepants.inMode() then return end
	
	local mapList = {}
	for i = 1, 3 do
		local function trueBlacklist(map)
			return (type(mapBlacklist) == "function" and mapBlacklist(map))
			or isSpecialStage(map)
		end
		mapList[i] = Squigglepants.getRandomMap($, true, true, trueBlacklist, gtBlacklist)
	end
	
	voteScreen.selectedMaps = mapList
	voteScreen.isVoting = true
	
	for mo in mobjs.iterate() do -- votes shouldn't have stuff bothering us >:(
		mo.flags = MF_NOTHINK
		mo.state = S_INVISIBLE
	end
	
	HUD.changeState("votingScreen-voting")
end

-- handle player controls !
addHook("PreThinkFrame", function()
	for p in players.iterate do
		if not (p.realmo and p.realmo.valid)
		or not Squigglepants.inMode()
		or not voteScreen.isVoting then continue end
		
		local sp = p.squigglepants
		local vote = sp.votingScreen
		
		if not vote.hasSelected then
			if ((p.cmd.sidemove >= 25) and not (vote.lastsidemove >= 25))
			or ((p.cmd.sidemove <= -25) and not (vote.lastsidemove <= -25))
				local add = clamp(p.cmd.sidemove)
				
				vote.selected = $+add
				if vote.selected < 1 then
					vote.selected = 4
				elseif vote.selected > 4 then
					vote.selected = 1
				end
			end
			
			if (p.cmd.buttons & BT_JUMP)
			and not (vote.lastbuttons & BT_JUMP) then
				S_StartSound(nil, sfx_spvsel, p)
				vote.hasSelected = true
				HUD.changeState("votingScreen-voteShowcase")
			end
		else
			if (p.cmd.buttons & BT_SPIN)
			and not (vote.lastbuttons & BT_SPIN) then
				S_StartSound(nil, sfx_thok, p)
				vote.hasSelected = false
				HUD.changeState("votingScreen-voting")
			end
		end
		
		vote.lastbuttons = p.cmd.buttons
		vote.lastsidemove = p.cmd.sidemove
		
		p.cmd.forwardmove = 0
		p.cmd.sidemove = 0
		p.cmd.buttons = 0
	end
	
	voteScreen.tics = $+1
end)

return {
	global = globalVars,
	player = playerVars
}