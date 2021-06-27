hook.Add("Initialize", "ttt2_slk_status_init", function()
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
    --RECHARGE_STATUS:SetRecharge(ply, "ttt2_slk_lifesteal_recharge", time, true)
    --RECHARGE_STATUS:RemoveStatus(ply, "ttt2_slk_lifesteal_recharge")
end)
