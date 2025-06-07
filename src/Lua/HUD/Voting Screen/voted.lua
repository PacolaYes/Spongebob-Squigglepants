
-- handles the stuff after you've voted/time ended
-- yeyeyeyea

local voteScreen = Squigglepants.voteScreen
local HUD = Squigglepants.hud

local mapMarginHoriz = 8*FU
local mapMarginVert = 8*FU
local mapScale = FU/4
local mapRowCount = 6
local startX = ((160 * mapScale + mapMarginHoriz)*(mapRowCount-1) + 160 * mapScale) / 2

local function enterFunc(self, v, tics, p)
	local _, dupx = v.dupx()
	if tics == 0 then
		self.x = 320*dupx + 160*dupx
	end
	
	local rateThing = FixedDiv(tics, TICRATE/5)
	self.x = ease.linear(rateThing, 320*dupx + 160*dupx, 160*FU)
	
	if rateThing >= FU then return true end
end

local function thinkFunc(self, v, tics, plyr)
	if not voteScreen.isVoting
	or splitscreen and plyr == secondarydisplayplayer then return end
	
	local maps = voteScreen.selectedMaps
	
	local bg = Squigglepants.getPatch(v, "SQUIGGLEPANTS")
	local scrWidth, scrHeight = v.width(), v.height()
	v.drawStretched(
		0, 0,
		FixedDiv(scrWidth, bg.width), FixedDiv(scrHeight, bg.height),
		bg, V_NOSCALESTART|V_NOSCALEPATCH
	)
	
	local x = self.x - startX
	local y = mapMarginVert
	local pCount = 0
	for p in players.iterate do
		if not p.squigglepants then continue end
		
		local vote = p.squigglepants.votingScreen
		
		pCount = $+1
		
		if pCount % (mapRowCount+1) == 0 then
			x = self.x - startX
			y = $ + 100*mapScale + mapMarginVert
		end
		
		local patch
		if vote.hasSelected
		and maps[vote.selected] ~= nil then
			patch = Squigglepants.getPatch(v, G_BuildMapName(maps[vote.selected].map)+"P")
		else
			patch = Squigglepants.getPatch(v, "BLANKLVL")
		end
		v.drawScaled(x, y, mapScale, patch)
		
		x = $ + 160*mapScale + mapMarginHoriz
	end
end

local function exitFunc(self, v, tics)
	local _, dupx = v.dupx()
	local rateThing = FixedDiv(tics, TICRATE/5)
	self.x = ease.linear(rateThing, 160*FU, 320*dupx + 160*dupx)
	
	if rateThing >= FU then return true end
end

HUD.addState({
	name = "votingScreen-voteShowcase",
	enter = enterFunc,
	think = thinkFunc,
	exit = exitFunc,
	x = 320*FU
})