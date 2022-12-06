if !CPTBase then return end
-------------------------------------------------------------------------------------------------------------------
hook.Add("ScaleNPCDamage","cpt_FindHitGroup",function(ent,hitbox,dmginfo)
	if ent.CPTBase_NPC == true then
		ent.Hitbox = hitbox
		ent.tblDamageInfo = dmginfo
		if (ent.Hitbox == HITGROUP_HEAD) then
			dmginfo:ScaleDamage(2.0)
		end
	end
end)

hook.Add("ShouldCollide","CPTBase_NextbotNavShouldCollide_" .. math.Rand(1,99999999),function(ent1,ent2)
	if ent1:GetClass() == "cpt_ai_pathfinding" && ent2 == ent1:GetOwner() then
		return false
	end
	return true
end)

hook.Add("EntityEmitSound","CPTBase_DetectEntitySounds",function(data)
	if GetConVarNumber("ai_disabled") == 1 then
		return nil -- Don't alter sound data, proceed
	end
	if GetConVarNumber("cpt_npchearing_advanced") == 0 then
		return nil -- Don't alter sound data, proceed
	end
	if !IsValid(data.Entity) then return nil end
	for _,v in pairs(ents.GetAll()) do
		if IsValid(v) && v:IsNPC() && v != data.Entity && v.CPTBase_NPC && v.UseAdvancedHearing then
			local ent = data.Entity
			local vol = data.SoundLevel
			local pos = data.Pos
			local dvol = data.Volume
			v:AdvancedHearingCode(ent,vol,pos,dvol)
		end
	end
	return nil
end)

hook.Add("PlayerSpawnedNPC","cpt_SetOwnerNPC",function(ply,ent)
	if ent:IsNPC() && ent.CPTBase_NPC then
		if ent:GetOwner() == NULL then
			ent.NPC_Owner = ply
		end
	end
end)

hook.Add("OnNPCKilled","cpt_KilledNPC",function(victim,inflictor,killer)
	if killer.CPTBase_NPC then
		if killer != victim then
			killer:OnKilledEnemy(victim)
			killer:RemoveFromMemory(victim)
		end
	end
end)

hook.Add("PlayerDeath","cpt_KilledPlayer",function(victim,inflictor,killer)
	if killer.CPTBase_NPC then
		if killer != victim then
			killer:OnKilledEnemy(victim)
			killer:RemoveFromMemory(victim)
		end
	end
end)

hook.Add("PlayerSpawn","CPTBase_StopIgnition",function(ply)
	timer.Simple(0.02,function()
		if IsValid(ply) then
			if ply:IsOnFire() then
				ply:Extinguish()
			end
		end
	end)
end)

hook.Add("InitialPlayerSpawn","CPTBase_AddDefaultInitialPlayerValues",function(ply)
	ply:SetNWBool("CPTBase_IsPossessing",false)
end)

hook.Add("PlayerSpawn","CPTBase_AddDefaultPlayerValues",function(ply)
	ply.IsPossessing = false
--	ply.CPTBase_EF_RAD = 0
--	ply.CPTBase_ExperiencingEFDamage_RAD = false
--	ply.CPTBase_ExperiencingEFDamage_POI = false
--	ply.CPTBase_ExperiencingEFDamage_AFTERBURN = false
--	ply.CPTBase_ExperiencingEFDamage_FROST = false
--	ply.CPTBase_ExperiencingEFDamage_DE = false
--	ply.CPTBase_ExperiencingEFDamage_ELEC = false
	ply.CPTBase_Ragdoll = NULL
	ply.CPTBase_HasBeenRagdolled = false
	ply.LastRagdollMoveT = CurTime()
--	ply.CPTBase_TotalDrinks = 0
--	ply.CPTBase_TimeSinceLastPotionDrink = CurTime()
	ply.CPTBase_CurrentSoundtrack = nil
	ply.CPTBase_CurrentSoundtrackDir = nil
	ply.CPTBase_CurrentSoundtrackNPC = NULL
	ply.CPTBase_CurrentSoundtrackTime = 0
	ply.CPTBase_CurrentSoundtrackRestartTime = 0
	if ply:GetNWString("CPTBase_NPCFaction") == nil then
		ply:SetNWString("CPTBase_NPCFaction","FACTION_PLAYER")
	end
	ply:SetNWBool("CPTBase_IsPossessing",false)
	ply:SetNWString("CPTBase_PossessedNPCClass",nil)
	ply:SetNWEntity("CPTBase_PossessedNPC",NULL)
--[[	ply:SetNWInt("CPTBase_Magicka",100)
	ply:SetNWInt("CPTBase_MaxMagicka",100)
	ply:SetNWInt("CPTBase_NextMagickaT",5)
	ply:SetNWString("CPTBase_SpellConjuration","npc_cpt_parasite") ]]--
end)

hook.Add("Think","CPTBase_PlayerRagdolling",function()
	for _,v in ipairs(player.GetAll()) do
		if not IsValid(v) then return end
       	if not v.CPTBase_HasBeenRagdolled then return end
       	v:UpdateNPCFaction()
	--[[	if v:GetNWInt("CPTBase_Magicka") < v:GetNWInt("CPTBase_MaxMagicka") && CurTime() > v:GetNWInt("CPTBase_NextMagickaT") then
			v:SetNWInt("CPTBase_Magicka",v:GetNWInt("CPTBase_Magicka") +1)
			if v:GetNWInt("CPTBase_Magicka") > v:GetNWInt("CPTBase_MaxMagicka") then
				v:SetNWInt("CPTBase_Magicka",v:GetNWInt("CPTBase_MaxMagicka"))
			end
			v:SetNWInt("CPTBase_NextMagickaT",CurTime() +1)
		end ]]--
		--if v.CPTBase_HasBeenRagdolled then
			if IsValid(v:GetCPTBaseRagdoll()) then
				-- v:GodEnable()
				v:GodDisable()
				v:StripWeapons()
				v:Spectate(OBS_MODE_CHASE)
				v:SpectateEntity(v:GetCPTBaseRagdoll())
				v:SetMoveType(MOVETYPE_OBSERVER)
				v:SetPos(v:GetCPTBaseRagdoll():GetPos())
				if v:GetCPTBaseRagdoll():GetVelocity():Length() > 10 then
					v.LastRagdollMoveT = CurTime() +5
				end
				if v:KeyReleased(IN_FORWARD) then
					v.LastRagdollMoveT = v.LastRagdollMoveT -0.6
				end
				if CurTime() > v.LastRagdollMoveT then
					v:CPTBaseUnRagdoll()
					-- v:GodDisable()
				end
			end
		--end
	end
end)

hook.Add("PlayerDeath","CPTBase_PlayerRagdollingDeath",function(v,inflictor,attacker)
	if not v.CPTBase_HasBeenRagdolled then return end
   	if not IsValid(v:GetCPTBaseRagdoll()) then return end
	if IsValid(v:GetRagdollEntity()) then
		local ent = v:GetCPTBaseRagdoll()
		local rag = v:GetRagdollEntity()
		rag:SetPos(ent:GetPos())
		rag:SetAngles(ent:GetAngles())
		if ent:IsOnFire() then
			rag:Ignite(math.random(8,10),1)
		end
		rag:SetVelocity(ent:GetVelocity())
		for i = 1,128 do
			local bonephys = rag:GetPhysicsObjectNum(i)
			if IsValid(bonephys) then
				local bonepos,boneang = ent:GetBonePosition(rag:TranslatePhysBoneToBone(i))
				if bonepos then
					bonephys:SetPos(bonepos)
					bonephys:SetAngles(boneang)
				end
			end
		end
	end
	v:GetCPTBaseRagdoll():Remove()
end)