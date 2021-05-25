if engine.ActiveGamemode() ~= "terrortown" then return end

game.AddAmmoType( {
    name = "stalker_tele",
} )

if SERVER then
    AddCSLuaFile()
    SWEP.Weight         = 1
    SWEP.AutoSwitchTo   = false
    SWEP.AutoSwitchFrom = false

    resource.AddFile("materials/vgiu/ttt/icon_slk_tele")
    resource.AddFile("materials/vgui/ttt/hud_icon_slk_tele") --.png
end

if CLIENT then
    SWEP.PrintName      = "weapon_ttt_slk_tele_name"
    SWEP.DrawAmmo       = true -- not needed?
    SWEP.DrawCrosshair  = true
    SWEP.ViewModelFlip  = false
    SWEP.ViewModelFOV   = 74
    SWEP.Slot           = 2
    SWEP.Slotpos        = 2

    --SWEP.Category =
    --SWEP.Icon =
    SWEP.material = "vgui/ttt/icon_slk_tele"

    SWEP.EquipMenuData = {
        type = "item_weapon",
        name = "weapon_ttt_slk_tele_name",
        desc = "weapon_ttt_slk_tele_desc",
        credits = 3
    }
end

SWEP.Base = "weapon_tttbase"

-- SWEP.Spawnable = true
-- SWEP.AutoSpawnable = false
-- SWEP.AdminSpawnable = true

-- Visuals
SWEP.ViewModel              = "models/zed/weapons/v_banshee.mdl"
SWEP.WorldModel             = ""
SWEP.HoldType               = "magic"
SWEP.UseHands               = true

-- Shop settings
SWEP.Kind                   = WEAPON_HEAVY
SWEP.CanBuy                 = {ROLE_STALKER}
SWEP.LimitedStock           = true
SWEP.notBuyable             = false

-- PRIMARY: Tele Shot
SWEP.Primary.Delay          = 0.2
SWEP.Primary.Automatic      = false
SWEP.Primary.ClipSize       = 1 -- 1
SWEP.Primary.DefaultClip    = 1 -- 1
SWEP.Primary.Ammo           = "stalker_tele" -- do i need this?
SWEP.Primary.Tele           = Sound("npc/turret_floor/active.wav")
SWEP.Primary.Miss           = Sound("ambient/atmosphere/cave_hit2.wav")
SWEP.Primary.Mana           = 50

-- SECONDARY: Start Tele 
SWEP.Secondary.Delay        = 10
SWEP.Secondary.Automatic    = false
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.TeleShot     = Sound("ambient/levels/citadel/portal_beam_shoot5.wav")
SWEP.Secondary.Mana         = 25

-- TTT2 related
SWEP.MaxDistance        = 250
SWEP.AllowDrop          = false
SWEP.IsSilent           = true

-- Pull out faster than standard guns
SWEP.DeploySpeed        = 2

--AddWeaponIntoFallbackTable(SWEP:GetClass(), STALKER)


-- hook.Add("PostInitPostEntity", "Intiaialize_weapon_ttt_slk_tele", function()
--     AddToShopFallback(STALKER.fallbackTable, ROLE_STALKER, SWEP)
--     --AddWeaponIntoFallbackTable(SWEP.id, STALKER)
-- end)

function SWEP:ShopInit()
    AddToShopFallback(STALKER.fallbackTable, ROLE_STALKER, self)
    --AddWeaponIntoFallbackTable(self.id, STALKER)
end

function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)
end

-- function SWEP:Holster()
--     return false
-- end
function SWEP:Equip(owner)
    if not SERVER or not owner then return end
    owner:DrawWorldModel(false)
    --self.ViewModel = "models/weapons/v_banshee.mdl"
    --self.WorldModel = ""
    -- net.Start("ttt2_hdn_network_wep")
    --     net.WriteEntity(self)
    --     net.WriteString("")
    -- net.Broadcast()
    -- STATUS:RemoveStatus(owner, "ttt2_hdn_knife_recharge")
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) or owner:GetSubRole() ~= ROLE_STALKER or not owner:GetNWBool("ttt2_hd_stalker_mode", false) then return end

    local mana_cost = self.Primary.Mana + self.Secondary.Mana

    local ammo = math.Clamp(math.floor(self:GetOwner():GetMana() / mana_cost) - self:Clip1(), 0, 10)
    owner:SetAmmo(ammo, self:GetPrimaryAmmoType())

    if owner:GetMana() < mana_cost then
        --print("Not enough mana")
    return end

    if self:GetNextSecondaryFire() > CurTime() then
        --print("NextSecondaryFire not valid:", self:GetNextSecondaryFire())
    return end

    self:SetClip1(1)
    -- self:Reload()
end

-- function SWEP:Reload()
--     print("Try Reloading")
--     if self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() ) < 1 then
--         print("Not enough Ammo available:", self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()))
--     return end
--     if self.Clip1() == self.Primary.ClipSize then
--         print("Clip already full!:", self.Clip1())
--     return end

--     print("Set Clip1 to:", self.Primary.ClipSize)
--     self:SetClip1(self.Primary.ClipSize)
-- end

function SWEP:CanSecondaryAttack()
    -- if self:GetOwner():GetMana() < (self.Primary.Mana + self.Secondary.Mana) then
    --     self:SetClip1()
    --     return false
    -- end
    -- print("AmmoCOunt:", self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()))
    -- if self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()) < 1 then
    --     self:GetOwner():EmitSound( self.Primary.Miss, 40, 250 )
    -- return false
    -- end
    if self:Clip1() < 1 then
        --print("not enough ammo:", self:Clip1())
        self:GetOwner():EmitSound( self.Primary.Miss, 40, 250 )
        self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
        return false
    end

    return true
end

-- end
function SWEP:PrimaryAttack()
    -- TODO: Only set this, if the attack hit something.    

    --self.ViewModel = "models/weapons/v_banshee.mdl"
    local owner = self:GetOwner()
    if not IsValid(owner) or owner:GetSubRole() ~= ROLE_STALKER or not owner:GetNWBool("ttt2_hd_stalker_mode", false) then return end
    --owner:LagCompensation(true)

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    if self:ShotTele() then
        self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
    
        if SERVER then
            owner:AddMana(-self.Primary.Mana)
        end
    end

    return true
    --owner:LagCompensation(false)
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) or owner:GetSubRole() ~= ROLE_STALKER or not owner:GetNWBool("ttt2_hd_stalker_mode", false) then return end

    if not self:CanSecondaryAttack() then return end

    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
    --self.ViewModel = "models/zed/weapons/v_banshee.mdl"

    --owner:LagCompensation(true)
    -- local tgt, spos, sdest, trace = self:MeleeTrace()
    -- print("target:", tgt, "pos:", spos, "destination:", sdest, "trace:", trace)
    -- if IsValid(tgt) then
    if self:Tele() then
        self:SetClip1(0)
        --owner:SetAmmo(owner:GetAmmoCount(self:GetPrimaryAmmoType()) - 1, self:GetPrimaryAmmoType())
        if SERVER then
            owner:AddMana(-self.Secondary.Mana)
        end
    end
    --owner:LagCompensation(false)
end

-- Turnes Prop into controlled prop
function SWEP:TeleProp(ent)
    local owner = self:GetOwner()
    --print("Turn Prop into TeleProp")
    ent.Tele = true
    local psy = ents.Create("ttt_tele_object")
    psy:SetOwner(owner)
    psy:SetAngles(ent:GetAngles())

    if ent:GetClass() == "prop_ragdoll" then
        psy:SetCollides(true)
        psy:SetTrueParent(ent)
        psy:SetPos(ent:LocalToWorld(ent:OBBCenter()))
        psy:SetModel("models/props_junk/propanecanister001a.mdl")
    else
        psy:SetParent(ent)
        psy:SetModel(ent:GetModel())
        psy:SetPos(ent:GetPos())
    end

    local phys = ent:GetPhysicsObject()

    if IsValid(phys) then
        psy:SetMass(math.Clamp(phys:GetMass(), 100, 5000))
        psy:SetPhysMat(phys:GetMaterial())
    end

    psy:Spawn()
    self.Prop = psy
    owner:EmitSound(self.Primary.Tele, 50)
    -- net.Start("Flay")
    -- net.Send(owner)
end

-- Checks wether telekinesis can be used on an object
function SWEP:CanTele(ent, phys)
    if (string.find(ent:GetClass(), "prop_phys") or ent:GetClass() == "prop_ragdoll") and not IsValid(ent:GetParent()) then
        if IsValid(phys) and phys:IsMotionEnabled() and phys:IsMoveable() then
            print("Can Tele: TRUE!")
            return true
        end
    end

    print("Cannot Tele: FALSE")
end

-- Lanches Object, if one is controlled with telekinesis
function SWEP:ShotTele()

    print("Activate ShotTele")
    -- TODO: Entfernung beachten
    local tr = util.TraceLine(util.GetPlayerTrace(self:GetOwner()))

    if IsValid(self.Prop) then
        print("ShotTele is carried out!")
        self.Prop:EmitSound(self.Secondary.TeleShot, 100, math.random(100, 120))
        self.Prop:SetLaunchTarget(tr.HitPos)
        self.Prop = nil

        return true
    end
end

-- Starks Telekinesis process of an object
function SWEP:Tele()
    local owner = self:GetOwner()
    -- create Trace in the direction the player is looking in. 
    -- restrict distance to self.MaxDistance
    local spos = owner:GetShootPos()
    local sdest = spos + (owner:GetAimVector() * self.MaxDistance)

    local tr = util.TraceLine({
        start = spos,
        endpos = sdest,
        filter = owner,
        mask = MASK_SHOT_HULL
    })

    -- TODO: Implement Mana System
    -- if not enough mana, return
    -- if owner:GetMana() < self.Mana then
    --     return
    -- end

    local phys
    if IsValid(tr.Entity) then
        phys = tr.Entity:GetPhysicsObject()
    end

    -- if object meets the Telekinesis requirements: TODO: add distance
    if IsValid(tr.Entity) and IsValid(phys) and self:CanTele(tr.Entity, phys) then
        print("Trace has hit object", tr.Entity)
        self:TeleProp(tr.Entity)

        return true
        -- searches around the hit position for the closest other object
    else
        local dist = 100
        local ent
        local tbl = ents.FindByClass("prop_phys*")
        tbl = table.Add(tbl, ents.FindByClass("prop_ragdoll"))

        for k, v in pairs(tbl) do
            local phys = v:GetPhysicsObject()

            -- HitPos is EndPos if trace hit nothing
            if v:GetPos():Distance(tr.HitPos) < dist and not IsValid(v:GetParent()) and self:CanTele(v, phys) then
                ent = v
                dist = v:GetPos():Distance(tr.HitPos)
            end
        end

        if IsValid(ent) then
            self:TeleProp(ent)

            return true
        end

        owner:EmitSound(self.Primary.Miss, 50, 250)
        return false
    end
end
