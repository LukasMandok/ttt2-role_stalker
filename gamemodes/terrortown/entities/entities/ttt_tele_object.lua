ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.MinDamage = 30
ENT.MaxDamage = 100

if SERVER then
    ENT.SpawnSound = Sound("ambient/atmosphere/city_skypass1.wav")

    function ENT:Initialize()
        self.HitEntities = {}
        -- create new separate and invisible physics Object
        print("sucess with physcics Init:", self:PhysicsInit(SOLID_VPHYSICS))
        --self:SetSolid(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)

        -- self:SetCollisionGroup( COLLISION_GROUP_PROJECTILE ) -- This might not be needed
		-- self:SetTrigger(true)	

        -- self:AddCallback( "PhysicsCollide", PhysCallback )

        self:DrawShadow(false)
        local phys = self:GetPhysicsObject()

        -- if IsValid(phys) then
        --     phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
        -- end

        -- if colisions are enabled set solif type -> interacts with other phys objects
        if self.Collides then
            --self:SetSolid(SOLID_VPHYSICS)
            --self:SetSolidFlags(FSOLID_TRIGGER)
            if IsValid(phys) then
                phys:Wake()
                phys:SetMaterial(self.PhysMat)
                phys:EnableGravity(false)
            end
        else
            self:SetSolid(SOLID_NONE)
            if IsValid(phys) then
                phys:Wake()
                phys:SetMaterial(self.PhysMat)
            end
        end

        self.DieTime = CurTime() + 5

        -- setup real object
        local par = self:GetTrueParent()

        if IsValid(par) then

            -- if Ragdoll
            if par:GetClass() == "prop_ragdoll" then
                self.Bloody = true
                par.Cons = {}
                table.insert(par.Cons, constraint.Weld(par, self, 0, 0, 0, true, false))

                -- iterate over all ragdol parts and disable gravity
                for i = 0, 16 do
                    local phys = par:GetPhysicsObjectNum(i)

                    if IsValid(phys) then
                        phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG) --
                        --par:SetSolid(SOLID_NONE) --
                        --par:SetSolidFlags(FSOLID_NOT_SOLID) --

                        phys:EnableGravity(false)
                        phys:Wake()
                        phys:AddAngleVelocity(VectorRand() * 800)
                        table.insert(par.Cons, constraint.NoCollide(self, par, 0, i))
                    end
                end

            -- if normal Physics Object
            else
                local phys = par:GetPhysicsObject()

                if IsValid(phys) then
                    phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG) --
                    --par:SetSolid(SOLID_NONE) --
                    --par:SetSolidFlags(FSOLID_NOT_SOLID) --

                    phys:SetMass(math.Clamp(phys:GetMass(), 10, 200))
                    phys:EnableMotion(true)
                    phys:EnableGravity(false)
                    phys:Wake()
                    phys:AddAngleVelocity(VectorRand() * 800)
                end
            end

            --self:SetModel(par:GetModel())
        end

        
        self:EmitSound(self.SpawnSound, 100, math.random(90, 110))
    end

    function ENT:SetTrueParent(ent)
        self:SetNWEntity("TrueParent", ent)
    end

    function ENT:GetTrueParent()
        if IsValid(self:GetParent()) then
            return self:GetParent()
        elseif IsValid(self:GetNWEntity("TrueParent")) then
            return self:GetNWEntity("TrueParent")
        end

        return NULL
    end

    function ENT:SetCollides(bool)
        self.Collides = bool
    end

    function ENT:SetProp(ent)
        self.Prop = ent
    end

    function ENT:SetMass(mass)
        self.Mass = mass
    end

    function ENT:SetPhysMat(mat)
        self.PhysMat = mat
    end

    function ENT:Think()
        local par = self:GetTrueParent()

        if IsValid(par) then
            local phys = par:GetPhysicsObject()

            -- If Prop has beam Launched, enable Gravity again and apply a force depending on the mass
            if IsValid(phys) and self.LaunchDir and not self.Launched then
                self.Launched = true
                phys:EnableGravity(true)
                phys:AddAngleVelocity(VectorRand() * self.Mass)
                phys:ApplyForceCenter((self.Mass * 2500) * self.LaunchDir)

                if par:GetClass() == "prop_ragdoll" then
                    local phys_i
                    for i = 0, 16 do
                        phys_i = par:GetPhysicsObjectNum(i)

                        if IsValid(phys_i) then
                            phys_i:EnableGravity(true)
                            phys_i:Wake()
                        end
                    end
                end

                -- If prop should collide also update information of the new phys object
                if self.Collides then
                    phys = self:GetPhysicsObject()

                    if IsValid(phys) then
                        phys:EnableGravity(true)
                        phys:ApplyForceCenter((self.Mass * 2500) * self.LaunchDir) --9000
                    end
                end
            end
        end

        if self.DieTime < CurTime() or not IsValid(par) or not self:GetOwner():Alive() then
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
        print("OnRemove Object")
        self:GetOwner():SetNWBool("ttt2_slk_tele_active", false)
        local par = self:GetTrueParent()

        if IsValid(par) then
            if par:GetClass() == "prop_ragdoll" then
                for k, v in pairs(par.Cons) do
                    if IsValid(v) then
                        v:Remove()
                    end
                end
            end

            par.Tele = nil
            self.Prop = nil
            local phys = par:GetPhysicsObject()

            if IsValid(phys) then
                phys:EnableGravity(true)
                phys:Wake()
            end
        end
    end

    function ENT:OnTakeDamage(dmginfo)
        print("Entity takes damage:", dmginfo)
    end

    function ENT:DamagePlayer(target, mass, speed, dir, pos)
        local dmg = DamageInfo()

        damage = math.Clamp(mass * speed * 0.001 * 3, self.MinDamage, self.MaxDamage)

        print("\tdamage = ", tostring(math.Round(damage)))

        dmg:SetDamage(damage)
        dmg:SetAttacker(self:GetOwner())
        dmg:SetInflictor(self:GetTrueParent())
        dmg:SetDamageForce(dir)
        dmg:SetDamagePosition(pos)
        dmg:SetDamageType(DMG_DIRECT) --DMG_CRUSH

        target:TakeDamageInfo(dmg)
    end

    function ENT:PhysicsCollide(data, phys)
        if self.Collides and data.DeltaTime > 0.15 then
            self:EmitSound("Flesh.ImpactHard", 100, math.random(80, 100))
            util.Decal("Blood", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal)
        end
        print("\nImpact of:", phys, "mass = " .. tostring(phys:GetMass()) .. "  target:", data.HitEntity, "speed = " .. tostring(math.Round(data.Speed)))
       -- PrintTable(data) -- , "interia =", phys:GetInertia() --"vel =", phys:GetVelocity(), 

        local target = data.HitEntity

        if not target:IsPlayer() or self.HitEntities[target] then return end

        self.HitEntities[target] = true
        
        local mass = phys:GetMass()
        local speed = data.Speed
        local dir = data.OurOldVelocity
        dir:Normalize()
        local pos = data.HitPos

        self:DamagePlayer(target, mass, speed, dir, pos)
        -- print("FVPHYSICS_CONSTRAINT_STATIC", phys:HasGameFlag(FVPHYSICS_CONSTRAINT_STATIC))
        -- print("FVPHYSICS_HEAVY_OBJECT", phys:HasGameFlag(FVPHYSICS_HEAVY_OBJECT))
        -- print("FVPHYSICS_MULTIOBJECT_ENTITY", phys:HasGameFlag(FVPHYSICS_MULTIOBJECT_ENTITY))
        -- print("FVPHYSICS_NO_IMPACT_DMG", phys:HasGameFlag(FVPHYSICS_NO_IMPACT_DMG))
        -- print("FVPHYSICS_NO_PLAYER_PICKUP", phys:HasGameFlag(FVPHYSICS_NO_PLAYER_PICKUP))
        -- print("FVPHYSICS_NO_SELF_COLLISIONS", phys:HasGameFlag(FVPHYSICS_NO_SELF_COLLISIONS))
        -- print("FVPHYSICS_PENETRATING", phys:HasGameFlag(FVPHYSICS_PENETRATING))
        -- print("FVPHYSICS_PLAYER_HELD", phys:HasGameFlag(FVPHYSICS_PLAYER_HELD))
        -- print("FVPHYSICS_WAS_THROWN", phys:HasGameFlag(FVPHYSICS_WAS_THROWN))
        -- print("FVPHYSICS_PART_OF_RAGDOLL", phys:HasGameFlag(FVPHYSICS_PART_OF_RAGDOLL))
    end

    -- function ENT:PhysCallback(data, phys)
    --     print("phys callback:", phys, "collides with:", data.HitEntity)
    -- end

    function ENT:UpdateTransmitState()
        return TRANSMIT_ALWAYS
    end
end

if CLIENT then
    ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

    function ENT:Initialize()
        self:SetRenderMode(RENDERMODE_TRANSALPHA)
    end

    function ENT:OnRemove()
        self:DieEffect()
    end

    function ENT:DieEffect()
        local min = self:LocalToWorld(self:OBBMins())
        local max = self:LocalToWorld(self:OBBMaxs())
        local emitter = ParticleEmitter(self:GetPos())

        for i = 1, math.Clamp(self:BoundingRadius(), 10, 100) do
            local pos = Vector(math.Rand(min.x, max.x), math.Rand(min.y, max.y), math.Rand(min.z, max.z))
            local norm = (pos - (self:LocalToWorld(self:OBBCenter()))):GetNormal()
            local particle = emitter:Add("effects/yellowflare", pos)
            particle:SetVelocity(norm * math.random(50, 100))
            particle:SetDieTime(math.Rand(1.5, 2.5))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(3, 6))
            particle:SetEndSize(0)
            particle:SetRoll(0)
            particle:SetColor(100, 200, 255)
            particle:SetCollide(true)
            particle:SetBounce(1.0)
            particle:SetAirResistance(50)
            particle:SetVelocityScale(true)
            particle:SetGravity(Vector(0, 0, 0))
        end

        emitter:Finish()
    end

    function ENT:Think()
        self.Alpha = math.sin(CurTime() * 2.5) * 50 + 50
        self:SetColor(Color(255, 255, 255, math.Clamp(self.Alpha, 5, 255)))
    end

    local matLight = Material("models/spawn_effect2")

    function ENT:Draw()
        local eyenorm = self:GetPos() - EyePos()
        local dist = eyenorm:Length()
        eyenorm:Normalize()
        local pos = EyePos() + eyenorm * dist * 0.01

        if IsValid(self:GetNWEntity("TrueParent")) then
            cam.Start3D(pos, EyeAngles())
            render.MaterialOverride(matLight)
            self:GetNWEntity("TrueParent"):DrawModel()
            --self:DrawModel()
            render.MaterialOverride(0)
            cam.End3D()
        elseif IsValid(self:GetParent()) then
            cam.Start3D(pos, EyeAngles())
            render.MaterialOverride(matLight)
            self:DrawModel()
            render.MaterialOverride(0)
            cam.End3D()
        end
    end
end