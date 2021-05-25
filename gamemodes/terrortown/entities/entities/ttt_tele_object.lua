ENT.Type = "anim"
ENT.Base = "base_anim"

if SERVER then
    ENT.SpawnSound = Sound("ambient/atmosphere/city_skypass1.wav")

    function ENT:Initialize()
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:DrawShadow(false)
        local phys = self:GetPhysicsObject()

        if self.Collides then
            self:SetSolid(SOLID_VPHYSICS)

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
        local par = self:GetTrueParent()

        if IsValid(par) then
            if par:GetClass() == "prop_ragdoll" then
                self.Bloody = true
                par.Cons = {}
                table.insert(par.Cons, constraint.Weld(par, self, 0, 0, 0, true, false))

                for i = 0, 16 do
                    local phys = par:GetPhysicsObjectNum(i)

                    if IsValid(phys) then
                        phys:EnableGravity(false)
                        phys:Wake()
                        phys:AddAngleVelocity(VectorRand() * 800)
                        --phys:SetMass( 10 )
                        table.insert(par.Cons, constraint.NoCollide(self, par, 0, i))
                    end
                end
            else
                local phys = par:GetPhysicsObject()

                if IsValid(phys) then
                    phys:SetMass(math.Clamp(phys:GetMass(), 100, 5000))
                    phys:EnableMotion(true)
                    phys:EnableGravity(false)
                    phys:Wake()
                    phys:AddAngleVelocity(VectorRand() * 800)
                end
            end
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

                if self.Collides then
                    phys = self:GetPhysicsObject()

                    if IsValid(phys) then
                        phys:EnableGravity(true)
                        phys:ApplyForceCenter((self.Mass * 9000) * self.LaunchDir)
                    end
                end
            end
        end

        if self.DieTime < CurTime() or not IsValid(self:GetTrueParent()) or not self:GetOwner():Alive() then
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
            local phys = par:GetPhysicsObject()

            if IsValid(phys) then
                phys:EnableGravity(true)
                phys:Wake()
            end
        end
    end

    function ENT:OnTakeDamage(dmginfo)
    end

    function ENT:PhysicsCollide(data, phys)
        if self.Collides and data.DeltaTime > 0.15 then
            self:EmitSound("Flesh.ImpactHard", 100, math.random(80, 100))
            util.Decal("Blood", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal)
        end
    end

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