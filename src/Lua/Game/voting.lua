
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
		selecting = false,
		selectedPlayer = 0,
		selectedMaps = {},
		tics = voteTime
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
	
	local gtdef
	if doGametype then
		self.gametype = P_RandomRange(1, #Squigglepants.gametypes)
		gtdef = Squigglepants.getGametypeDef(self.gametype)
		local i = 0
		while gtdef.exclusive -- add map mechanism stuff l8r
		or (type(gtBlacklist) == "function" and gtBlacklist(self.gametype)) do
			self.gametype = P_RandomRange(1, #Squigglepants.gametypes)
			
			i = $+1
			if i > 9999 then error("Timeout! No gametypes were found, did you screw up something?") break end
		end
	end
	
	if doMap then
		self.map = 0
		local i = 0
		
		while not mapheaderinfo[self.map]
		or (type(mapBlacklist) == "function" and mapBlacklist(self.map))
		or gtdef and not (mapheaderinfo[self.map].typeoflevel & gtdef.typeoflevel) do
			self.map = P_RandomRange(1, 1035)
			
			i = $+1
			if i > 9999 then error("Timeout! No maps were found, did you screw up something?") break end
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
	local foundMap = {}
	for i = 1, 3 do
		local function trueBlacklist(map)
			return (type(mapBlacklist) == "function" and mapBlacklist(map))
			or isSpecialStage(map)
			or foundMap[map]
		end
		mapList[i] = Squigglepants.getRandomMap($, true, true, trueBlacklist, gtBlacklist)
		foundMap[mapList[i].map] = true
	end
	
	voteScreen.tics = voteTime
	voteScreen.selectedMaps = mapList
	voteScreen.isVoting = true
	voteScreen.selected = false
	
	for mo in mobjs.iterate() do -- votes shouldn't have stuff bothering us >:(
		mo.flags = MF_NOTHINK
		mo.state = S_INVISIBLE
	end
	
	HUD.changeState("votingScreen-voting")
end

local function checkHUD(p, name)
	local curState, nextState = HUD.getCurrentState()
	
	return curState ~= name
	and nextState ~= name
	--and (splitscreen and p ~= secondarydisplayplayer or not splitscreen)
end

-- handle player controls !
addHook("PreThinkFrame", function()
	if not Squigglepants.inMode()
	or not voteScreen.isVoting then
		return
	end
	
	local playerList = {}
	local selectedPlayers = {}
	for p in players.iterate do
		if not (p.realmo and p.realmo.valid) then continue end
		
		playerList[#playerList+1] = p
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
			end
			
			if checkHUD(p, "votingScreen-voting") then
				HUD.changeState("votingScreen-voting")
			end
		else
			
			if (p.cmd.buttons & BT_SPIN)
			and not (vote.lastbuttons & BT_SPIN) then
				S_StartSound(nil, sfx_thok, p)
				vote.hasSelected = false
			end
			
			if checkHUD(p, "votingScreen-voteShowcase") then
				HUD.changeState("votingScreen-voteShowcase")
			end
			
			selectedPlayers[#selectedPlayers+1] = p
		end
		
		vote.lastbuttons = p.cmd.buttons
		vote.lastsidemove = p.cmd.sidemove
		
		p.cmd.forwardmove = 0
		p.cmd.sidemove = 0
		p.cmd.buttons = 0
	end
	
	voteScreen.tics = $-1
	
	if not voteScreen.selected then
		if #selectedPlayers >= #playerList then
			voteScreen.selected = true
			print("selected !")
		end
	else
		local rp = Squigglepants.getRandomPlayer(function(p)
			return not (p and p.valid)
			or not (p.realmo and p.realmo.valid)
		end)
		local voteNum = rp.squigglepants.votingScreen.selected
		local maps = voteScreen.selectedMaps
		local map = maps[voteNum] or Squigglepants.getRandomMap()
		
		Squigglepants.gametype = map.gametype
		G_SetCustomExitVars(map.map, 2)
		G_ExitLevel()
	end
end)

return {
	global = globalVars,
	player = playerVars
}