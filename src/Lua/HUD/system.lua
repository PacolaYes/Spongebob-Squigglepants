
-- hud anim state system
-- used for well, states
-- not necessarily animating
-- -pac

local curState = "base" -- i'd rather have you change it through the function :D
local nextState = nil -- state we'll be changing to
local statePhase = "enter" -- enter or exit, think always happens
local stateTics = 0 -- current tic value spent in the state's enter/exit parts
local stateThinkTics = 0 -- current tic value spent in the state's think part

local function emptyFunction()
	return true
end

local baseState = {
	name = "base",
	enter = emptyFunction,
	think = emptyFunction,
	exit = emptyFunction,
}

Squigglepants.hud.states = {
	game = {
		base = Squigglepants.copy(baseState)
	}
}

-- table format:
-- name: the state's name, case-sensitive so Test != test;
-- enter: function handling the enter stuff, return true will confirm you've entered, so you can do an entry anim
-- 	pls init all your variables when tics = 0 in enter if you're gonna do an animation :pray:
-- think: function handling the thinking, returning a string will try to change to that state
-- 	think will ALWAYS run, even while enter or exit are doing so
-- exit: function handling the exit stuff, return true will confirm you've exited, so you can do an leave anim or somethin
--	function format for 'em: function(v, self, tics, ...) "..." standing for whatever other arguments the hud type may have, "game" will give you both a player and a camera!
-- type: the hud type, example being "game", also defaults to "game"
-- [variable]: sets a variable that'll you be able to access through the self argument in the function
-- WARNING: these will all be ran through a HUD hook !! dont do bad stuff or itll probably desynch :P
function Squigglepants.hud.addState(t)
	if t == nil
	or t.name == nil then return end
	
	local baseCopy = Squigglepants.copy(baseState)
	if t.type == nil then
		t.type = "game"
	end
	local type = t.type
	t = Squigglepants.copyTo($, baseCopy)
	t.type = nil
	
	if not Squigglepants.hud.states[type] then
		baseCopy.type = type
		Squigglepants.hud.states[type] = {
			base = baseCopy
		}
	end
	Squigglepants.hud.states[type][t.name] = t
end

-- changes the state to newState, if available
function Squigglepants.hud.changeState(newState, force)
	if newState == nil then return end
	
	local foundState = false
	for key in pairs(Squigglepants.hud.states) do
		if Squigglepants.hud.states[key][newState] then
			foundState = true
			break 
		end
	end
	if not foundState then return end
	
	if newState == curState then
		force = true
	end
	
	stateTics = 0
	
	if force then
		curState = newState
		nextState = nil
		statePhase = "enter"
		stateThinkTics = 0
	else
		nextState = newState
		statePhase = "exit"
	end
end

-- idk why make this a function :P
-- returns the current state and the next one, if any
-- TODO: maybe figure out a better name to indicate nextState is here too
function Squigglepants.hud.getCurrentState()
	return curState, nextState
end

-- should only return "enter", "exit" and nil
-- nil is when the state isn't entering nor exiting
function Squigglepants.hud.getCurrentPhase()
	return statePhase
end

local function triggerState(hudtype, v, ...)
	if gametype ~= GT_SQUIGGLEPANTS
	or not Squigglepants
	or not Squigglepants.hud.states[hudtype]
	or not Squigglepants.hud.states[hudtype][curState] then return end
	
	local state = Squigglepants.hud.states[hudtype][curState]
	
	if type(state[statePhase]) == "function"
	and state[statePhase](state, v, stateTics, ...) then
		if statePhase == "exit"
			Squigglepants.hud.changeState(nextState, true)
			state = Squigglepants.hud.states[hudtype][curState]
		else
			statePhase = nil
		end
	end
	
	local thinkResult = state:think(v, stateThinkTics, ...)
	if type(thinkResult) == "string" then
		Squigglepants.hud.changeState(thinkResult)
	end
	
	stateTics = $+1
	stateThinkTics = $+1
end

addHook("HUD", function(v, ...)
	triggerState("game", v, ...)
end)