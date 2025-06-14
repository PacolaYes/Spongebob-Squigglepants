
-- handles the hud while you're voting
-- so the maps, bg and that kind of stuff :P
-- -pac

local voteScreen = Squigglepants.voteScreen
local HUD = Squigglepants.hud

-- imma be real, most of the time i don't know
-- the difference between padding and margin
-- including in css......
local mapMarginHoriz = 8*FU
local mapMarginTop = 8*FU
local mapScale = tofixed("0.4")

local function enterFunc(self, v, tics, p)
	if tics == 0 then
		self.x = -160*FU
	end
	
	local rateThing = FixedDiv(tics, TICRATE/5)
	self.x = ease.outsine(rateThing, -160*FU, 160*FU)
	
	if rateThing >= FU then return true end
end

local function thinkFunc(self, v, tics, p)
	if not p.squigglepants
	or not voteScreen.isVoting
	or splitscreen and p == secondarysplitscreen then return end
	
	local vote = p.squigglepants.votingScreen
	local vote2p
	local maps = voteScreen.selectedMaps
	if splitscreen and secondarysplitscreen
	and secondarysplitscreen.squigglepants then
		vote2p = secondarysplitscreen.squigglepants.votingScreen
	end
	
	local bg = Squigglepants.getPatch(v, "SQUIGGLEPANTS")
	local scrWidth, scrHeight = v.width(), v.height()
	v.drawStretched(
		0, 0,
		FixedDiv(scrWidth, bg.width), FixedDiv(scrHeight, bg.height),
		bg, V_NOSCALESTART|V_NOSCALEPATCH
	)
	
	local x = self.x - ((160 * mapScale + mapMarginHoriz)*3 + 160 * mapScale) / 2
	local y = 32*FU
	local flags = V_SNAPTOTOP
	for i = 1, 4 do
		local map = maps[i]
		local patch
		
		if map ~= nil then
			local gametype = Squigglepants.getGametypeDef(map.gametype)
			patch = Squigglepants.getPatch(v, G_BuildMapName(map.map)+"P")
			
			v.drawScaled(x, y, mapScale, patch, flags)
			v.drawString(x, y + 100*mapScale, gametype.name, flags, "small-thin-fixed")
			v.drawString(x, y + 100*mapScale + 4*FU, G_BuildMapTitle(map.map), flags, "small-thin-fixed")
		else
			patch = Squigglepants.getPatch(v, "BLANKLVL")
			v.drawScaled(x, y, mapScale, patch, flags)
		end
		
		if i == vote.selected
		or vote2p and i == vote2p.selected then
			local curVote = i == vote.selected and vote or vote2p
			local patchName = curVote.hasSelected and "SLCT2LVL" or "SLCT1LVL"
			v.drawScaled(x, y, mapScale, Squigglepants.getPatch(v, patchName), flags)
		end
		
		x = $ + patch.width * mapScale + mapMarginHoriz
	end
	--v.drawString(160*FU, 100*FU, p.squigglepants.votingScreen.selected, 0, "fixed-center")
	v.drawString(160*FU, 108*FU, "secs left: "+voteScreen.tics/TICRATE, 0, "fixed-center")
end

local function exitFunc(self, v, tics)
	local rateThing = FixedDiv(tics, TICRATE/5)
	self.x = ease.insine(rateThing, 160*FU, -160*FU)
	
	if rateThing >= FU then return true end
end

HUD.addState({
	name = "votingScreen-voting",
	enter = enterFunc,
	think = thinkFunc,
	exit = exitFunc,
	x = -160*FU
})