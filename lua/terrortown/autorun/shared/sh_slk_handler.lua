if engine.ActiveGamemode() ~= "terrortown" then return end

if SERVER then
    AddCSLuaFile()

    util.AddNetworkString("ttt2_slk_epop")
    util.AddNetworkString("ttt2_slk_epop_defeat")
    util.AddNetworkString("ttt2_slk_network_wep")
end

local plymeta = FindMetaTable("Player")

if not plymeta then
    Error("[TTT2 STALKER] FAILED TO FIND PLAYER TABLE")
end

local CLOAK_FULL = 4
local CLOAK_PARTIAL = 2
local CLOAK_NONE = 1

if CLIENT then
    --print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1 Load Stalker Handler")
    -- HiddenWallhack not for stalker

    -- DoHiddenVision (hook("RenderScreenspaceEffects")) in sh_hd_handler
    
    -- net.Receive( "Flay", function( len )

    --     if LocalPlayer():Team() == TEAM_HUMAN then
        
    --         DisorientTime = CurTime() + 20
    --         ViewWobble = 7.5
    --         MotionBlur = 0.9
    --         Sharpen = 4.5
    --         ColorModify[ "$pp_colour_mulg" ]   =  3.5
    --         ColorModify[ "$pp_colour_mulr" ]   =  4.5
    --         ColorModify[ "$pp_colour_addr" ]   =  0.2
    --         ColorModify[ "$pp_colour_addg" ]   =  0.1
    --         ColorModify[ "$pp_colour_colour" ] = -3.0
        
    --     else
        
    --         //ViewWobble = 2.5
    --         Sharpen = 2.5
    --         MotionBlur = 0.5
    --         ColorModify[ "$pp_colour_colour" ] = -1.2
        
    --     end
    
    -- end )
end


function plymeta:GetMana()
    return self:GetNWInt("ttt2_stalker_mana")
end

function plymeta:GetMaxMana()
    return self:GetNWInt("ttt2_stalker_mana_max")
end

if SERVER then

    -- using plymeta:SetCloakMode

    -- using plymeta:GetloakMode

    -- using plymeta:UpdateCloaking

    -- using hook "HiddenCloakThink"

    -- TODO: Has to be reimplemente. Any way round this?
    local function BetterWeaponStrip(ply, exclude_class)
        if not ply or not IsValid(ply) or not ply:IsPlayer() then return end

        local weps = ply:GetWeapons()
        for i = 1, #weps do
          local wep = weps[i]
          local wep_class = wep:GetClass()
          if (wep.Kind == WEAPON_EQUIP or wep.Kind == WEAPON_EQUIP2 or wep.Kind == WEAPON_HEAVY or wep.Kind == WEAPON_PISTOL or wep.Kind == WEAPON_NADE) and not exclude_class[wep_class] then
            ply:StripWeapon(wep_class)
          else
            wep.WorldModel = ""
            net.Start("ttt2_slk_network_wep")
                net.WriteEntity(wep)
                net.WriteString(wep.WorldModel)
            net.Broadcast()
          end
        end
    end

    function plymeta:ActivateStalkerStalker()
        if self:GetSubRole() ~= ROLE_STALKER then return end

        local exclude_tbl = {}
        exclude_tbl["weapon_ttt_slk_tele"] = true
        exclude_tbl["weapon_ttt_slk_claws"] = true
        exclude_tbl["weapon_ttt_slk_scream"] = true
        BetterWeaponStrip(self, exclude_tbl)

        local mana_max = GetConVar("ttt2_slk_maximal_mana"):GetInt()

        self:SetNWBool("ttt2_hd_stalker_mode", true)
        self:SetNWInt("ttt2_stalker_mana_max", mana_max)
        self:SetNWInt("ttt2_stalker_mana", mana_max)
        self:UpdateCloaking()

        -- events.Trigger(EVENT_HDN_ACTIVATE, self)
    end

    function plymeta:DeactivateStalkerStalker()
        self:SetNWBool("ttt2_hd_stalker_mode", false)
        self:SetNWInt("ttt2_stalker_mana", 0)
        self:UpdateCloaking()
        -- DeactivateCloaking(self)
    end

    function plymeta:SetStalkerMode_slk(bool)
        if bool then
            self:ActivateStalkerStalker()
            net.Start("ttt2_slk_epop")
            net.WriteString(self:Nick())
            -- net.SendOmit(self)
            net.Broadcast()
        else
            self:DeactivateStalkerStalker()
        end
    end

    function plymeta:AddMana(mana)
        if self:GetSubRole() ~= ROLE_STALKER then return end
        self:SetNWInt("ttt2_stalker_mana", math.Clamp(self:GetNWInt("ttt2_stalker_mana", false) + mana, 0, self:GetMaxMana()))
    end

    function plymeta:SetRegenerateMode(bool)
        if bool then
            --print("CloakMode:", self:GetCloakMode(), CLOAK_FULL)
            if self:GetCloakMode() ~= CLOAK_FULL or self:GetMana() >= self:GetMaxMana() then
                --print("Cloak is not fully charged: do not aktivate Recharge Moded")
                return
            end
            --print("Aktivate Cloak Recharge.")
            self:SetCloakMode(CLOAK_PARTIAL, 1, 0.4)
            self:SetNWBool("ttt2_slk_regenerate_mode", true)
        else
            --print("Deaktivate Cloak Recharge")
            self:UpdateCloaking(true, 1, 0.4)
            self:SetNWBool("ttt2_slk_regenerate_mode", false)
        end
    end

    hook.Add("Think", "StalkerCloakThink", function()
        local plys = player.GetAll()
        for i = 1, #plys do
            local ply = plys[i]
            if ply:GetSubRole() ~= ROLE_STALKER or ply:GetCloakMode() == CLOAK_NONE then continue end

            if ply:GetNWBool("ttt2_slk_regenerate_mode", false) then
                if ply:GetMana() < ply:GetMaxMana() then
                    if (ply.mana_time or 0) < CurTime() then
                        ply:AddMana(2)
                        ply.mana_time = CurTime() + 0.2
                    end

                    return
                else
                    ply:SetRegenerateMode(false)
                end
            end
            ply:UpdateCloaking()
        end
    end)

    hook.Add("EntityTakeDamage", "TTT2StalkerTakeDamage", function(tgt, dmg)
        if not IsValid(tgt) or not tgt:IsPlayer() or not tgt:Alive() or tgt:IsSpec() then return end
        if tgt:GetSubRole() ~= ROLE_STALKER then return end
        if not tgt:GetNWBool("ttt2_hd_stalker_mode", false) then return end
        tgt:SetRegenerateMode(false)
        tgt:UpdateCloaking(true)
    end)


    -- using ResetHiddenRole from Hidden and their hooks,
    -- probably need to implement for own NetVars

    hook.Add("PlayerCanPickupWeapon", "NoStalkerPickups", function(ply, wep)
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then return end
        if ply:GetSubRole() ~= ROLE_STALKER or not ply:GetNWBool("ttt2_hd_stalker_mode", false) then return end

        return (wep:GetClass() == "weapon_ttt_slk_claws" or wep:GetClass() == "weapon_ttt_slk_tele" or wep:GetClass() == "weapon_ttt_slk_scream")
    end)

    hook.Add("TTTPlayerSpeedModifier", "StalkerSpeedBonus", function(ply, _, _, speedMod)
        if ply:GetSubRole() ~= ROLE_STALKER or not ply:GetNWBool("ttt2_hd_stalker_mode") then return end
        
        -- if ply:HasEquipmentItem("item_ttt_slk_mobility") then
        -- --if ply:GetNWBool("ttt2_stalker_mobility") then
        --     speedMod[1] = speedMod[1] * 1.6
        -- else
        --     speedMod[1] = speedMod[1] * 1.3
        -- end
        speedMod[1] = speedMod[1] * 1.3
    end)

     hook.Add("TTT2StaminaRegen", "StalkerStaminaMod", function(ply, stamMod)
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then return end
        if ply:GetSubRole() ~= ROLE_STALKER or not ply:GetNWBool("ttt2_hd_stalker_mode") then return end

        stamMod[1] = stamMod[1] * 1.6
    end)

    -- using hook("ScalePlayerDamage") of hidden

    hook.Add("DoPlayerDeath", "TTT2StalkerDied", function(ply, attacker, dmgInfo)
        if ply:GetSubRole() ~= ROLE_STALKER or not ply:GetNWBool("ttt2_hd_stalker_mode", false) then return end

        ply:SetStalkerMode_slk(false)
        -- events.Trigger(EVENT_HDN_DEFEAT, ply, attacker, dmgInfo)
        net.Start("ttt2_slk_epop_defeat")
        net.WriteString(ply:Nick())
        net.Broadcast()
    end)

    -- using hook("PlayerSPawn") of hidden

end

if CLIENT then
    hook.Add("TTT2PreventAccessShop", "PreventShopOutsideStalkerMode", function()
        local ply = LocalPlayer()
        if ply:GetSubRole() ~= ROLE_STALKER or not ply:Alive() or ply:IsSpec() then return end

        return ply:GetNWBool("ttt2_hd_stalker_mode", false) == false
    end)


    net.Receive("ttt2_slk_epop", function()
        EPOP:AddMessage({
            text = LANG.GetParamTranslation("slk_epop_title", {nick = net.ReadString()}),
            color = HIDDEN.ltcolor
            },
            LANG.GetTranslation("slk_epop_desc")
        )
    end)

    net.Receive("ttt2_slk_epop_defeat", function()
        EPOP:AddMessage({
            text = LANG.GetParamTranslation("slk_epop_defeat_title", {nick = net.ReadString()}),
            color = HIDDEN.ltcolor
            },
            LANG.GetTranslation("slk_epop_defeat_desc")
        )
    end)

    net.Receive("ttt2_slk_network_wep", function()
                net.ReadEntity().WorldModel = net.ReadString()
    end)
end