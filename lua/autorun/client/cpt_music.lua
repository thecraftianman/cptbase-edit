if not CPTBase then return end
if not CLIENT then return end
-------------------------------------------------------------------------------------------------------------------
local ENT_Meta = FindMetaTable("Entity")
local NPC_Meta = FindMetaTable("NPC")
local PLY_Meta = FindMetaTable("Player")
local WPN_Meta = FindMetaTable("Weapon")

function NPC_Meta:CreateThemeSong(track,len)
	for _,v in ipairs(player.GetAll()) do
		if GetConVarNumber("cpt_allowmusic") == 0 then return end
		if v.CPTBase_CurrentSoundtrack == nil then
			v.CPTBase_CurrentSoundtrack = CreateSound(v,track)
			v.CPTBase_CurrentSoundtrack:SetSoundLevel(0.2)
			v.CPTBase_CurrentSoundtrack:Play()
				// Fast forward kind of system
			-- v.CPTBase_CurrentSoundtrack:ChangePitch(250) // 250 max. Setting volume to zero then 0.2 should mute the intro fx
			-- timer.Simple(1,function() v.CPTBase_CurrentSoundtrack:ChangePitch(100) end)
			v.CPTBase_CurrentSoundtrackDir = track
			v.CPTBase_CurrentSoundtrackNPC = self
			v.CPTBase_CurrentSoundtrackTime = RealTime() +len
			v.CPTBase_CurrentSoundtrackRestartTime = len
		end
	end
end

function NPC_Meta:StopATrack(track,fade)
	for _,v in ipairs(player.GetAll()) do
		if v.CPTBase_CurrentSoundtrack != nil then
			if v.CPTBase_CurrentSoundtrackNPC == self && v.CPTBase_CurrentSoundtrackDir == track then
				if !fade then
					v.CPTBase_CurrentSoundtrack:Stop()
				else
					v.CPTBase_CurrentSoundtrack:FadeOut(fade)
				end
				v.CPTBase_CurrentSoundtrack = nil
				v.CPTBase_CurrentSoundtrackDir = nil
				v.CPTBase_CurrentSoundtrackNPC = NULL
				v.CPTBase_CurrentSoundtrackTime = nil
				v.CPTBase_CurrentSoundtrackRestartTime = nil
			end
		end
	end
end

function NPC_Meta:StopAllThemeSongs()
	for _,v in ipairs(player.GetAll()) do
		if v.CPTBase_CurrentSoundtrack != nil then
			v.CPTBase_CurrentSoundtrack:Stop()
			v.CPTBase_CurrentSoundtrack = nil
			v.CPTBase_CurrentSoundtrackDir = nil
			v.CPTBase_CurrentSoundtrackNPC = NULL
			v.CPTBase_CurrentSoundtrackTime = nil
			v.CPTBase_CurrentSoundtrackRestartTime = nil
		end
	end
end

hook.Add("Think","CPTBase_ThemeSystemThink",function()
	local locPly = LocalPlayer()

	if locPly.CPTBase_CurrentSoundtrack == nil then return end
	if not IsValid(locPly.CPTBase_CurrentSoundtrackNPC) then
		locPly.CPTBase_CurrentSoundtrack:FadeOut(0.5)
		locPly.CPTBase_CurrentSoundtrack = nil
		locPly.CPTBase_CurrentSoundtrackDir = nil
		locPly.CPTBase_CurrentSoundtrackTime = nil
		locPly.CPTBase_CurrentSoundtrackRestartTime = nil
	end

	if locPly.CPTBase_CurrentSoundtrack ~= nil and RealTime() > locPly.CPTBase_CurrentSoundtrackTime then
		locPly.CPTBase_CurrentSoundtrack:FadeOut(2)
		local prevNPC = locPly.CPTBase_CurrentSoundtrackNPC
		timer.Simple(2,function()
			if IsValid(locPly) then
				if IsValid(locPly.CPTBase_CurrentSoundtrackNPC) and prevNPC == locPly.CPTBase_CurrentSoundtrackNPC then
					locPly.CPTBase_CurrentSoundtrack:Stop()
					locPly.CPTBase_CurrentSoundtrack = CreateSound(locPly,locPly.CPTBase_CurrentSoundtrackDir)
					locPly.CPTBase_CurrentSoundtrack:SetSoundLevel(0.2)
					locPly.CPTBase_CurrentSoundtrack:Play()
				end
			end
		end)
		locPly.CPTBase_CurrentSoundtrackTime = RealTime() + locPly.CPTBase_CurrentSoundtrackRestartTime
	end
end)