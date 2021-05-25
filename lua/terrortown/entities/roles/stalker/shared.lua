if engine.ActiveGamemode() ~= "terrortown" then return end

if SERVER then
    AddCSLuaFile()

    resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_slk.vmt")
end

-- TODO: Implement Mana instead of Ammunition

roles.InitCustomTeam(ROLE.name, {
    icon = "vgui/ttt/dynamic/roles/icon_slk",
    color = Color(0, 49, 82, 255)
})

function ROLE:PreInitialize()
    --roles.SetBaseRole(self, ROLE_HIDDEN)

    self.color = Color(0, 49, 82, 255)

    self.abbr = "slk"
    self.score.surviveBonusMultiplier = 0.5
    self.score.timelimitMultiplier = -0.5
    self.score.killsMultiplier = 5
    self.score.teamKillsMultiplier = -16
    self.score.bodyFoundMuliplier = 0



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
        credits = 3,
        togglable = true,
        random = 20,
        shopFallback = SHOP_UNSET -- SHOP_FALLBACK_STALKER -- SHOP_UNSET
    }

    self.isEvil = true

end

function ROLE:Initialize()
    roles.SetBaseRole(self, ROLE_HIDDEN)
    --RunConsoleCommand("ttt_" .. self.abbr .. "_shop_fallback", SHOP_FALLBACK_STALKER)

    if SERVER and JESTER then
        self.networkRoles = {JESTER}
    elseif CLIENT then
        --print("\n\n\n Hier könnte der EquipmentTable gelöscht werden")
        --Equipment[ROLE_STALKER] = nil
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
        ply:RemoveEquipmentWeapon("weapon_ttt_slk_claws")
        ply:RemoveEquipmentWeapon("weapon_ttt_slk_tele")
        ply:RemoveEquipmentItem("item_ttt_climb")
        ply:SetStalkerMode_slk(false)
        STATUS:RemoveStatus(ply, "ttt2_hdn_invisbility")
    end

    hook.Add("KeyPress", "StalkerEnterStalker", function(ply, key)
        if ply:GetSubRole() ~= ROLE_STALKER or not ply:Alive() or ply:IsSpec() then return end

        if key == IN_RELOAD then
            if ply:GetNWBool("ttt2_hd_stalker_mode", false) == false then
                ply:SetStalkerMode_slk(true)
                --STATUS:AddStatus(ply, "ttt2_hdn_invisbility")
                --ply:GiveEquipmentWeapon("weapon_ttt_hd_knife")
                ply:GiveEquipmentWeapon("weapon_ttt_slk_claws")
                ply:GiveEquipmentWeapon("weapon_ttt_slk_tele")
                ply:GiveEquipmentWeapon("weapon_ttt_slk_scream")

            elseif ply:GetNWBool("ttt2_slk_regenerate_mode", false) == false then 
                ply:SetRegenerateMode(true)
            else
                ply:SetRegenerateMode(false)
            end
        end
    end)
end
