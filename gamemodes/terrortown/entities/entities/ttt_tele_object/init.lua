AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.SpawnSound = Sound("ambient/atmosphere/city_skypass1.wav")

function ENT:Initialize()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:DrawShadow(false)

    --self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )

    self.HitEntities = {}

    local phys = self:GetPhysicsObject()

    if self.Collides then
        self:SetSolid(SOLID_VPHYSICS)

        if IsValid(phys) then
            phys:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
            phys:Wake()
            phys:SetMaterial(self.PhysMat)
            phys:EnableGravity(false)

            if self.PsyOnly then
                phys:AddAngleVelocity(VectorRand() * 800)
            end
        end
    else
        self:SetSolid(SOLID_NONE)

        if IsValid(phys) then
            phys:Wake()
            phys:SetMaterial(self.PhysMat)
        end
    end

    self.DieTime = CurTime() + 5
    local par = self:GetTrueParent()

    if IsValid(par) then

        if par:IsRagdoll() then

            self.Bloody = true
            par.Cons = {}
            table.insert(par.Cons, constraint.Weld(par, self, 0, 0, 0, true, false))

            for i = 0, 16 do
                local phys_i = par:GetPhysicsObjectNum(i)

                if IsValid(phys_i) then
                    phys_i:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)

                    phys_i:EnableGravity(false)
                    phys_i:Wake()
                    phys_i:AddAngleVelocity(VectorRand() * 800)
                    --phys:SetMass( 10 )
                    table.insert(par.Cons, constraint.NoCollide(self, par, 0, i))
                end
            end
        else
            if self.PsyOnly then
                --print("SetMoveParent")
                par:SetParent(self)
                --ent.CanPickup = false
            else
                        --print("Origional Solid Type:", par:GetSolid(), par:GetSolidFlags(), "new:", SOLID_VPHYSICS)
            --print("Origional Move Type:", par:GetMoveType(), "new:", MOVETYPE_VPHYSICS)
            -- par:SetSolid(SOLID_VPHYSICS)
            -- par:SetMoveType(MOVETYPE_VPHYSICS)
            -- par:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
            -- par:SetCustomCollisionCheck( true )

            local phys = par:GetPhysicsObject()

            if IsValid(phys) then
                phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)

                --print("Is Collsion enabled:",  phys:IsCollisionEnabled())
                
                phys:SetMass(math.Clamp(phys:GetMass(), 10, 200))
                phys:EnableMotion(true)
                phys:EnableGravity(false)
                phys:Wake()
                if not self.PsyOnly then
                    phys:AddAngleVelocity(VectorRand() * 800)
                end
            else
                print("Has no physics Object")
            end
            end
        end

        if not self.Collides then --and not self.Inverted
            self.CallbackID = par:AddCallback("PhysicsCollide", function (ent, data)
                --print("Collide")
                self:PhysicsParCollide(ent:GetPhysicsObject(), data)
            end )
        end
    end

    self:EmitSound(self.SpawnSound, 100, math.random(90, 110))
end

function ENT:SetTrueParent(ent)
    self:SetNWEntity("TrueParent", ent)
end

function ENT:GetTrueParent()
    if IsValid(self:GetNWEntity("TrueParent")) then
        return self:GetNWEntity("TrueParent")
    elseif IsValid(self:GetParent()) then
        return self:GetParent()
    end

    return NULL
end

function ENT:Think()
   
    -- If Prop has beam Launched, enable Gravity again and apply a force depending on the mass
    if self.LaunchDir and not self.Launched then
        self.Launched = true

        local par = self:GetTrueParent()

        if IsValid(par) and not self.PsyOnly then

            local phys = par:GetPhysicsObject()

            if IsValid(phys) then

                phys:EnableGravity(true)
                phys:AddAngleVelocity(VectorRand() * self.Mass)
                phys:ApplyForceCenter((self.Mass * 2500) * self.LaunchDir)

                if par:IsRagdoll() then
                    local phys_i
                    for i = 0, 16 do
                        phys_i = par:GetPhysicsObjectNum(i)

                        if IsValid(phys_i) then
                            phys_i:EnableGravity(true)
                            phys_i:Wake()
                        end
                    end
                end
            end
        end

        if self.Collides then
            phys = self:GetPhysicsObject()

            if IsValid(phys) then
                phys:EnableGravity(true)
                phys:AddAngleVelocity(VectorRand() * self.Mass)
                phys:ApplyForceCenter((self.Mass * 9000) * self.LaunchDir)
            end
        end
    end

    if self.DieTime < CurTime() or not IsValid(self:GetTrueParent()) or not (self:GetOwner() and self:GetOwner():Alive()) or (not self:GetTrueParent().Tele)  then
        self:Remove()
    end
end

function ENT:SetLaunchTarget(pos)
    local dir = (pos - self:GetPos()):GetNormal()
    dir.z = math.Clamp(dir.z, -0.5, 1.0)
    self.LaunchDir = dir
    self.DieTime = CurTime() + 2
end

function ENT:OnRemove()
    --print("OnRemove Object")
    self:GetOwner():SetNWBool("ttt2_slk_tele_active", false)
    local par = self:GetTrueParent()

    if IsValid(par) then
        if self.PsyOnly then
            --print("RemoveParent", par:GetParent(), par:GetMoveParent())
            par:SetParent()
            par:SetPos( self:GetPos() )
            par:SetAngles( self:GetAngles() )
            par:SetVelocity( self:GetVelocity() )
            par:SetLocalAngularVelocity (self:GetLocalAngularVelocity() )

            -- local phys = par:GetPhysicsObject()
            -- if IsValid(phys) then
            --     phys:SetLocalAngularVelocity(Angle angVel)
            -- end
        end

        if self.CallbackID then
            par:RemoveCallback("PhysicsCollide", self.CallbackID)
        end
    
        if par:IsRagdoll() then
            for k, v in pairs(par.Cons) do
                if IsValid(v) then
                    v:Remove()
                end
            end
            -- par:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
            -- par:SetCustomCollisionCheck( true )

        end

        self.Prop = nil
        par.Tele = nil

        local phys = par:GetPhysicsObject()

        if IsValid(phys) then
            phys:EnableGravity(true)
            phys:Wake()

            if par:IsRagdoll() then
                local phys_i
                for i = 0, 16 do
                    phys_i = par:GetPhysicsObjectNum(i)

                    if IsValid(phys_i) then
                        phys_i:EnableGravity(true)
                        phys_i:Wake()
                    end
                end
            end
        end
    end
end

function ENT:OnTakeDamage(dmginfo)
end

function ENT:DamagePlayer(target, mass, speed, dir, pos, norm)
    self:EmitSound("Flesh.ImpactHard", 100, math.random(80, 100))
    util.Decal("Blood", pos + norm, pos - norm)

    local dmg = DamageInfo()

    damage = math.Clamp(mass * speed * 0.002 , self.MinDamage, self.MaxDamage)

    print("mass = " .. tostring(mass), "speed = " .. tostring(speed))
    print("\t-> damage = ", tostring(math.Round(damage)))

    dmg:SetDamage(damage)
    dmg:SetAttacker(self:GetOwner())
    dmg:SetInflictor(self:GetTrueParent())
    dmg:SetDamageForce(dir)
    dmg:SetDamagePosition(pos)
    dmg:SetDamageType(DMG_DIRECT) --DMG_CRUSH

    target:TakeDamageInfo(dmg)
end

function ENT:PhysicsParCollide(phys, data)
    --print("self:", self, "phys:", phys, "data:", data)
    --print("mass = ", phys:GetMass(), "  target:", data.HitEntity, "speed = " .. tostring(math.Round(data.Speed)))

    local target = data.HitEntity

    if not target:IsPlayer() or self.HitEntities[target] then return end

    self.HitEntities[target] = true
    
    local mass = phys:GetMass()
    local speed = data.Speed
    local dir = data.OurOldVelocity
    dir:Normalize()
    local pos = data.HitPos
    local norm = data.HitNormal

    self:DamagePlayer(target, mass, speed, dir, pos, norm)
end

function ENT:PhysicsCollide(data, phys)
    --print("psy collide", data.HitEntity)
    -- if self:IsRagdoll() and data.DeltaTime > 0.15 then
        
    -- end

    local target = data.HitEntity

    if not target:IsPlayer() or self.HitEntities[target] then return end

    self.HitEntities[target] = true
    
    local mass = phys:GetMass()
    local speed = data.Speed
    local dir = data.OurOldVelocity
    dir:Normalize()
    local pos = data.HitPos
    local norm = data.HitNormal

    self:DamagePlayer(target, mass, speed, dir, pos, norm)
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

-- hook.Add("PlayerCanPickupWeapon", "PreventPickupTeleWep", function(ply, wep)
--     if wep.Tele == true then 
--         return false 
--     end
-- end)

-- hook.Add("TTTCanPickupAmmo", "PreventPickupTeleAmmo", function(ply, ammo)
--     if ammo.Tele == true then 
--         return false
--     end
-- end)

hook.Add("WeaponEquip", "ChangeTelePropertyIfPickedUp", function( wep, ply )
    if wep.Tele == true then
        wep.Tele = nil
    end
end)