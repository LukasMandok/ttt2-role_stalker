------------------------------------------------------------
-- credits go to: https://github.com/nuke-haus/thestalker -- 
------------------------------------------------------------

include('shared.lua')

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
    --print("Init Clientside")
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

function ENT:DrawTranslucent()
    --print("Draw entity")
    local eyenorm = self:GetPos() - EyePos()
    local dist = eyenorm:Length()
    eyenorm:Normalize()
    local pos = EyePos() + eyenorm * dist * 0.01

    if IsValid(self:GetNWEntity("TrueParent")) then
        --print("True Parent is valid")
        cam.Start3D(pos, EyeAngles())
        if not self:GetNWEntity("TrueParent"):IsRagdoll() then
            --print("DrawModel of parent:", self:GetModel())
            self:DrawModel()
        end
        render.MaterialOverride(matLight)
        self:GetNWEntity("TrueParent"):DrawModel()
        --self:DrawModel()
        render.MaterialOverride(0)
        cam.End3D()
    elseif IsValid(self:GetParent()) then
        --print("Parent is valid")
        cam.Start3D(pos, EyeAngles())
        render.MaterialOverride(matLight)
        self:DrawModel()
        render.MaterialOverride(0)
        cam.End3D()
    end
end