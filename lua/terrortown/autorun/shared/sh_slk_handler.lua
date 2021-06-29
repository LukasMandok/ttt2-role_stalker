if engine.ActiveGamemode() ~= "terrortown" then return end

if SERVER then
    AddCSLuaFile()

    util.AddNetworkString("ttt2_slk_epop")
    util.AddNetworkString("ttt2_slk_epop_defeat")
    util.AddNetworkString("ttt2_slk_network_wep")

    resource.AddFile("materials/hud/hvision.vmt")
    -- resource.AddFile("materials/hud/hvision_dx6.vmt")

    resource.AddFile("materials/hud/water_effect.vmt")
    resource.AddFile("materials/hud/water_effect_dx6.vmt")

    resource.AddFile("materials/hud/vignette.vmt")
    resource.AddFile("materials/hud/vignette_blue.vmt")

    resource.AddFile("materials/vgui/ttt/hud/hud_icon_slk_cloak")
    resource.AddFile("materials/vgui/ttt/hud/hud_icon_slk_cloak_fading")
end

local plymeta = FindMetaTable("Player")

if not plymeta then
    Error("[TTT2 STALKER] FAILED TO FIND PLAYER TABLE")
end

local CLOAK_FULL = 4
local CLOAK_PARTIAL = 2
local CLOAK_NONE = 1

if CLIENT then
    ----------------------------------------------------------------------
    -- Credits got to: https://github.com/ZacharyHinds/ttt2-role_hidden --
    ----------------------------------------------------------------------

    local water_effect = Material("hud/water_effect.vmt", "noclamp smooth")
    local vignette_mat = Material("hud/vignette.vmt")
    local vignette_blue_mat = Material("hud/vignette_blue.vmt")
    local blood_mat = Material("hud/hvision.vmt")

    local function StalkerHUDOverlay()
        local client = LocalPlayer()

        if client:GetBaseRole() ~= ROLE_STALKER then return end

        if client:GetNWBool("ttt2_slk_stalker_mode", false) then
            render.UpdateScreenEffectTexture()
            render.SetMaterial( water_effect )
            render.DrawScreenQuad()
        end
    end

    hook.Add("PostDrawOpaqueRenderables", "TTT2Stalker:PlayerVision", StalkerHUDOverlay)

    ColorMod = {}
    ColorMod[ "$pp_colour_addr" ] = 0.0
    ColorMod[ "$pp_colour_addg" ] = 0.03
    ColorMod[ "$pp_colour_addb" ] = 0.09
    ColorMod[ "$pp_colour_brightness" ] = 0
    ColorMod[ "$pp_colour_contrast" ] = 0.9
    ColorMod[ "$pp_colour_colour" ] = 1
    ColorMod[ "$pp_colour_mulr" ] = 1  
    ColorMod[ "$pp_colour_mulg" ] = 1 
    ColorMod[ "$pp_colour_mulb" ] = 1 

    local pattern = Material("pp/texturize/pattern1.png")

    local function DoStalkerVision()
        local client = LocalPlayer()
        if not client:Alive() or client:IsSpec() then return end
        if client:GetBaseRole() ~= ROLE_STALKER or not client:GetNWBool("ttt2_slk_stalker_mode") then return end

        DrawColorModify(ColorMod)
        local modifier = client:GetNWInt("ttt2_slk_cloak_strength") / 100 or 1
        ColorMod[ "$pp_colour_addb" ] = .09 * modifier
        ColorMod[ "$pp_colour_addg" ] = .03 * modifier
	    ColorMod[ "$pp_colour_contrast" ] = 0.9
	    ColorMod[ "$pp_colour_colour" ] = 1 - 0.2 * modifier
        --ColorMod[ "$pp_colour_brightness"] = - 0.3 * (1-modifier)
        if modifier != 1 then
            ColorMod[ "$pp_colour_addr"] = 0.05 * (1-modifier)
            DrawSharpen( 1 + 0.2 * (1-modifier), 1 + 0.2 * (1-modifier) )
        end
        

        cam.Start3D(EyePos(), EyeAngles())

        render.SuppressEngineLighting(true)
        render.SetColorModulation(1, 1, 1)
        render.SuppressEngineLighting(false)

        cam.End3D()

        if not vignette_mat then return end

        local modifier = math.Clamp(client:GetNWInt("ttt2_slk_cloak_strength") / 100 or 1, 0.1, 1)
        render.UpdateScreenEffectTexture()

        vignette_mat:SetFloat("$alpha", modifier)
        vignette_mat:SetFloat("$envmap", 0)
        vignette_mat:SetFloat("$envmaptint", 0)
        vignette_mat:SetInt("$ignorez", 1)
        
        render.SetMaterial( vignette_mat )
        render.DrawScreenQuad()

        blood_mat:SetFloat("$alpha", 1 - modifier)
        blood_mat:SetFloat("$envmap", 0)
        blood_mat:SetFloat("$envmaptint", 0)
        blood_mat:SetInt("$ignorez", 1)

        render.SetMaterial( blood_mat )
        render.DrawScreenQuad()
    end

    hook.Add("RenderScreenspaceEffects", "TTT2Stalker:VisionRender", DoStalkerVision)

    ----------------------------------------------------------------------
    ----------------------------------------------------------------------
    ----------------------------------------------------------------------
end


function plymeta:GetMana()
    return self:GetNWInt("ttt2_stalker_mana")
end

function plymeta:GetMaxMana()
    return self:GetNWInt("ttt2_stalker_mana_max")
end

function plymeta:GetManaCost()
    return self.ManaCost
end

function plymeta:SetManaCost(mana_cost)
    self.ManaCost = mana_cost and math.Round(mana_cost) or nil
end

if SERVER then

    ----------------------------------------------------------------------
    -- Credits got to: https://github.com/ZacharyHinds/ttt2-role_hidden --
    ----------------------------------------------------------------------

    local function ActivateCloaking(ply)
        ply.stalkerColor = ply:GetColor()
        ply.stalkerRenderMode = ply:GetRenderMode()
        ply.stalkerMaterial = ply:GetMaterial()

        -- local ply_color = table.Copy(ply.stalkerColor)
        -- ply_color.a = math.Round(ply_color.a * 0.05)
        local ply_color = Color(255, 255, 255, 50)

        ply:SetColor(ply_color)
        ply:SetMaterial("sprites/heatwave")
        ply:SetRenderMode(RENDERMODE_TRANSALPHA)
    end

    local max_pct = 0.6
    local health_threshold = 25
    local min_alpha = 0.1
    local max_alpha = 0.7

    function plymeta:SetStalkerCloakStrength(strength)
        self:SetNWInt("ttt2_slk_cloak_strength", strength)
        if strength < 100 and not self.stalkerCloakRecharging then
            self.stalkerCloakRecharging = true
            RECHARGE_STATUS:SetRecharge(self, "ttt2_slk_invisbility", true)
        elseif strength == 100 and self.stalkerCloakRecharging then
            self.stalkerCloakRecharging = false
            RECHARGE_STATUS:SetRecharge(self, "ttt2_slk_invisbility", false)
        end
    end

    function plymeta:SetStalkerCloakMode(cloak, delta, offset, override)
        delta  = delta or 1
        offset = offset or 0

        local clr = self:GetColor()
        if not self.stalkerColor then self.stalkerColor = clr end
        local render = self:GetRenderMode()
        if not self.stalkerRenderMode then self.stalkerRenderMode = render end
        local mat = self:GetMaterial()
        if not self.stalkerMaterial then self.stalkerMaterial = mat end

        if cloak == CLOAK_FULL then
            mat = "sprites/heatwave"
            clr = Color(255, 255, 255, 3)
            render = RENDERMODE_TRANSALPHA
            self:SetStalkerCloakStrength(100)

        elseif cloak == CLOAK_PARTIAL then
            --local pct = math.Clamp(self:Health() / (self:GetMaxHealth() - 25), 0, 1)

            local pct = math.Clamp((self:Health() / (self:GetMaxHealth() - health_threshold) - 1) * -max_pct, 0, 1)
            local alpha = ((override and offset) or (pct + offset)) * delta
            mat = self.stalkerMaterial
            clr = self.stalkerColor

            alpha = math.Clamp(alpha, min_alpha, max_alpha)
            clr.a = alpha * 255
            self:SetStalkerCloakStrength((1 - alpha) * 100)

        else
            clr = self.stalkerColor
            render = self.stalkerRenderMode
            mat = self.stalkerMaterial
            self.stalkerCloakTimeout = nil
            self:SetStalkerCloakStrength(0)
        end
        self:SetColor(clr)
        self:SetRenderMode(render)
        self:SetMaterial(mat)
        self.stalkerCloakMode = cloak
    end

    function plymeta:GetStalkerCloakMode()
        return self.stalkerCloakMode
    end

    function plymeta:UpdateStalkerCloaking(timeout, delay, alphaOffset, override)
        if not IsValid(self) or not self:IsPlayer() then return end
        if GetRoundState() ~= ROUND_ACTIVE or self:GetBaseRole() ~= ROLE_STALKER then self:SetStalkerCloakMode(CLOAK_NONE) return end  
        if self:IsSpec() or not self:Alive() then self:SetStalkerCloakMode(CLOAK_NONE) return end
        if not self:GetNWBool("ttt2_slk_stalker_mode", false) then self:SetStalkerCloakMode(CLOAK_NONE) return end

        if timeout then
            self.stalkerCloakDelay = delay or (8 * (self:Health() / self:GetMaxHealth()))
            self.stalkerCloakTimeout = CurTime() + self.stalkerCloakDelay
            self.stalkerAlphaOffset = alphaOffset or 0
        elseif self.stalkerCloakTimeout and self.stalkerCloakTimeout > CurTime() then
            timeout = true
        end

        if timeout then
            local start = self.stalkerCloakTimeout - self.stalkerCloakDelay
            local delta = (1 - (CurTime() - start) / self.stalkerCloakDelay)

            self:SetStalkerCloakMode(CLOAK_PARTIAL, delta, self.stalkerAlphaOffset, override)
        else
            self:SetStalkerCloakMode(CLOAK_FULL)
        end
    end

    local function DeactivateCloaking(ply)
        ply:SetColor(ply.stalkerColor)
        ply:SetRenderMode(ply.stalkerRenderMode)
        ply:SetMaterial(ply.stalkerMaterial)
    end

    ----------------------------------------------------------------------
    ----------------------------------------------------------------------
    ----------------------------------------------------------------------

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

    function plymeta:ActivateStalkerMode()
        if self:GetSubRole() ~= ROLE_STALKER then return end

        local exclude_tbl = {}
        exclude_tbl["weapon_ttt_slk_tele"] = true
        exclude_tbl["weapon_ttt_slk_claws"] = true
        exclude_tbl["weapon_ttt_slk_scream"] = true
        BetterWeaponStrip(self, exclude_tbl)

        local mana_max = GetConVar("ttt2_slk_maximal_mana"):GetInt()

        self:SetNWBool("ttt2_slk_stalker_mode", true)
        self:SetNWInt("ttt2_stalker_mana_max", mana_max)
        self:SetNWInt("ttt2_stalker_mana", mana_max)
        self:UpdateStalkerCloaking()

        -- events.Trigger(EVENT_slk_ACTIVATE, self)
    end

    function plymeta:DeactivateStalkerMode()
        self:SetNWBool("ttt2_slk_stalker_mode", false)
        self:SetNWInt("ttt2_stalker_mana", 0)
        self:UpdateStalkerCloaking()
        -- DeactivateCloaking(self)
    end

    function plymeta:EnableStalkerMode(bool)
        if bool then
            self:ActivateStalkerMode()
            net.Start("ttt2_slk_epop")
                net.WriteString(self:Nick())
                -- net.SendOmit(self)
            net.Broadcast()
        else
            self:DeactivateStalkerMode()
        end
    end

    function plymeta:AddMana(mana)
        if self:GetSubRole() ~= ROLE_STALKER then return end
        self:SetNWInt("ttt2_stalker_mana", math.Clamp(self:GetNWInt("ttt2_stalker_mana", false) + mana, 0, self:GetMaxMana()))
    end

    function plymeta:SetRegenerateMode(bool)
        if bool then
            --print("CloakMode:", self:GetStalkerCloakMode(), CLOAK_FULL)
            if self:GetStalkerCloakMode() ~= CLOAK_FULL or self:GetMana() >= self:GetMaxMana() then
                --print("Cloak is not fully charged: do not aktivate Recharge Moded")
                return
            end
            --print("Aktivate Cloak Recharge.")
            self:SetStalkerCloakMode(CLOAK_PARTIAL, 1, 0.4)
            self:SetNWBool("ttt2_slk_regenerate_mode", true)
        else
            --print("Deaktivate Cloak Recharge")
            self:UpdateStalkerCloaking(true, 1, 0.4)
            self:SetNWBool("ttt2_slk_regenerate_mode", false)
        end
    end

    hook.Add("Think", "TTT2Stalker:CloakThink", function()
        local plys = player.GetAll()
        for i = 1, #plys do
            local ply = plys[i]
            if ply:GetSubRole() ~= ROLE_STALKER or ply:GetStalkerCloakMode() == CLOAK_NONE then continue end

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
            ply:UpdateStalkerCloaking()
        end
    end)

    hook.Add("EntityTakeDamage", "TTT2Stalker:TakeDamage", function(tgt, dmg)
        if not IsValid(tgt) or not tgt:IsPlayer() or not tgt:Alive() or tgt:IsSpec() then return end
        if tgt:GetSubRole() ~= ROLE_STALKER then return end
        if not tgt:GetNWBool("ttt2_slk_stalker_mode", false) then return end
        tgt:SetRegenerateMode(false)
        tgt:UpdateStalkerCloaking(true)
    end)

    
    local function ResetStalkerRole()
        local plys = player.GetAll()
        for i = 1, #plys do
            local ply = plys[i]
            ply:SetNWBool("ttt2_slk_stalker_mode", false)
            ply:SetNWBool("ttt2_slk_regenerate_mode", false)
            -- TODO: Was muss hier noch alles rein?
            ply.stalkerCloakTimeout = nil
            ply.stalkerUseTimeout = nil
        end
    end

    hook.Add("TTTPrepRound", "TTT2Stalker:ResetRole", ResetStalkerRole)
    hook.Add("TTTBeginRound", "TTT2Stalker:ResetRole", ResetStalkerRole)
    hook.Add("TTTEndRound", "TTT2Stalker:ResetRole", ResetStalkerRole)


    hook.Add("PlayerCanPickupWeapon", "TTT2Stalker:NoPickups", function(ply, wep)
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then return end
        if ply:GetSubRole() ~= ROLE_STALKER or not ply:GetNWBool("ttt2_slk_stalker_mode", false) then return end

        return (wep:GetClass() == "weapon_ttt_slk_claws" or wep:GetClass() == "weapon_ttt_slk_tele" or wep:GetClass() == "weapon_ttt_slk_scream")
    end)

     hook.Add("TTT2StaminaRegen", "TTT2Stalker:StaminaMod", function(ply, stamMod)
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then return end
        if ply:GetSubRole() ~= ROLE_STALKER or not ply:GetNWBool("ttt2_slk_stalker_mode") then return end

        stamMod[1] = stamMod[1] * 1.6
    end)

    hook.Add("ScalePlayerDamage", "TTT2Stalker:DmgPreTransform", function(ply, _, dmginfo)
        local attacker = dmginfo:GetAttacker()
        if attacker:GetBaseRole() ~= ROLE_STALKER then return end
        if attacker:GetNWBool("ttt2_slk_stalker_mode") then return end

        dmginfo:ScaleDamage(0.2)
    end)

    hook.Add("DoPlayerDeath", "TTT2Stalker:Died", function(ply, attacker, dmgInfo)
        if not IsValid(ply) or not IsValid(attacker) or ply:IsSpec() or attacker:IsSpec() then return end
        
        if ply:GetSubRole() == ROLE_STALKER and ply:GetNWBool("ttt2_slk_stalker_mode", false) then

            ply:EnableStalkerMode(false)
            -- events.Trigger(EVENT_slk_DEFEAT, ply, attacker, dmgInfo)
            net.Start("ttt2_slk_epop_defeat")
                net.WriteString(ply:Nick())
            net.Broadcast()

        elseif attacker:GetSubRole() == ROLE_STALKER and attacker:GetNWBool("ttt2_slk_stalker_mode", false) and not ply:IsInTeam(attacker) then
            attacker:AddCredits(1)
        end
    end)

    hook.Add("PlayerSpawn", "TTT2Stalker:Respawn", function(ply)
        if ply:GetBaseRole() ~= ROLE_STALKER then return end
        ply:EnableStalkerMode(false)
    end)

end

hook.Add("TTTPlayerSpeedModifier", "TTT2Stalker:SpeedBonus", function(ply, _, _, speedMod)
    if ply:GetSubRole() ~= ROLE_STALKER or not ply:GetNWBool("ttt2_slk_stalker_mode") then return end

    speedMod[1] = speedMod[1] * 1.3
end)

if CLIENT then
    hook.Add("TTT2PreventAccessShop", "TTT2Stalker:PreventShopOutsideStalkerMode", function()
        local ply = LocalPlayer()
        if ply:GetSubRole() ~= ROLE_STALKER or not ply:Alive() or ply:IsSpec() then return end

        return ply:GetNWBool("ttt2_slk_stalker_mode", false) == false
    end)


    net.Receive("ttt2_slk_epop", function()
        EPOP:AddMessage({
            text = LANG.GetParamTranslation("slk_epop_title", {nick = net.ReadString()}),
            color = STALKER.ltcolor
            },
            LANG.GetTranslation("slk_epop_desc")
        )
    end)

    net.Receive("ttt2_slk_epop_defeat", function()
        EPOP:AddMessage({
            text = LANG.GetParamTranslation("slk_epop_defeat_title", {nick = net.ReadString()}),
            color = STALKER.ltcolor
            },
            LANG.GetTranslation("slk_epop_defeat_desc")
        )
    end)

    net.Receive("ttt2_slk_network_wep", function()
                net.ReadEntity().WorldModel = net.ReadString()
    end)
end