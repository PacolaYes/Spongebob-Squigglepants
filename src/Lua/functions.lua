
-- functions to be used on more of a 
-- global level, stuff like:
-- 	- getting a table copy
--	- copying from one table to another
-- 	- insert more as we do more
-- -pac :D

-- simply gets a copy of a table
-- it also is recursive, meaning that
-- if the table has more tables, it'll
-- copy those seperatly too
function Squigglepants.copy(t)
	local tcopy = {}
	for key, val in pairs(t) do
		if type(val) == "table" then
			tcopy[key] = Squigglepants.copy(val)
		else
			tcopy[key] = val
		end
	end
	return tcopy
end

-- copies from the table "from" to the table "to"
-- prioritizes values from the "from" table
-- that means that "from" overwrites what both have in common.
-- calls copy (above) if a value is a table.
function Squigglepants.copyTo(from, to)
	for key, val in pairs(from) do
		if type(val) == "table" then
			if to[key] then
				to[key] = Squigglepants.copyTo(val, $)
			else
				to[key] = Squigglepants.copy(val)
			end
		else
			to[key] = val
		end
	end
	return to
end

-- pretty much require, i think?
-- i don't know, would require be closer to dofile or loadfile?
local loadedFiles = {}
function Squigglepants.dofile(file)
	if not loadedFiles[file] then
		loadedFiles[file] = dofile(file)
	end
	return loadedFiles[file]
end

Squigglepants.require = Squigglepants.dofile -- i think this makes it an alias

-- checks if you're inside codename spongebob squigglepants
-- pretty self-explanatory, i think :D
-- if gametype is specified it also checks if you're
-- in that specific gametype
function Squigglepants.inMode(gt)
	return gametype == GT_SQUIGGLEPANTS
	and (gt ~= nil and Squigglepants.gametype == gt or gt == nil)
end

-- gets a list with all players that exist
-- blacklist should be a function
-- said function gets a player as an argument
-- returning true makes so said player is ignored
-- #playerlist = # of players that exist :P
function Squigglepants.getPlayerList(blacklist)
	local pList = {}
	for p in players.iterate do
		if type(blacklist) == "function"
		and blacklist(p) then continue end
		
		pList[#pList+1] = p
	end
	return pList
end

function Squigglepants.getRandomPlayer(blacklist)
	local rp = P_RandomRange(0, 31)
	while not (players[rp] and players[rp].valid)
	or (type(blacklist) == "function" and blacklist(players[rp])) do
		rp = P_RandomRange(0, 31)
	end
	return players[rp]
end

-- stores patch in table
-- other than that
-- its just cachePatch :P
local patchTable = {}
function Squigglepants.getPatch(v, name)
	if not (patchTable[name] and patchTable[name].valid) then
		patchTable[name] = v.cachePatch(name)
	end
	return patchTable[name]
end

-- below ill only do MATH related stuff
-- i know, its pretty scary

-- make this global, because its just clamp :P
-- why make it specific to the mod variable
-- its not like clamp has different results
rawset(_G, "clamp", function(num, minimum, maximum)
	if type(num) ~= "number" then
		error("Please provide a number.", 2)
		return num
	end
	
	if minimum == nil then minimum = -1 end
	if maximum == nil then maximum = 1 end
	
	return min(max(num, minimum), maximum)
end)