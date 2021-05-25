
if SERVER then
    AddCSLuaFile()

    resource.AddFile("materials/vgiu/ttt/icon_slk_mobility")
    resource.AddFile("materials/vgui/ttt/hud_icon_slk_mobility") --.png
end

ITEM.EquipMenuData = {
    type = "item_passive",
    name = "item_ttt_slk_mobility_name",
    desc = "item_ttt_slk_mobility_desc",
    credits = 2
}

ITEM.PrintName = "item_ttt_slk_mobility_name"

ITEM.CanBuy     = {ROLE_STALKER}
ITEM.limited    = true
ITEM.notBuyable = false

if CLIENT then
    ITEM.material = "vgui/ttt/icon_slk_mobility"
    ITEM.hud      = Material("vgui/ttt/hud_icon_slk_mobility")  --.png
end

ITEM.RegenTime = 2


-- hook.Add("PostInitPostEntity", "Intiaialize_item_ttt_slk_mobility", function()
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


-- if SERVER then
    -- function ITEM:Initialize()
    --     AddEquipmentToRole(ROLE_STALKER, self)
    -- end

local plymeta = FindMetaTable("Player")


function ITEM:Bought(owner)
    if owner:GetSubRole() ~= ROLE_STALKER or not owner:Alive() or owner:IsSpec() then return end

    hook.Add("KeyPress", "StalkerEnterStalker", function(ply, key)
        if ply:HasEquipmentItem(self.id) and ply:GetSubRole() ~= ROLE_STALKER or not ply:Alive() or ply:IsSpec() then return end

        if key == IN_JUMP and ply:KeyDown(IN_SPEED) then
            self:DashJump(ply)
        end
    end)

    if SERVER then
        ply:GiveEquipmentItem("item_ttt_climb")
    end
end

-- Functionality
function ITEM:SetNextJump(ply, time)
    ply.NextJump = CurTime() + (time or self.RegenTime)
end

function ITEM:CanJump(ply)
    return ply.NextJump and ply.NextJump < CurTime() or true
end

function ITEM:DashJump(owner)
    if not self:CanJump(owner) then return end

    --owner = self:GetOwner()

    if owner:OnGround() then
        local jump = owner:GetAimVector() * 400 + Vector(0, 0, 350)
        owner:SetVelocity(jump)
        owner:EmitSound("npc/fast_zombie/foot3.wav", 40, math.random(90, 110))
        self:SetNextJump(owner)
    else
        local tr = util.TraceLine(util.GetPlayerTrace(owner))

        if tr.HitPos:Distance(owner:GetShootPos()) < 50 and not owner:OnGround() then
            owner:SetLocalVelocity(Vector(0, 0, 0))
            owner:SetMoveType(MOVETYPE_NONE)
        elseif owner:GetMoveType() == MOVETYPE_NONE then
            owner:SetMoveType(MOVETYPE_WALK)
            owner:SetLocalVelocity(owner:GetAimVector() * 500)
        end
    end
end