if engine.ActiveGamemode() ~= "terrortown" then return end

if SERVER then
    AddCSLuaFile()

    resource.AddFile( "models/weapons/zed/v_banshee.mdl" )
    --resource.AddFile( "models/weapons/tfa_echo/c_claws_new.mdl" )

    SWEP.Weight				= 1
    SWEP.AutoSwitchTo		= false
    SWEP.AutoSwitchFrom		= false
end

if CLIENT then
    SWEP.PrintName     = "weapon_ttt_slk_claws_name"

    SWEP.DrawAmmo	   = false -- not needed?

    SWEP.DrawCrosshair = true
    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV  = 74

    SWEP.Slot          = 1
    SWEP.Slotpos       = 1
end


SWEP.Base                  = "weapon_tttbase"

SWEP.ViewModel             = "models/weapons/zed/v_banshee.mdl" --"models/weapons/tfa_echo/c_claws_new.mdl" -- --
SWEP.WorldModel            = ""--"models/weapons/v_banshee.mdl" -- change this! w_pistol
SWEP.HoldType              = "fist" --knife
SWEP.UseHands              = false

SWEP.Kind                  = WEAPON_PISTOL

-- PRIMARY:  Claws Attack
SWEP.Primary.Damage        = 33
SWEP.Primary.Delay         = 0.75
SWEP.Primary.Automatic     = true

SWEP.Primary.ClipSize      = -1
SWEP.Primary.DefaultClip   = -1
SWEP.Primary.Ammo          = "none"

SWEP.Primary.MissSound	   = Sound( "weapons/knife/knife_slash2.wav" )
SWEP.Primary.HitSound      = Sound( "npc/fast_zombie/claw_strike3.wav" )


-- SECONDARY: Claws Push
SWEP.Secondary.Damage      = 10
SWEP.Secondary.HitForce    = 6000
SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"
SWEP.Secondary.Delay       = 3

SWEP.Secondary.Sound	   = Sound( "weapons/knife/knife_slash2.wav" )
SWEP.Secondary.Hit         = Sound( "npc/fast_zombie/claw_strike3.wav" )


-- TTT2 related
SWEP.HitDistance = 50
SWEP.AllowDrop   = false
SWEP.IsSilent    = true

-- Pull out faster than standard guns
SWEP.DeploySpeed = 2

-- TODO: Richtig Implementieren
SWEP.RegenTime = true

function SWEP:Initialize()
    self:SetWeaponHoldType( self.HoldType )

    if CLIENT then
        self:AddTTT2HUDHelp("weapon_ttt_slk_claws_help_pri", "weapon_ttt_slk_claws_help_sec")
    end
end

function SWEP:Deploy()
    -- local vm = self.GetOwner():GetViewModel()
    -- vm:SendViewModelMatchingSequence( vm:LookupSequence( "idle" ) ) 
    local viewmodel = self:GetOwner():GetViewModel( 0 )
    if ( IsValid( viewmodel ) ) then
        --associate its weapon to us
        viewmodel:SetWeaponModel( self.ViewModel , self )
    end
    self:SendViewModelAnim( ACT_VM_DEPLOY , 0 )

    timer.Simple(1, function()
        self:SendViewModelAnim( ACT_VM_IDLE , 0 )
    end)

    if CLIENT and self:GetOwner():HasEquipmentItem("item_ttt_slk_lifesteal") then
        RECHARGE_STATUS:AddStatus("ttt2_slk_lifesteal_recharge")
    end

    return true
end

function SWEP:Holster()
    local viewmodel1 = self:GetOwner():GetViewModel( 0 )
    if ( IsValid( viewmodel1 ) ) then
        --set its weapon to nil, this way the viewmodel won't show up again
        viewmodel1:SetWeaponModel( self.ViewModel , nil )
    end

    if CLIENT then
        RECHARGE_STATUS:RemoveStatus("ttt2_slk_lifesteal_recharge")
    end

    return true
end

function SWEP:SendViewModelAnim( act , index , rate )
    if ( not game.SinglePlayer() and not IsFirstTimePredicted() ) then return end

    if not isfunction(self:GetOwner().GetViewModel) then return end

    local vm = self:GetOwner():GetViewModel( index )
    --("vm:", vm)
    if ( not IsValid( vm ) ) then return end

    local seq = vm:SelectWeightedSequence( act )
    --print("seq:", seq)
    if ( seq == -1 ) then return end

    vm:SendViewModelMatchingSequence( seq )
    vm:SetPlaybackRate( rate or 1 )
end

function SWEP:Equip(owner)
    if SERVER and owner then

        self:GetOwner():DrawWorldModel( false )
    -- elseif CLIENT then
    --     self:GetOwner():DrawViewModel( true )
    end
    --self.ViewModel = "models/weapons/v_banshee.mdl"
    --self.WorldModel = ""
    -- net.Start("ttt2_hdn_network_wep")
    --     net.WriteEntity(self)
    --     net.WriteString("")
    -- net.Broadcast()
    -- STATUS:RemoveStatus(owner, "ttt2_hdn_knife_recharge")
end

function SWEP:PrimaryAttack()
    -- TODO: Only set this, if the attack hit something.    
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    --self.ViewModel = "models/weapons/v_banshee.mdl"
    local owner = self:GetOwner()

    if not IsValid(owner) or owner:GetSubRole() ~= ROLE_STALKER or not owner:GetNWBool("ttt2_hd_stalker_mode", false) then return end

    owner:LagCompensation(true)

        local tgt, spos, sdest, trace = self:MeleeTrace(self.HitDistance)

        --print("target:", tgt, "pos:", spos, "destination:", sdest, "trace:", trace)

        if IsValid(tgt) and (tgt:IsPlayer() or tgt:IsRagdoll()) then

            --self:SendWeaponAnim(ACT_VM_MISSCENTER)

            local eData = EffectData()
            eData:SetStart(spos)
            eData:SetOrigin(trace.HitPos)
            eData:SetNormal(trace.Normal)
            eData:SetEntity(tgt)

            self:SendViewModelAnim( ACT_VM_PRIMARYATTACK , 0 )
            owner:SetAnimation(PLAYER_ATTACK1)

            tgt:EmitSound( self.Primary.HitSound, 100, math.random(90,110) )
            --self:SendWeaponAnim(ACT_VM_MISSCENTER)

            util.Effect("BloodImpact", eData)
        else
            --owner:SetAnimation(PLAYER_ATTACK1)
            --self:SendWeaponAnim(ACT_VM_MISSCENTER)
            self:SendViewModelAnim( ACT_VM_MISSCENTER , 0 )
            owner:SetAnimation(PLAYER_ATTACK1)

            -- TODO: keine Ahnung
            owner:EmitSound( self.Primary.MissSound, 100, math.random(80,100) )
        end

        -- TODO: Warum brauche ich das?
        --if SERVER then owner:SetAnimation(PLAYER_ATTACK1) end

        if SERVER and trace.Hit and trace.HitNonWorld and IsValid(tgt) then
            self:DealDamage(self.Primary.Damage, tgt, trace, spos, sdest, true)
        end

    owner:LagCompensation(false)
end

function SWEP:SecondaryAttack()
    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
    self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

    --self.ViewModel = "models/weapons/v_banshee.mdl"
    local owner = self:GetOwner()

    if not IsValid(owner) or owner:GetSubRole() ~= ROLE_STALKER or not owner:GetNWBool("ttt2_hd_stalker_mode", false) then return end

    owner:LagCompensation(true)

        local tgt, spos, sdest, trace = self:MeleeTrace(self.HitDistance)

        --print("target:", tgt, "pos:", spos, "destination:", sdest, "trace:", trace)

        if IsValid(tgt) then

            --self:SendWeaponAnim(ACT_VM_MISSCENTER)
            -- local eData = EffectData()
            -- eData:SetStart(spos)
            -- eData:SetOrigin(trace.HitPos)
            -- eData:SetNormal(trace.Normal)
            -- eData:SetEntity(tgt)

            -- self:SendWeaponAnim( ACT_VM_HITCENTER )
            self:SendViewModelAnim( ACT_VM_HITCENTER , 0 )
            owner:SetAnimation(PLAYER_ATTACK1)

            tgt:EmitSound( self.Secondary.Hit, 100, math.random(90,110) )

            self:PushObject(tgt, trace, self.Secondary.HitForce)
            -- if tgt:IsPlayer()

            -- elseif tgt:IsRagdoll() then
            --     owner:SetAnimation(PLAYER_ATTACK1)

            --     self:SendWeaponAnim( ACT_VM_HITCENTER )
            --     tgt:EmitSound( self.Secondary.Hit, 100, math.random(90,110) )
            --     --self:SendWeaponAnim(ACT_VM_MISSCENTER)


            --     local phys = tgt:GetPhysicsObject()

            --     if t

            --     -- tgt:SetPhysicsAttacker( self:GetOwner() ) 
            -- 	--phys:Wake()
            -- 	self:PushObject(phys, trace, self.Secondary.HitForce)

            --     --util.Effect("BloodImpact", eData)
            -- end
        else
            -- owner:SetAnimation(PLAYER_ATTACK1)
            -- self:SendWeaponAnim(ACT_VM_MISSCENTER)
            self:SendViewModelAnim( ACT_VM_MISSCENTER , 0 )
            -- TODO: keine Ahnung
            owner:EmitSound( self.Secondary.Sound, 100, math.random(80,100) )
        end

        -- TODO: Warum brauche ich das?
        --if SERVER then owner:SetAnimation(PLAYER_ATTACK1) end

        if SERVER and trace.Hit and trace.HitNonWorld and IsValid(tgt) then
            self:DealDamage(self.Secondary.Damage, tgt, trace, spos, sdest, false)
        end

    owner:LagCompensation(false)

 end


function SWEP:MeleeTrace(hitDistance)

    local owner = self:GetOwner()

    local spos = owner:GetShootPos()
    local sdest = spos + (owner:GetAimVector() * hitDistance)

    local kmins = Vector(1, 1, 1) * -20
    local kmaxs = Vector(1, 1, 1) * 20

    local trace = util.TraceHull({
        start = spos,
        endpos = sdest,
        filter = owner,
        mask = MASK_SHOT_HULL,
        mins = kmins,
        maxs = kmaxs
    })

    -- TODO: not shure about this
    if not IsValid(trace.Entity) then
        trace = util.TraceLine({
            start = spos,
            endpos = sdest,
            filter = owner,
            mask = MASK_SHOT_HULL
        })
    end

    return trace.Entity, spos, sdest, trace
end


function SWEP:DealDamage(damage, tgt, trace, spos, sdest, primary)

    local owner = self:GetOwner()

    local dmg = DamageInfo()
    dmg:SetDamage(damage)
    dmg:SetAttacker(owner)
    dmg:SetInflictor(self)
    dmg:SetDamageForce(owner:GetAimVector() * 5)
    dmg:SetDamagePosition(owner:GetPos())
    dmg:SetDamageType(DMG_SLASH)

    if tgt:IsPlayer() or tgt:IsRagdoll() then
        hook.Run("ttt_slk_claws_hit", owner, tgt, damage, primary)
    end

    tgt:DispatchTraceAttack(dmg, spos + (owner:GetAimVector() * 3), sdest)
end

function SWEP:Murder(trace, spos, sdest)
    local tgt = trace.Entity
    local owner = self:GetOwner()

    local dmg = DamageInfo()
    dmg:SetDamage(2000)
    dmg:SetAttacker(owner)
    dmg:SetInflictor(self)
    dmg:SetDamageForce(owner:GetAimVector())
    dmg:SetDamagePosition(owner:GetPos())
    dmg:SetDamageType(DMG_SLASH)

    local retrace = util.TraceLine({
        start = spos,
        endpos = sdest,
        filter = owner,
        mask = MASK_SHOT_HULL
    })

    if retrace.Entity ~= tgt then
        local center = tgt:LocalToWorld(tgt:OBBCenter())

        retrace = util.TraceLine({
            start = spos,
            endpos = sdest,
            filter = owner,
            mask = MASK_SHOT_HULL
        })
    end

    local bone = retrace.PhysicsBone
    local pos = retrace.HitPos
    local norm = trace.Normal

    local angle = Angle(-28, 0, 0) + norm:Angle()
    angle:RotateAroundAxis(angle:Right(), -90)

    pos = pos - (angle:Forward() * 7)

    tgt.effect_fn = function(rag)
        local moreTrace = util.TraceLine({
            start = pos,
            endpos = pos + norm * 40,
            filter = ignore,
            mask = MASK_SHOT_HULL
        }) 

        if IsValid(moreTrace.Entity) and moreTrace.Entity == rag then
            bone = moreTrace.PhysicsBone
            pos = moreTrace.HitPos
            angle = Angle(-28, 0, 0) + moreTrace.Normal:Angle()
            angle:RotateAroundAxis(angle:Right(), -90)
            pos = pos - (angle:Forward() * 10)
        end

        -- local knife = ents.Create("prop_physics")
        -- knife:SetModel("models/weapons/w_knife_t.mdl")
        -- knife:SetPos(pos)
        -- knife:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        -- knife:SetAngles(angle)

        -- knife.CanPickup = false 

        -- knife:Spawn()

        -- local phys = knife:GetPhysicsObject()

        -- if IsValid(phys) then
        --     phys:EnableCollisions(false)
        -- end

        -- constraint.Weld(rag, knife, bone, 0, 0, true)

        -- rag:CallOnRemove("ttt_knife_cleanup", function()
        --     SafeRemoveEntity(knife)
        -- end)
    end

    tgt:DispatchTraceAttack(dmg, spos + owner:GetAimVector() * 3, sdest)
end

function SWEP:PushObject(tgt, trace, force) -- phys, pdir, maxforce, is_ragdol
    local dir = self:GetOwner():GetEyeTrace(MASK_SHOT).Normal
    --print("Push Target:", tgt, "direction: ", dir)

    local phys = tgt:GetPhysicsObject()

    if IsValid(phys) and not tgt:IsPlayer()     then
        local mass = math.log(math.Clamp(phys:GetMass(), 10, 1000))
        --print("Phys Object has mass:", mass)

        local pushvel = dir * force / mass
        pushvel.z = math.Clamp(pushvel.z, 50, 300)
        --print("Object Push Velocity:", pushvel)
        phys:AddVelocity(pushvel)

    elseif tgt:IsPlayer() then
        local mass = 5

        local pushvel = dir * force / mass
        pushvel.z = math.Clamp(pushvel.z, 50, 300)
        --print("Player Push Velocity:", pushvel)
        tgt:SetVelocity(tgt:GetVelocity() + pushvel)

    end

    if tgt:IsPlayer() then
        tgt.was_pushed = {
            att = self:GetOwner(),
            t = CurTime(),
            wep = self:GetClass(),
            -- infl = self
        }
    end
end


if CLIENT then
    function SWEP:DrawHUD()
        self:DrawHelp()
    end

    -- function SWEP:ShouldDrawViewModel()
    --     return true
    -- end
end