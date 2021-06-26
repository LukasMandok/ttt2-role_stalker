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
    resource.AddFile("materials/vgui/ttt/hud/hud_icon_slk_tele") --.png

    util.AddNetworkString("SendMassList")
    util.AddNetworkString("RequestMassList")
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
SWEP.Primary.TeleSound      = Sound("npc/turret_floor/active.wav")
SWEP.Primary.MissSound      = Sound("ambient/atmosphere/cave_hit2.wav")
SWEP.Primary.ManaMin        = 10
SWEP.Primary.ManaMax        = 75

-- SECONDARY: Start Tele 
SWEP.Secondary.Delay        = 10
SWEP.Secondary.Automatic    = false
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.Ammo         = "none"
SWEP.Primary.TeleShotSound  = Sound("ambient/levels/citadel/portal_beam_shoot5.wav")
SWEP.Secondary.Mana         = 25

-- TTT2 related
SWEP.MaxDistance        = 250
SWEP.FindObjectDistance = 75
SWEP.AllowDrop          = false
SWEP.IsSilent           = true

-- Pull out faster than standard guns
SWEP.DeploySpeed        = 2
SWEP.RenderGroup = RENDERGROUP_OPAQUE

local plymeta = FindMetaTable("Player")

------------------------------------------------
------- Initialize Weapon and Add Hooks -------- 
------------------------------------------------

-- Initialize TeleEntities

local function createTeleEntry(ent)
    --print("add:", ent:GetClass())
    return { ["Mass"]  = nil,
             ["Class"] = ent:GetClass(),
             ["Ent"]   = ent}
end

function SWEP:InitializeTeleEnts()
    --print("Initialize Tele Ents")
    self.TeleEnts = {}

    for i,ent in ipairs(ents.GetAll()) do
        -- physic props
        if string.find(ent:GetClass(), "prop_phys*") then
            self.TeleEnts[ent:EntIndex()] = createTeleEntry(ent)

        -- spawnable weapons
        elseif string.find(ent:GetClass(), "weapon_*") then
            if ent.AutoSpawnable and not IsValid(ent:GetOwner()) then
                self.TeleEnts[ent:EntIndex()] = createTeleEntry(ent)
            end

        -- spawnable ammo
        elseif string.find(ent:GetClass(), "item_ammo_*") or string.find(ent:GetClass(), "item_box_*") then
            if ent.AutoSpawnable then
                self.TeleEnts[ent:EntIndex()] = createTeleEntry(ent)
            end
        end
    end
    --PrintTable(self.TeleEnts)
end


-- General Initialization

function SWEP:ShopInit()
    AddToShopFallback(STALKER.fallbackTable, ROLE_STALKER, self)
    --AddWeaponIntoFallbackTable(self.id, STALKER)
end

function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)

    self:InitializeTeleEnts()

    if CLIENT then
        self:AddTTT2HUDHelp("weapon_ttt_slk_tele_help_pri", "weapon_ttt_slk_tele_help_sec")

        net.Start("RequestMassList")
        net.SendToServer()

        net.ReceiveStream("SendMassList", function(masses)
            for ent_index, mass in pairs(masses) do
                --print(ent_index, mass)
                local ent = self.TeleEnts[ent_index]
                if ent then
                    ent.Mass = mass
                    ent.Ent.Mass = mass
                end

                -- local ent = ents.GetByIndex(ent_index)

                -- if IsValid(ent) then
                --     --print("Mass of ent:", ent:GetClass(), ent.Mass, mass)
                --     ent.Mass = mass
                -- end
            end
            --PrintTable(self.TeleEnts)
        end)


    -- if SERVER
    else
        net.Receive("RequestMassList", function(len, ply)
            --print("requested physics list")
            local masses = {}
            for index, entry in pairs(self.TeleEnts) do
                local ent = entry.Ent
                local phys = ent:GetPhysicsObject()
                if IsValid(phys) then
                    local mass = phys:GetMass()
                    ent.Mass = mass
                    entry.Mass = mass
                    masses[index] = mass
                end
            end

            net.SendStream("SendMassList", masses, ply)
        end)
    end
end


function SWEP:Equip(owner)
    if not SERVER or not owner then return end
    owner:DrawWorldModel(false)
end

------------------------------------------------
-------------------- Think --------------------- 
------------------------------------------------

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) or owner:GetSubRole() ~= ROLE_STALKER or not owner:GetNWBool("ttt2_hd_stalker_mode", false) then return end

    if not owner:GetNWBool("ttt2_slk_tele_active") then

        -- On Client Side, if 
        if CLIENT and owner.FindNewHighlightObject then
            owner.HighlightObject = self:FindTeleObject()

            if IsValid(owner.HighlightObject) then
                --print("Add highlight for:", owner.HighlightObject:GetClass(), "with Mass:", owner.HighlightObject.Mass)
                owner:SetManaCost(self:CalculateManaCost(owner.HighlightObject))
            else
                owner:SetManaCost(nil)
            end

        end

        -- Calculating Ammuntion
        local mana_cost = CLIENT and owner:GetManaCost() or self.Secondary.Mana + self.Primary.ManaMin

        local ammo = math.Clamp(math.floor(owner:GetMana() / mana_cost) - self:Clip1(), 0, 10)
        owner:SetAmmo(ammo, self:GetPrimaryAmmoType())

        if owner:GetMana() < mana_cost then
            self:SetClip1(0)
        return end

        if self:GetNextSecondaryFire() > CurTime() then
            --print("NextSecondaryFire not valid:", self:GetNextSecondaryFire())
        return end

        self:SetClip1(1)

    else 
        self:SetClip1(0)
        if CLIENT and owner.HighlightObject then
            owner:SetManaCost(self:CalculateManaCost(owner.HighlightObject, true))
            owner.HighlightObject = nil
        end
    end
end

function SWEP:Reload() end


function SWEP:CanSecondaryAttack()
    -- if self:GetOwner():GetMana() < (self.Primary.Mana + self.Secondary.Mana) then
    --     self:SetClip1()
    --     return false
    -- end
    -- print("AmmoCOunt:", self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()))
    -- if self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()) < 1 then
    --     self:GetOwner():EmitSound( self.Primary.MissSound, 40, 250 )
    -- return false
    -- end
    if self:Clip1() < 1 then
        --print("not enough ammo:", self:Clip1())
        self:GetOwner():EmitSound( self.Primary.MissSound, 40, 250 )
        self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
        return false
    end

    return true
end

-- end
function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) or owner:GetSubRole() ~= ROLE_STALKER or not owner:GetNWBool("ttt2_hd_stalker_mode", false) then return end

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    if self:LaunchTele() then
        self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

        if SERVER then
            owner:SetNWBool("ttt2_slk_tele_active", false)
            owner:AddMana(-owner:GetManaCost())
        end
    end

    return true
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) or owner:GetSubRole() ~= ROLE_STALKER or not owner:GetNWBool("ttt2_hd_stalker_mode", false) then return end
    if not self:CanSecondaryAttack() then return end

    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

    -- local tgt, spos, sdest, trace = self:MeleeTrace()
    -- print("target:", tgt, "pos:", spos, "destination:", sdest, "trace:", trace)
    -- if IsValid(tgt) then
    if self:StartTele() then
        self:SetClip1(0)
        --owner:SetAmmo(owner:GetAmmoCount(self:GetPrimaryAmmoType()) - 1, self:GetPrimaryAmmoType())
        if SERVER then
            owner:SetNWBool("ttt2_slk_tele_active", true)
            owner:AddMana(-self.Secondary.Mana)

        end
    end
    --owner:LagCompensation(false)
end

-- Checks wether telekinesis can be used on an object
function SWEP:CanTele(ent, phys)
    -- TODO: Test for Mana
    -- return canTele, enoughMana


    if (self.TeleEnts[ent:EntIndex()] or ent:IsRagdoll() ) and not IsValid(ent:GetParent()) and not IsValid(ent:GetOwner()) then
        if SERVER then
            if IsValid(phys) and phys:IsMotionEnabled() and phys:IsMoveable() then
                --print("!!! Class of Object: " .. ent:GetClass() .. ",  with mass: " .. tostring(phys:GetMass()))
                return true
            end
        else
            return true
        end
    end

    print("Cannot Tele: FALSE")
end

-- Turnes Prop into controlled prop
function SWEP:CreateTeleProp(ent)
    local owner = self:GetOwner()
    --print("Turn Prop into CreateTeleProp")
    ent.Tele = true
    local psy = ents.Create("ttt_tele_object")
    psy:SetOwner(owner)
    psy:SetAngles(ent:GetAngles())
    psy:SetProp(ent)

    if ent:IsRagdoll() then
        psy:SetTrueParent(ent)
        psy:SetCollides(true)
        psy:SetPos(ent:LocalToWorld(ent:OBBCenter()))
        psy:SetModel("models/props_junk/propanecanister001a.mdl")
        -- Hard coding Mass of Object
    elseif string.find(ent:GetClass(), "prop_phys") then
        psy:SetParent(ent)
        psy:SetModel(ent:GetModel())
        psy:SetPos(ent:GetPos())
    else
        psy:SetTrueParent(ent)
        --ent:SetParent(psy)
        psy:SetPsyOnly(true)
        psy:SetCollides(true)
        psy:SetModel(ent:GetModel())
        psy:SetPos(ent:GetPos())
    end

    local phys = ent:GetPhysicsObject()

    if IsValid(phys) then
        --print("Set Mass for Object", ent, "mass:", math.Clamp(phys:GetMass(), 10, 200))
        if not ent:IsRagdoll() then
            psy:SetMass(math.Clamp(phys:GetMass(), 10, 200))
        else
            psy:SetMass(85)
        end
        psy:SetPhysMat(phys:GetMaterial())
    else
        --print("!!!! no physics Object available", ent:GetClass())
        psy:SetMass()
    end

    psy:Spawn()
    psy:Activate()
    self.Psy = psy
    owner:EmitSound(self.Primary.TeleSound, 50)
    -- net.Start("Flay")
    -- net.Send(owner)
end

-- Lanches Object, if one is controlled with telekinesis
function SWEP:LaunchTele()
    if IsValid(self.Psy) then
        local ply_tr = util.GetPlayerTrace(self:GetOwner())
        ply_tr.filter = {self:GetOwner(), self.Psy, self.Psy.Prop}
        
        local tr = util.TraceLine(ply_tr)

        --print("LaunchTele is carried out!")
        self.Psy:EmitSound(self.Primary.TeleShotSound, 100, math.random(100, 120))
        self.Psy:SetLaunchTarget(tr.HitPos)
        self.Psy = nil

        return true
    end
end

-- Starks Telekinesis process of an object
function SWEP:StartTele()
    local owner = self:GetOwner()
    -- create Trace in the direction the player is looking in. 
    -- restrict distance to self.MaxDistance
    local ent = self:FindTeleObject()

    if IsValid(ent) and owner:GetMana() >= self:CalculateManaCost(ent) then
        if SERVER then
            self:CreateTeleProp(ent)
            print("Mana Cost:", self:CalculateManaCost(ent, true), "of Entity:", ent)
            owner:SetManaCost(self:CalculateManaCost(ent, true))
        end

        return true
    end

    owner:EmitSound(self.Primary.MissSound, 50, 250)
    return false
end



function SWEP:FindTeleObject()
    local owner = self:GetOwner()
    local spos  = owner:GetShootPos()
    local sdest = spos + (owner:GetAimVector() * self.MaxDistance)

    --filter = table.insert(filter, self)
    local tr = util.TraceLine({
        start = spos,
        endpos = sdest,
        filter = owner,
        mask = MASK_SHOT_HULL,
    })

    if IsValid(tr.Entity) then
        if SERVER then
            local phys = tr.Entity:GetPhysicsObject()
            if IsValid(phys) and self:CanTele(tr.Entity, phys) then
                --print("Found Object Line Trace")
                return tr.Entity
            end
        else
            if self:CanTele(tr.Entity) then
                --print("Found Object Line Trace")
                return tr.Entity
            end
        end
    end

    -- local dist = 50

    -- using Hull Trace

    -- local tr = util.TraceHull( {
    --     start = spos,
    --     endpos = sdest,
    --     filter = self,
    --     mask = MASK_SHOT_HULL,
    --     maxs =  Vector(dist, dist, dist),
    --     mins = -Vector(dist, dist, dist),
    -- } )


    -- if ( tr.Hit ) then
    --     print("HullTrace hit:", tr.Entity)
    --     return ent
    -- end

    --print("Try Surounding")

    -- using FindByClass

    -- local dist = 50
    -- local sel_ent
    -- local tbl = ents.FindByClass("prop_phys*")
    -- tbl = table.Add(tbl, ents.FindByClass("prop_ragdoll"))

    -- for k, ent in pairs(tbl) do
    --     print("test:", ent:GetClass())
    --     local phys = ent:GetPhysicsObject()

    --     -- HitPos is EndPos if trace hit nothing
    --     print("distance:", ent:GetPos():Distance(tr.HitPos))
    --     if ent:GetPos():DistToSqr(tr.HitPos) < dist^2 and not IsValid(ent:GetParent()) and self:CanTele(ent, phys) then
    --         sel_ent = ent
    --         print("found entity:", sel_ent:GetClass())
    --         dist = ent:GetPos():Distance(tr.HitPos)
    --     end
    -- end

    -- FindInSphere
    local dist = self.FindObjectDistance
    local sel_ent
    tbl = ents.FindInSphere(tr.HitPos, dist)

    for k, ent in pairs(tbl) do
        --print("test:", ent:GetClass(), ent)
        if not (self.TeleEnts[ent:EntIndex()] or ent:IsRagdoll()) then continue end--if ent:GetClass() ~= "prop_physics" and ent:GetClass() ~= "prop_ragdoll" and not string.find(ent:GetClass(), "item_ammo") then continue end -- and not string.find(ent:GetClass(), "item_ammo")

        if SERVER then
            local phys = ent:GetPhysicsObject()

            -- HitPos is EndPos if trace hit nothing
            --print("distance:", ent:GetPos():Distance(tr.HitPos))
            if ent:GetPos():DistToSqr(tr.HitPos) < dist^2 and self:CanTele(ent, phys) then
                sel_ent = ent
                --print("found entity:", sel_ent:GetClass())
                dist = ent:GetPos():Distance(tr.HitPos)
            end
        else
            if ent:GetPos():DistToSqr(tr.HitPos) < dist^2 and self:CanTele(ent) then
                sel_ent = ent
                --print("found entity:", sel_ent:GetClass())
                dist = ent:GetPos():Distance(tr.HitPos)
            end
        end
    end

    return sel_ent

end



function SWEP:CalculateManaCost(ent, only_shot)
    if not IsValid(ent) then return end

    local mass = ent.Mass

    if not mass then
        if not ent:IsRagdoll() then
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                mass = phys:GetMass()
            else
                mass = 50
            end
        else
            mass = 85
        end
    end

    --print("Mass = " .. tostring(mass), "ent:", ent)

    local mana_cost =  math.Clamp(mass / 3, self.Primary.ManaMin, self.Primary.ManaMax)

    if not only_shot then mana_cost = mana_cost + self.Secondary.Mana end

    return math.Round(mana_cost)
end





if CLIENT then
    local TryT = LANG.TryTranslation
	local ParT = LANG.GetParamTranslation

    local function drawOutline()
        local ply = LocalPlayer()

        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then return end
        if ply:GetSubRole() ~= ROLE_STALKER or not ply:GetNWBool("ttt2_hd_stalker_mode", false) then return end

        local wep = ply:GetActiveWeapon()

        if wep:GetClass() ~= "weapon_ttt_slk_tele" or ply:GetNWBool("ttt2_slk_tele_active") then
            --print("Tele is aktive:")
        return end

        if IsValid(ply.HighlightObject) then
            if not ply:GetManaCost() then return end
            
            local clr
            if ply:GetMana() < ply:GetManaCost() then
                clr = Color(255, 0, 0)
            else
                clr = Color(0, 255, 0)
            end

            outline.Add(ply.HighlightObject, clr, OUTLINE_MODE_VISIBLE)
            --halo.Add({ ply.HighlightObject }, clr, 0, 0, 3, true, true)
        end
    end

    local function changeTargetID(ent, distance)
        if IsValid(ent) and distance < 300 then return end

        local ply = LocalPlayer()

        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then return end
        if ply:GetSubRole() ~= ROLE_STALKER or not ply:GetNWBool("ttt2_hd_stalker_mode", false) then return end

        local wep = ply:GetActiveWeapon()

        if wep:GetClass() ~= "weapon_ttt_slk_tele" or ply:GetNWBool("ttt2_slk_tele_active") then return end

        if not IsValid(ply.HighlightObject) then return end

        return ply.HighlightObject

    end

    local function drawTargetID(tData)
        local ply = LocalPlayer()

        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then return end
        if ply:GetSubRole() ~= ROLE_STALKER or not ply:GetNWBool("ttt2_hd_stalker_mode", false) then return end

        local wep = ply:GetActiveWeapon()

        if wep:GetClass() ~= "weapon_ttt_slk_tele" or ply:GetNWBool("ttt2_slk_tele_active") then return end

        if not IsValid(ply.HighlightObject) then return end

        local ent = tData:GetEntity()

        if not IsValid(ent) or ent ~= ply.HighlightObject then return end

        tData:EnableText()

        -- TODO: Less Hardcoding
        local name = (ply.HighlightObject.AmmoType and ply.HighlightObject.AmmoType .. TryT("weapon_ttt_slk_tele_target_ammo")) or ply.HighlightObject.PrintName or (ply.HighlightObject:IsRagdoll() and "Ragdoll") or "weapon_ttt_slk_tele_target_prop"

        tData:SetTitle( TryT("weapon_ttt_slk_tele_target_title") )
        tData:SetSubtitle( ParT("weapon_ttt_slk_tele_target_name", {name = TryT(name) or ""}) )
        tData:SetKeyBinding("+attack2")
        tData:AddDescriptionLine( TryT("weapon_ttt_slk_tele_target_desc") )

        tData:AddDescriptionLine(
            ParT("weapon_ttt_slk_tele_target_mana", {mana = ply:GetManaCost()}),
            COLOR_ORANGE
        )

    end

    local function setNewHighlightObject(cmd)
        local ply = LocalPlayer()

        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then return end
        if ply:GetSubRole() ~= ROLE_STALKER then return end
        if ply:GetActiveWeapon():GetClass() ~= "weapon_ttt_slk_tele" or ply:GetNWBool("ttt2_slk_tele_active") then return end
        
        if cmd:GetForwardMove() ~= 0 or cmd:GetSideMove() ~= 0 or cmd:GetMouseX() ~= 0 or cmd:GetMouseY() ~= 0 then
            ply.FindNewHighlightObject = true
        else
            ply.FindNewHighlightObject = false
        end
    end

    function SWEP:Deploy()
        --if SERVER then return true end
        hook.Add("PreDrawHalos", "Stalker:HighlightTeleObjects", drawOutline)
        -- Clear Highlight Object, so the Player needs to look for it again
        hook.Add("CreateMove", "Stalker:RemoveHighlightObject", setNewHighlightObject)

        hook.Add("TTTModifyTargetedEntity", "Stalker:ChangeTargetIDTele", changeTargetID)
        hook.Add("TTTRenderEntityInfo", "Stalker:DrawTargetIDTele", drawTargetID)
        return true
    end

    function SWEP:Holster()
        --if SERVER then return true end
        hook.Remove("PreDrawHalos", "Stalker:HighlightTeleObjects")
        -- Clear Highlight Object, so the Player needs to look for it again
        hook.Remove("CreateMove", "Stalker:RemoveHighlightObject")

        hook.Remove("TTTModifyTargetedEntity", "Stalker:ChangeTargetIDTele")
        hook.Remove("TTTRenderEntityInfo", "Stalker:DrawTargetIDTele")
        return true
    end

    function SWEP:DrawHUD()
        self:DrawHelp()
    end
end