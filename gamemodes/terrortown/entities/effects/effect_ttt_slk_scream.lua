-- maybe make a convar for that
EFFECT.Duration = 10

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()

    if not LocalPlayer():Alive() or LocalPlayer():GetPos():Distance( self.Pos ) > 50 or LocalPlayer():IsSpec() or LocalPlayer():Team() ~= TEAM_STALKER then return end

    DisorientTime = CurTime() + self.Duration
    ViewWobble = 3.5
    MotionBlur = 0.7
    Sharpen = 6.5
end

function EFFECT:Think( )
    return false
end

function EFFECT:Render() end