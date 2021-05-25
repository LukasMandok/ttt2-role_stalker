if SERVER then
    AddCSLuaFile()

    resource.AddFile("materials/vgiu/ttt/icon_slk_mana_upgrade")
    resource.AddFile("materials/vgui/ttt/hud_icon_slk_mana_upgrade") --.png
end

ITEM.EquipMenuData = {
    type = "item_passive",
    name = "item_ttt_slk_mana_upgrade_name",
    desc = "item_ttt_slk_mana_upgrade_desc",
    credits = 1
}

ITEM.PrintName = "item_ttt_slk_lifesteal_name"

ITEM.CanBuy     = {ROLE_STALKER}
ITEM.limited    = false
ITEM.notBuyable = false

ITEM.ManaUpgrade = 50

if CLIENT then
    ITEM.material = "vgui/ttt/icon_slk_mana_upgrade"
    ITEM.hud      = Material("vgui/ttt/hud_icon_slk_mana_upgrade")  --.png
end

function ITEM:Initialize()
    AddToShopFallback(STALKER.fallbackTable, ROLE_STALKER, self)
end
--     if SERVER then
--         print("Add Equipment Server Side: Mana Upgrade")
--         AddEquipmentToRole(ROLE_STALKER, self)
--     elseif CLIENT then
--         print("Add Equipment Client Side: Maana upgrade")
--         AddEquipmentToRoleEquipment(ROLE_STALKER, self)
--     end
-- end


if SERVER then
    --function ITEM:Initialize()
        --AddEquipmentToRole(ROLE_STALKER, self)
    --end

    function ITEM:Equip(ply)
        if ply:GetSubRole() ~= ROLE_STALKER or not ply:Alive() or ply:IsSpec() then return end

        ply:SetNWInt("ttt2_stalker_mana_max", ply:GetNWInt("ttt2_stalker_mana_max") + self.ManaUpgrade)
    end
end