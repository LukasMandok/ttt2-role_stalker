L = LANG.GetLanguageTableReference("en")

-- GENERAL ROLE LANGUAGE STRINGS
L[STALKER.name] = "Stalker"
L[STALKER.defaultTeam] = "Team Stalker"
L["hilite_win_" .. STALKER.defaultTeam] = "Team Stalkers Win"
L["info_popup_" .. STALKER.name] = [[You are the Stalker! 
Press Reload to transform permanently and begin killing.]]
L["body_found_" .. STALKER.abbr] = "They were a Stalker!"
L["search_role_" .. STALKER.abbr] = "This person was a Stalker!"
L["target_" .. STALKER.name] = "Stalker"
L["ttt2_desc_" .. STALKER.name] = [[The Stalker is a neutral killer. By unleashing their power, they gain speed and invisibility but 
are limited to their claws and telekinesis.]]

-- General
L["slk_mana_name"] = "Mana"

--Weapons
L["weapon_ttt_slk_tele_name"] = "Telekinesis"
L["weapon_ttt_slk_scream_name"] = "Scream"
L["weapon_ttt_slk_claws_name"] = "Claws"
L["item_ttt_slk_lifesteal_name"] = "Lifesteal"
L["item_ttt_slk_mana_upgrade_name"] = "Mana Upgrade"
L["item_ttt_slk_mobility_name"] = "Mobility Upgrade"

L["weapon_ttt_slk_tele_desc"] = "Control objects with the power of your mind. \nMana cost: 75"
L["weapon_ttt_slk_scream_desc"] = "Scream to stun the opponents in front of you. \nMana cost: 50"
L["item_ttt_slk_lifesteal_desc"] = "Get some health back, when attacking players with our claws."
L["item_ttt_slk_mana_upgrade_desc"] = "Increase your maximal Mana Pool by 100."
L["item_ttt_slk_mobility_desc"] = "Increases mobility by allowing you to perform very large jumps and climb walls."

--EPOP
L["slk_epop_title"] = "{nick} is the Stalker!"
L["slk_epop_desc"] = "Kill them before they kill you all!"
L["slk_epop_defeat_title"] = "{nick} the Stalker has been defeated!"
L["slk_epop_defeat_desc"] = "You survived the Stalker threat."

--EVENT STRINGS
L["slk_activate_title"] = "A Stalker activated their power"
L["slk_activate_desc"] = "{nick} entered Stalker mode"
L["slk_defeat_title"] = "A Stalker has been defeated"
L["slk_defeat_score"] = "Stalker Defeated: "
L["tooltip_slk_defeat_score"] = "Stalker Defeated: {score}"

