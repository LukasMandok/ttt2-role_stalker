CreateConVar("ttt2_slk_maximal_mana", "100", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

hook.Add("TTTUlxDynamicRCVars", "ttt2_slk_ulx_convars", function(tbl)
    tbl[ROLE_STALKER] = tbl[ROLE_STALKER] or {}

    table.insert(tbl[ROLE_STALKER], {
        cvar = "ttt2_slk_maximal_mana",
        slider = true,
        min = 75,
        max = 300,
        desc = "ttt2_slk_maximal_mana (def. 100)"
    })
end)