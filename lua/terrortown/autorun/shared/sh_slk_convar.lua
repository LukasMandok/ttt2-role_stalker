-- General
CreateConVar("ttt2_slk_speed_modifier", "1.3", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

-- Mana
CreateConVar("ttt2_slk_maximal_mana", "100", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_slk_mana_upgrade", "50", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

-- Tele
CreateConVar("ttt2_slk_tele_damage_multiplier", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_slk_tele_manacost_multiplier", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

-- Scream
CreateConVar("ttt2_slk_scream_manacost", "50", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_slk_scream_damage", "", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

-- Lifesteal
CreateConVar("ttt2_slk_lifesteal_pct", "0.05", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_slk_lifesteal_kill_bonus", "20", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_slk_lifesteal_manacost", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_slk_lifesteal_corpse_enabled", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

-- Mobility




---------------------------------

hook.Add("TTTUlxDynamicRCVars", "ttt2_slk_ulx_convars", function(tbl)
    tbl[ROLE_STALKER] = tbl[ROLE_STALKER] or {}
    
    -- General
    table.insert(tbl[ROLE_STALKER], {
        cvar = "ttt2_slk_speed_modifier",
        slider = true,
        min = 1,
        max = 1.9,
        desc = "ttt2_slk_speed_modifier (def. 1.3)"
    })

    -- Mana
    table.insert(tbl[ROLE_STALKER], {
        cvar = "ttt2_slk_maximal_mana",
        slider = true,
        min = 75,
        max = 300,
        desc = "ttt2_slk_maximal_mana (def. 100)"
    })

    table.insert(tbl[ROLE_STALKER], {
        cvar = "ttt2_slk_mana_upgrade",
        slider = true,
        min = 10,
        max = 150,
        desc = "ttt2_slk_mana_upgrade (def. 50)"
    })

    -- Tele
    table.insert(tbl[ROLE_STALKER], {
        cvar = "ttt2_slk_tele_damage_multiplier",
        slider = true,
        min = 0.1,
        max = 5,
        desc = "ttt2_slk_tele_damage_multiplier (def. 1.0)"
    })

    table.insert(tbl[ROLE_STALKER], {
        cvar = "ttt2_slk_tele_manacost_multiplier",
        slider = true,
        min = 0.1,
        max = 5,
        desc = "ttt2_slk_tele_manacost_multiplier (def. 1.0)"
    })

    -- Scream


    -- Lifesteal


    -- Mobility
    
end)