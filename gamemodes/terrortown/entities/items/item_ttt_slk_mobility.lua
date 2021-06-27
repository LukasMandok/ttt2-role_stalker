
if SERVER then
    AddCSLuaFile()

    resource.AddFile("materials/vgiu/ttt/icon_slk_mobility")
    resource.AddFile("materials/vgui/ttt/hud/hud_icon_slk_mobility") --.png
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
    ITEM.hud      = Material("vgui/ttt/hud/hud_icon_slk_mobility.vmt")  --.png
end

ITEM.RegenTime = 2


function ITEM:Initialize()
    AddToShopFallback(STALKER.fallbackTable, ROLE_STALKER, self)
end

function ITEM:Bought(owner)
    if owner:GetSubRole() ~= ROLE_STALKER or not owner:Alive() or owner:IsSpec() then return end

    hook.Add("KeyPress", "TTT2Stalker:DashJump", function(ply, key)
        if not ply:HasEquipmentItem(self.id) or ply:GetSubRole() ~= ROLE_STALKER or not ply:Alive() or ply:IsSpec() then return end

        if key == IN_JUMP and ply:KeyDown(IN_SPEED) then
            self:DashJump(ply)
        end
    end)

    if SERVER then
        owner:GiveEquipmentItem("item_ttt_climb")
    end
end

-- Functionality
function ITEM:SetNextJump(ply, time)
    ply.NextJump = CurTime() + (time or self.RegenTime)
end

function ITEM:CanJump(ply)
    return ply.NextJump and ply.NextJump < CurTime() or true
end

function ITEM:DashJump(ply)
    if not self:CanJump(ply) then return end

    if ply:OnGround() then
        local jump = ply:GetAimVector() * 400 + Vector(0, 0, 350)
        ply:SetVelocity(jump)
        ply:EmitSound("npc/fast_zombie/foot3.wav", 40, math.random(90, 110))
        self:SetNextJump(ply)
    -- else
    --     local tr = util.TraceLine(util.GetPlayerTrace(ply))

    --     if tr.HitPos:Distance(ply:GetShootPos()) < 50 and not ply:OnGround() then
    --         ply:SetLocalVelocity(Vector(0, 0, 0))
    --         ply:SetMoveType(MOVETYPE_NONE)
    --     elseif ply:GetMoveType() == MOVETYPE_NONE then
    --         ply:SetMoveType(MOVETYPE_WALK)
    --         ply:SetLocalVelocity(ply:GetAimVector() * 500)
    --     end
    end
end