------------------------------------------------------------
-- credits go to: https://github.com/nuke-haus/thestalker -- 
------------------------------------------------------------

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.MaxDamage = 1000
ENT.MinDamage = 30


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

function ENT:SetPsyOnly(bool)
    self.PsyOnly = bool
end

