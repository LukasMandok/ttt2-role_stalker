if engine.ActiveGamemode() ~= "terrortown" then return end

game.AddAmmoType( {
    name = "stalker_scream",
} )

if SERVER then
    AddCSLuaFile()
    SWEP.Weight         = 1
    SWEP.AutoSwitchTo   = false
    SWEP.AutoSwitchFrom = false

    resource.AddFile("materials/vgiu/ttt/icon_slk_scream")
    resource.AddFile("materials/vgui/ttt/hud_icon_slk_scream") --.png
end

if CLIENT then
    SWEP.PrintName      = "weapon_ttt_slk_scream_name"
    SWEP.DrawAmmo       = true -- not needed?
    SWEP.DrawCrosshair  = false
    SWEP.ViewModelFlip  = false
    SWEP.ViewModelFOV   = 90
    SWEP.Slot           = 3
    SWEP.Slotpos        = 3

    SWEP.material = "vgui/ttt/icon_slk_scream"
end

SWEP.EquipMenuData = {
    type = "item_weapon",
    name = "weapon_ttt_slk_scream_name",
    desc = "weapon_ttt_slk_scream_desc",
    credits = 2
}

SWEP.Base = "weapon_tttbase"

-- Visuals
SWEP.ViewModel             = ""
SWEP.WorldModel            = ""
SWEP.HoldType              = "normal"
SWEP.UseHands              = false

-- Shop settings
SWEP.Kind                  = WEAPON_NADE
SWEP.CanBuy                = {ROLE_STALKER}
SWEP.LimitedStock          = true
SWEP.notBuyable            = false

-- PRIMARY:  Scream Attack -> damages and suns players
SWEP.Primary.Delay          = 10
SWEP.Primary.Damage         = 20
SWEP.Primary.Automatic      = false
SWEP.Primary.HitForce       = 50
SWEP.Primary.ClipSize       = 1 -- 1
SWEP.Primary.DefaultClip    = 1 -- 1
SWEP.Primary.Ammo           = "stalker_scream"
SWEP.Primary.Scream         = Sound("npc/stalker/go_alert2a.wav" )
SWEP.Primary.Miss           = Sound("ambient/atmosphere/cave_hit2.wav")

-- TTT2 related
SWEP.MaxDistance    = 200
SWEP.AllowDrop      = false
SWEP.IsSilent       = true
                       -- pitch, yaw, roll
SWEP.HitAngle       = Angle(30,  45,  0)   -- one direction

-- Pull out faster than standard guns
SWEP.DeploySpeed = 2

-- Mana Managment
SWEP.Mana = 50

--AddWeaponIntoFallbackTable(SWEP:GetClass(), STALKER)

-- hook.Add("PostInitPostEntity", "Intiaialize_weapon_ttt_slk_scream", function()
--     AddToShopFallback(STALKER.fallbackTable, ROLE_STALKER, SWEP)
--     --AddWeaponIntoFallbackTable(SWEP.id, STALKER)
-- end)

function SWEP:ShopInit()
    --print("Adding Scream to FallbackTable")
    AddToShopFallback(STALKER.fallbackTable, ROLE_STALKER, self)
    --AddWeaponIntoFallbackTable(self.id, STALKER)
end

function SWEP:Initialize()
    --print("SCream Initialize")
    self:SetWeaponHoldType(self.HoldType)
end


-- function SWEP:Holster()
--     return false
-- end
function SWEP:Equip(owner)
    if not SERVER or not owner then return end
    owner:DrawWorldModel(false)
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) or owner:GetSubRole() ~= ROLE_STALKER or not owner:GetNWBool("ttt2_hd_stalker_mode", false) then return end

    if owner:GetMana() < self.Mana then
        --print("Not enough mana", owner:GetMana(), self.Mana)
        owner:SetAmmo(0, self:GetPrimaryAmmoType())
    return end

    local ammo = math.Clamp(math.floor(self:GetOwner():GetMana() / self.Mana ) - self:Clip1(), 0, 10)
    owner:SetAmmo(ammo, self:GetPrimaryAmmoType())

    if self:GetNextPrimaryFire() > CurTime() then
        --print("NextPrimaryFire not ready")
        --print("NextSecondaryFire not valid:", self:GetNextSecondaryFire())
    return end

    --print("Reload Ammo:", ammo)
    self:SetClip1(1)
    -- self:Reload()

end

function SWEP:CanPrimaryAttack()
    if self:Clip1() < 1 then
        self:GetOwner():EmitSound( self.Primary.Miss, 40, 250 )
        self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
        return false
    end

    return true
end

function SWEP:PrimaryAttack()

    local owner = self:GetOwner()
    if not IsValid(owner) or owner:GetSubRole() ~= ROLE_STALKER or not owner:GetNWBool("ttt2_hd_stalker_mode", false) then return end

    if not self:CanPrimaryAttack() then return end

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    self:SetClip1(0)
    --owner:SetAmmo(owner:GetAmmoCount(self:GetPrimaryAmmoType()) - 1, self:GetPrimaryAmmoType())

    --owner:LagCompensation(true)
    if self:Scream() and SERVER then
        owner:AddMana(-self.Mana)
    end

    return true
    --owner:LagCompensation(false)
end


function SWEP:Scream()
    local owner = self:GetOwner()

    owner:EmitSound( self.Primary.Scream, 100, 90 )

    --TODO: Create Blast effect
    local ed = EffectData()
    ed:SetOrigin(owner:EyePos())
    ed:SetAngles(owner:EyeAngles())
    util.Effect( "ManhackSparks", ed, true, true )

    for k,ply in pairs( util.GetAlivePlayers() ) do
    	
        if ply == owner then continue end

        local vec = ply:GetPos() - owner:GetPos()
        local angle = vec:Angle() - owner:EyeAngles()
        angle:Normalize()

        -- print("\n", ply:Nick() .. ":")
        -- print("Vector:", vec, "condition:", vec:LengthSqr() < self.MaxDistance^2)
        -- print("\tvec^2", vec:LengthSqr(), "max^2:", self.MaxDistance^2)
        -- print("angle:", angle, "condition p:", math.abs(angle.p) < self.HitAngle.p, "condition y:", math.abs(angle.y) < self.HitAngle.y)
        -- print("\tangle p:", math.abs(angle.p), "max p:", self.HitAngle.p)
        -- print("\tangle y:", math.abs(angle.y), "max p:", self.HitAngle.y)

        if not ply:IsSpec() and  (vec:LengthSqr() <  self.MaxDistance^2) and (math.abs(angle.p) < self.HitAngle.p) and (math.abs(angle.y) < self.HitAngle.y) and ply:Team() ~= TEAM_STALKER then
            util.BlastDamage( owner, owner, ply:GetPos(), 5, self.Primary.Damage )

            -- Screen Effect on the Hit players
            local ed = EffectData()
            ed:SetOrigin( ply:GetPos() )
            util.Effect( "effect_ttt_slk_scream", ed, true, true )
        end
    end

    -- local tbl = ents.FindByClass( "sent_tripmine" )
    -- tbl = table.Add( tbl, ents.FindByClass( "sent_seeker" ) )

    -- for k,v in pairs( tbl ) do
    --     if v:GetPos():Distance( owner:GetPos() ) < 350 then
    --         v:Malfunction()
    --     end
    -- end

    return true
end