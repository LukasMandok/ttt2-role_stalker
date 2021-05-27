-- maybe make a convar for that
EFFECT.Duration = 4

local ColorMod = {}
    ColorMod = {}
    ColorMod[ "$pp_colour_addr" ] = 0.05
    ColorMod[ "$pp_colour_addg" ] = 0
    ColorMod[ "$pp_colour_addb" ] = 0
    ColorMod[ "$pp_colour_mulr" ] = 1
    ColorMod[ "$pp_colour_mulg" ] = 1
    ColorMod[ "$pp_colour_mulb" ] = 1

function EFFECT:Init(data)
    self:SetPos(LocalPlayer():GetPos()) --data:GetOrigin())

    -- if not LocalPlayer():Alive() or LocalPlayer():GetPos():Distance( self.Pos ) > 50 or LocalPlayer():IsSpec() or LocalPlayer():Team() == TEAM_STALKER then 
    --     print("does not affect", LocalPlayer():Nick())
    --     return
    -- end

    if LocalPlayer() ~= data:GetEntity() or not LocalPlayer():Alive() or LocalPlayer():IsSpec() or LocalPlayer():Team() == TEAM_STALKER then 
        print("does not affect", LocalPlayer():Nick())
        self:Remove()
        return
    end

    print("Start Effect")


    self.StartTime = CurTime()
end

function EFFECT:Think( )
    self:SetPos(LocalPlayer():GetPos())
    print("Think:", self.StartTime and self.StartTime + self.Duration > CurTime() or false)
    return self.StartTime and self.StartTime + self.Duration > CurTime() or false
end

function EFFECT:Render()
    print("Render Effect")
    local add = 0.2
    local draw = 1
    local delay = 0.01
    DrawMotionBlur(add, draw, delay)

    local modifier = 1 - (CurTime() - self.StartTime) / self.Duration

    ColorMod[ "$pp_colour_brightness" ] = 0.5 * modifier
    ColorMod[ "$pp_colour_contrast" ] = 1 + 0.3 * modifier
    ColorMod[ "$pp_colour_colour" ] = 1.0 + 0.5 * modifier

    DrawColorModify(ColorMod)
end