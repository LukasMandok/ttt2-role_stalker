if engine.ActiveGamemode() ~= "terrortown" then return end

if SERVER then
    AddCSLuaFile()

    resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_slk.vmt")
end

roles.InitCustomTeam(ROLE.name, {
    icon = "vgui/ttt/dynamic/roles/icon_slk",
    color = Color(0, 49, 82, 255)
})

function ROLE:PreInitialize()
    roles.SetBaseRole(self, ROLE_HIDDEN)

    self.color = Color(0, 49, 82, 255)

    self.abbr = "slk"
    self.score.surviveBonusMultiplier = 0.5
    self.score.timelimitMultiplier = -0.5
    self.score.killsMultiplier = 5
    self.score.teamKillsMultiplier = -16
    self.score.bodyFoundMuliplier = 0

    self.traitorCreditAward = false
    self.preventKillCredits = true
    self.preventFindCredits = true

    self.fallbackTable = {} -- = {items.GetStored("weapon_ttt_slk_tele"),
                        --   --items.GetStored("weapon_ttt_slk_scream"),
                        --   items.GetStored("item_ttt_slk_mana_upgrade"),
                        --   items.GetStored("item_ttt_slk_mobility"),
                        --   items.GetStored("item_ttt_slk_lifesteal")}

    self.defaultTeam = TEAM_STALKER
    self.defaultEquipment = STALKER_EQUIPMENT

    self.conVarData = {
        pct = 0.13,
        maximum = 1,
        minPlayers = 8,
        credits = 2,
        togglable = true,
        random = 20,
        traitorKill = 0,
        creditsTraitorKill = 0,
        --creditsTraitorDead = 1,
        shopFallback = SHOP_UNSET -- SHOP_FALLBACK_STALKER -- SHOP_UNSET
    }

    self.isEvil = true

end

function ROLE:Initialize()
    --roles.SetBaseRole(self, ROLE_HIDDEN)
    --RunConsoleCommand("ttt_" .. self.abbr .. "_shop_fallback", SHOP_FALLBACK_STALKER)

    if SERVER and JESTER then
        self.networkRoles = {JESTER}
    end
end

hook.Add("InitFallbackShops", "InitWeaponInStalkerShop", function() 
    --print("InitFallbackShop of STALKER")

    local sweps = weapons.GetList()

    for i = 1, #sweps do
        local wep = sweps[i]
        if wep.ShopInit then
            wep:ShopInit()
        end
    end
    --InitFallbackShop(STALKER, STALKER.fallbackTable)
    --RunConsoleCommand("ttt_" .. STALKER.abbr .. "_shop_fallback", SHOP_FALLBACK_STALKER)
end)

if SERVER then

    function ROLE:RemoveRoleLoadout(ply, isRoleChange)
        -- TODO: Effizientere Variante!
        ply:RemoveEquipmentWeapon("weapon_ttt_slk_claws")
        ply:RemoveEquipmentWeapon("weapon_ttt_slk_scream")
        ply:RemoveEquipmentWeapon("weapon_ttt_slk_tele")
        ply:RemoveEquipmentItem("item_ttt_slk_lifesteal")
        ply:RemoveEquipmentItem("item_ttt_slk_mana_upgrade")
        ply:RemoveEquipmentItem("item_ttt_slk_mobility")
        ply:RemoveEquipmentItem("item_ttt_climb")
        ply:SetStalkerMode_slk(false)
        STATUS:RemoveStatus(ply, "ttt2_hdn_invisbility")
        RECHARGE_STATUS:RemoveStatus(ply, "ttt2_slk_lifesteal_recharge")
        RECHARGE_STATUS:RemoveStatus(ply, "ttt2_slk_tele_recharge")
        RECHARGE_STATUS:RemoveStatus(ply, "ttt2_slk_scream_recharge")

        hook.Remove("PreDrawHalos", "HighlightTeleObjects")
        hook.Remove("CreateMove", "RemoveHighlightObject")
    end

    hook.Add("KeyPress", "StalkerEnterStalker", function(ply, key)
        if ply:GetSubRole() ~= ROLE_STALKER or not ply:Alive() or ply:IsSpec() then return end

        if key == IN_RELOAD then
            if not ply:GetNWBool("ttt2_hd_stalker_mode", false) then
                ply:SetStalkerMode_slk(true)
                STATUS:AddStatus(ply, "ttt2_hdn_invisbility")
                ply:GiveEquipmentWeapon("weapon_ttt_slk_claws")
                --ply:GiveEquipmentWeapon("weapon_ttt_slk_tele")
                --ply:GiveEquipmentWeapon("weapon_ttt_slk_scream")

            elseif ply:GetNWBool("ttt2_slk_regenerate_mode", false) == false then
                ply:SetRegenerateMode(true)
            else
                ply:SetRegenerateMode(false)
            end
        end
    end)
end

-- -- Remove Hooks if Round has ended
-- hook.Add("TTTEndRound", "RemoveStalkerHooks", function()
--     hook.Remove("KeyPress", "StalkerEnterStalker")
    
-- end)
