if SERVER then
    AddCSLuaFile()

    resource.AddFile("materials/vgiu/ttt/icon_slk_lifesteal")
    resource.AddFile("materials/vgui/ttt/hud_icon_slk_lifesteal") --.png
end

ITEM.EquipMenuData = {
    type = "item_passive",
    name = "item_ttt_slk_lifesteal_name",
    desc = "item_ttt_slk_lifesteal_desc",
    credits = 2
}

ITEM.PrintName = "item_ttt_slk_lifesteal_name"

ITEM.CanBuy     = {ROLE_STALKER}
ITEM.limited    = true
ITEM.notBuyable = false

if CLIENT then
    ITEM.material = "vgui/ttt/icon_slk_lifesteal"
    ITEM.hud      = Material("vgui/ttt/hud_icon_slk_lifesteal")  --.png
end

ITEM.RegenTime = 2
ITEM.RegenTimeCorpse = 5

-- hook.Add("PostInitPostEntity", "Intiaialize_item_ttt_slk_lifesteal", function()
--     AddToShopFallback(STALKER.fallbackTable, ROLE_STALKER, ITEM)
-- end)

function ITEM:Initialize()
    AddToShopFallback(STALKER.fallbackTable, ROLE_STALKER, self)
end
--     if SERVER then
--         AddEquipmentToRole(ROLE_STALKER, self)

--     elseif CLIENT then
--         AddEquipmentToRoleEquipment(ROLE_STALKER, self)
--     end
-- end


if SERVER then

    local plymeta = FindMetaTable("Player")

    function plymeta:AddHealth(health)

        if self:Health() == self:GetMaxHealth() then return end

        -- Clamp between 0 and Maximum Health
        -- TODO: Maybe not needed: CHECK THIS!
        self:SetHealth( math.Clamp(self:Health() + health, 0, self:GetMaxHealth()))
    end

    function ITEM:Bought(owner)
        if owner:GetSubRole() ~= ROLE_STALKER or not owner:Alive() or owner:IsSpec() then return end

        hook.Add("ttt_slk_claws_hit", "StalkerClawsLifesteal", function(ply, tgt, dmg, primary)
            if ply:HasEquipmentItem(self.id) and ply:GetSubRole() ~= ROLE_STALKER or not ply:Alive() or ply:IsSpec() then return end

            if tgt:IsPlayer() and primary then
                self:HitPlayer(ply, tgt, dmg)
            elseif tgt:IsRagdoll() and primary then
                self:HitRagdoll(ply, tgt, dmg)
            end
        end)
    end

    -- Sets the time, where the Item can regenerate Health again
    function ITEM:SetNextRegen(ply, time)
        ply.NextRegen = CurTime() + (time or self.RegenTime)
    end

    -- Tests if the item can regenerate health
    function ITEM:CanRegen(ply)
        return ply.NextRegen and ply.NextRegen < CurTime() or true
    end

    function ITEM:HitPlayer(ply, tgt, dmg)
        if not self:CanRegen(ply) then return end

        local health = tgt:Health()
        if  health < (dmg + 5) then
            ply:AddHealth(health * 0.2 + 20)
            self:SetNextRegen(ply)
        else
            ply:AddHealth(dmg * 0.2)
            self:SetNextRegen(ply)
        end
    end

    function ITEM:HitRagdoll(ply, tgt, dmg)
        if not self:CanRegen(ply) then return end

        tgt.lifesteal_hits = tgt.lifesteal_hits or 1

        if tgt.lifesteal_hits >= 5 then return end

        ply:AddHealth(dmg * 0.4)
        self:SetNextRegen(ply, self.RegenTimeCorpse)
        tgt.lifesteal_hits = tgt.lifesteal_hits + 1
    end


end