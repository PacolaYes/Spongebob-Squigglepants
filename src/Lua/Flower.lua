/*
freeslot("SPR_IDLE", "SPR_TALK", "S_FLOWER_IDLE", "S_FLOWER_TALK", "MT_FLOWER", "sfx_splat", "sfx_rsplat", "sfx_oau", "sfx_serene", "sfx_visit", "sfx_boing", "sfx_trap", "sfx_oh", "sfx_nohelp", "sfx_cldh20", "sfx_life", "sfx_nshare")

states[S_FLOWER_IDLE] = {
	sprite = SPR_IDLE,
	frame = FF_ANIMATE|A,
	var1 = 5,
	var2 = 8,
	tics = -1,
	nextstate = S_FLOWER_IDLE
}

states[S_FLOWER_TALK] = {
	sprite = SPR_TALK,
	frame = FF_ANIMATE|A,
	var1 = 5,
	var2 = 4,
	tics = -1,
	nextstate = S_FLOWER_TALK
}

mobjinfo[MT_FLOWER] = {
	doomednum = 2110,
	spawnstate = S_FLOWER_IDLE,
	radius = 128*FU,
	height = 256*FU,
	flags = MF_NOGRAVITY
}

rawset(_G, "flowerpopup", true)

COM_AddCommand("flowerpopup", function(player)
	if flowerpopup == false
		flowerpopup = true
		CONS_Printf(player, "Flower's will now be revived after getting stomped")
	else
		flowerpopup = false
		CONS_Printf(player, "Flower's will only be revived after the map is reloaded")
	end
end, COM_ADMIN)

local function ReactToBadnik(flower)
	if flower and flower.valid
		for thing in mapthings.iterate
			if (not udmf and not ListOfFlowerReact[flower.spawnpoint.extrainfo]
			or udmf and not ListOfFlowerReact[flower.spawnpoint.args[0]])
				continue
			end
			if thing.tag <= 0 
				continue 
			end
			if thing.tag ~= flower.spawnpoint.tag 
				continue 
			end
			if thing.mobj
			and thing.mobj.valid
			and thing.mobj.health > 0
				continue
			end
			if not udmf
				S_StopSoundByID(flower, ListOfFlowerTalk[flower.spawnpoint.extrainfo])
				S_StartSound(flower, ListOfFlowerReact[flower.spawnpoint.extrainfo])
			else
				S_StopSoundByID(flower, ListOfFlowerTalk[flower.spawnpoint.args[0]])
				S_StartSound(flower, ListOfFlowerReact[flower.spawnpoint.args[0]])
			end
		end
	end
end

rawset(_G, "ListOfFlowerTalk", {
	[1] = sfx_oau,
	[2] = sfx_serene,
	[3] = sfx_visit,
	[4] = sfx_trap,
	[5] = sfx_boing,
	[6] = sfx_oh,
	[7] = sfx_cldh20,
	[8] = sfx_life,
	[9] = sfx_nshare
})

rawset(_G, "ListOfFlowerReact", {
	[2] = sfx_oh,
	[4] = sfx_nohelp,
	[8] = sfx_nshare
})

rawset(_G, "PlayFlowerTalk", function(flower)
	if not flower.talked
		flower.state = S_FLOWER_TALK
		if not udmf
			if flower.spawnpoint.extrainfo == nil
			or flower.spawnpoint.extrainfo < 1
				S_StartSound(flower, sfx_oau)
				flower.talked = true
				return
			end
			local talk = ListOfFlowerTalk[flower.spawnpoint.extrainfo]
			S_StartSound(flower, talk)
			ReactToBadnik(flower)
		else
			local arg = flower.spawnpoint.args[0]
			if arg == nil
			or arg < 1
				S_StartSound(flower, sfx_oau)
				flower.talked = true
				return
			end
			local talk = ListOfFlowerTalk[arg]
			S_StartSound(flower, talk)
			ReactToBadnik(flower)
		end
		flower.talked = true
	end
end)

addHook("MobjThinker", function(flower)
	if flower and flower.valid
		flower.scale = FRACUNIT/6
		if flower.talked == nil
			flower.talked = false
		end
		if P_LookForPlayers(flower, 256*FRACUNIT, true)
			local player = flower.target.player
			PlayFlowerTalk(flower)
			if flower.state ~= S_FLOWER_TALK
			and (not udmf and S_SoundPlaying(flower, ListOfFlowerTalk[flower.spawnpoint.extrainfo])
			or udmf and S_SoundPlaying(flower, ListOfFlowerTalk[flower.spawnpoint.args[0]]))
				flower.state = S_FLOWER_TALK
			elseif flower.state ~= S_FLOWER_IDLE
			and not S_OriginPlaying(flower)
				flower.state = S_FLOWER_IDLE
			end
			if player.mo.x < flower.x + flower.radius and player.mo.x > flower.x - flower.radius
			and player.mo.y < flower.y + flower.radius and player.mo.y > flower.y - flower.radius
			and (player.mo.eflags & MFE_JUSTHITFLOOR)
			and not (flower.flags2 & MF2_DONTDRAW)
				flower.stomped = true
				flower.spriteyscale = $ - flower.spriteyscale/3
				flower.spritexscale = $ + flower.spritexscale/3
				flower.radius = $ + 16*FRACUNIT/3
				flower.height = $ - 16*FRACUNIT/3
				S_StopSound(flower)
				S_StartSound(flower, sfx_splat)
				flower.state = S_FLOWER_IDLE
				if flower.spriteyscale < FRACUNIT/6
				and flower.spritexscale > FRACUNIT/6
					if flowerpopup == true
						flower.flags2 = $|MF2_DONTDRAW
					else
						S_StopSoundByID(flower, sfx_splat)
						S_StartSound(player.mo, sfx_splat)
						P_RemoveMobj(flower)
						return
					end
				end
			elseif (player.mo.x > flower.x + flower.radius or player.mo.x < flower.x - flower.radius
			or player.mo.y > flower.y + flower.radius or player.mo.y < flower.y - flower.radius)
			and flowerpopup == true
				if flower.stomped == true
					flower.stomped = false
					S_StartSound(flower, sfx_rsplat)
					flower.flags2 = $ & ~MF2_DONTDRAW
				end
				if flower.spriteyscale < FRACUNIT
					flower.spriteyscale = $ + FRACUNIT/3
					flower.height = $ + 16*FRACUNIT/3
				end
				if flower.spritexscale > FRACUNIT
					flower.spritexscale = $ - FRACUNIT/3
					flower.radius = $ - 16*FRACUNIT/3
				end
				if flower.spriteyscale > FRACUNIT
					flower.spriteyscale = FRACUNIT
					flower.height = 256*FRACUNIT/6
				end
				if flower.spritexscale < FRACUNIT
					flower.spritexscale = FRACUNIT
					flower.radius = 128*FRACUNIT/6
				end
			end
		else
			if flower.state ~= S_FLOWER_IDLE
				flower.state = S_FLOWER_IDLE
				if S_OriginPlaying(flower)
					S_StopSound(flower)
				end
			end
		end
		if not P_LookForPlayers(flower, 256*FRACUNIT, true)
			flower.talked = false
		end
	end
end, MT_FLOWER)

addHook("MobjDeath", function(target)
	for thing in mapthings.iterate
		if thing.mobj ~= target
			continue
		end
		if thing.tag <= 0 
			continue 
		end
		for flower in mobjs.iterate()
			if not (flower or (flower and flower.valid))
				continue
			end
			if flower.type ~= MT_FLOWER
				continue
			end
			if thing.tag ~= flower.spawnpoint.tag 
				continue 
			end
			if (not udmf and ListOfFlowerReact[flower.spawnpoint.extrainfo] == nil
			or udmf and ListOfFlowerReact[flower.spawnpoint.args[0]] == nil)
				continue
			end
			flower.state = S_FLOWER_TALK
			if not udmf
				S_StopSoundByID(flower, ListOfFlowerTalk[flower.spawnpoint.extrainfo])
				S_StartSound(flower, ListOfFlowerReact[flower.spawnpoint.extrainfo])
			else
				S_StopSoundByID(flower, ListOfFlowerTalk[flower.spawnpoint.args[0]])
				S_StartSound(flower, ListOfFlowerReact[flower.spawnpoint.args[0]])
			end
		end
	end
end)
*/