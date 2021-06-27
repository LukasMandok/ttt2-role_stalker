hook.Add("Initialize", "TTT2Stalker:InitializeStatus", function()
    RECHARGE_STATUS:RegisterStatus("ttt2_slk_invisbility", {
        ready = {
            hud = Material("vgui/ttt/hud/hud_icon_slk_cloak_fading"),
            type = "good",
            DrawInfo = function()
                local ply = LocalPlayer()
                local val = ply:GetNWInt("ttt2_slk_cloak_strength")

                if val then
                    return tostring(math.Round(val)) .. "%"
                elseif ply:Health() >= ply:GetMaxHealth() - 25 then
                    return tostring(100) .. "%"
                else
                    return tostring(math.Round(math.Clamp((ply:Health() / (ply:GetMaxHealth() - 25) * 100), 0, 50))) .. "%"
                end
            end
        },
        recharge = {
            hud = Material("vgui/ttt/hud/hud_icon_slk_cloak"),
            type = "bad",
            DrawInfo = function()
                local ply = LocalPlayer()
                local val = ply:GetNWInt("ttt2_slk_cloak_strength")

                if val then
                    return tostring(math.Round(val)) .. "%"
                elseif ply:Health() >= ply:GetMaxHealth() - 25 then
                    return tostring(100) .. "%"
                else
                    return tostring(math.Round(math.Clamp((ply:Health() / (ply:GetMaxHealth() - 25) * 100), 0, 50))) .. "%"
                end
            end
        }
    })

    RECHARGE_STATUS:RegisterStatus("ttt2_slk_lifesteal_recharge", {
        ready = {
            hud = Material("vgui/ttt/hud/hud_icon_slk_lifesteal.vmt"),
            type = "good"
        },
        recharge = {
            hud = Material("vgui/ttt/hud/hud_icon_slk_lifesteal.vmt"),
            type = "bad"
        }
    })

    RECHARGE_STATUS:RegisterStatus("ttt2_slk_tele_recharge", {
        ready = {
            hud = Material("vgui/ttt/hud/hud_icon_slk_tele.vmt"),
            type = "good"
        },
        recharge = {
            hud = Material("vgui/ttt/hud/hud_icon_slk_tele.vmt"),
            type = "bad"
        }
    })

    RECHARGE_STATUS:RegisterStatus("ttt2_slk_scream_recharge", {
        ready = {
            hud = Material("vgui/ttt/hud/hud_icon_slk_scream.vmt"),
            type = "good"
        },
        recharge = {
            hud = Material("vgui/ttt/hud/hud_icon_slk_scream.vmt"),
            type = "bad"
        }
    })
    --RECHARGE_STATUS:AddStatus(ply, "ttt2_slk_lifesteal_recharge")
    --RECHARGE_STATUS:SetRechargeTimer(ply, "ttt2_slk_lifesteal_recharge", time, true)
    --RECHARGE_STATUS:RemoveStatus(ply, "ttt2_slk_lifesteal_recharge")
end)

hook.Add("TTTRenderEntityInfo", "TTT2Stalker:DisableStalkerTargetID", function(tData)
    if not STALKER then return end
    
    local ent = tData:GetEntity()
    
    if not ent:IsPlayer() then return end

    local ply = LocalPlayer()

    -- if ply:GetTeam() == TEAM_HIDDEN or ent:GetTeam() ~= TEAM_HIDDEN then return end
    if not ent:GetNWBool("ttt2_slk_stalker_mode", false) then return end

    tData:EnableText(false)
    tData:EnableOutline(false)

end)