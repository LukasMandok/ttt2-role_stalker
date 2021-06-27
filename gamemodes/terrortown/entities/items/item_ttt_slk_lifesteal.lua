if SERVER then
    AddCSLuaFile()

    resource.AddFile("materials/vgiu/ttt/icon_slk_lifesteal")
    resource.AddFile("materials/vgui/ttt/hud/hud_icon_slk_lifesteal.vmt")
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
    --ITEM.hud      = Material("vgui/ttt/hud/hud_icon_slk_lifesteal.png")  --.png
end

ITEM.RegenTime       = 2
ITEM.RegenTimeCorpse = 5
ITEM.Mana            = 10


function ITEM:Initialize()
    AddToShopFallback(STALKER.fallbackTable, ROLE_STALKER, self)
end


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

        hook.Add("ttt_slk_claws_hit", "TTT2Stalker:ClawsLifesteal", function(ply, tgt, dmg, primary)
            if not ply:HasEquipmentItem(self.id) or ply:GetSubRole() ~= ROLE_STALKER or not ply:Alive() or ply:IsSpec() then return end

            if tgt:IsPlayer() and primary then
                self:HitPlayer(ply, tgt, dmg)
            elseif tgt:IsRagdoll() and primary then
                self:HitRagdoll(ply, tgt, dmg)
            end
        end)
    end

    -- Sets the time, where the Item can regenerate Health again
    function ITEM:SetNextRegen(ply, time)
        local time = time or self.RegenTime
        ply.NextRegen = CurTime() + time
        RECHARGE_STATUS:SetRechargeTimer(ply, "ttt2_slk_lifesteal_recharge", time, true)
    end

    -- Tests if the item can regenerate health
    function ITEM:CanRegen(ply)
        if not ply.NextRegen then 
            return true
        else 
            return ply.NextRegen < CurTime() 
        end
    end

    function ITEM:HitPlayer(ply, tgt, dmg)
        if not self:CanRegen(ply) then return end

        local health = tgt:Health()
        if  health <= dmg then
            ply:AddHealth(health * 0.2 + 20)
            self:SetNextRegen(ply)
        else
            ply:AddHealth(dmg * 0.2)
            self:SetNextRegen(ply)
        end
    end

    function ITEM:HitRagdoll(ply, tgt, dmg)
        if not self:CanRegen(ply) then return end

        tgt.stalkerLifestealHits = tgt.stalkerLifestealHits or 1

        if tgt.stalkerLifestealHits >= 5 then return end

        ply:AddHealth(dmg * 0.4)
        self:SetNextRegen(ply, self.RegenTimeCorpse)
        tgt.stalkerLifestealHits = tgt.stalkerLifestealHits + 1
    end


end