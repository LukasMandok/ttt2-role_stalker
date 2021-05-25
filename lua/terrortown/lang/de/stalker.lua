L = LANG.GetLanguageTableReference("de")

-- GENERAL ROLE LANGUAGE STRINGS
L[STALKER.name] = "Stalker"
L[STALKER.defaultTeam] = "Team Stalker"
L["hilite_win_" .. STALKER.defaultTeam] = "Die Stalker gewinnen"
L["info_popup_" .. STALKER.name] = [[Du bist der Stalker! 
Drücke Nachladen, um dich dauerhauft zu verwandeln und mit dem Töten zu beginnen.]]
L["body_found_" .. STALKER.abbr] = "Es war ein Stalker!"
L["search_role_" .. STALKER.abbr] = "Diese Person war ein Stalker!"
L["target_" .. STALKER.name] = "Stalker"
L["ttt2_desc_" .. STALKER.name] = [[Der Stalker ist ein neutraler Killer. Durch das Entfesseln seiner Kraft gewinnt er an Geschwindigkeit und wird unsichtbar.
Allerdings stehen ihm nur noch seine Krallen und telekinetische Fähigkeiten zur Verfügung.]]

-- General
L["slk_mana_name"] = "Mana"

--Weapons
L["weapon_ttt_slk_claws_name"] = "Krallen"
L["weapon_ttt_slk_tele_name"] = "Telekinese"
L["weapon_ttt_slk_scream_name"] = "Schrei"
L["item_ttt_slk_lifesteal_name"] = "Lebensraub"
L["item_ttt_slk_mana_upgrade_name"] = "Mana Upgrade"
L["item_ttt_slk_mobility_name"] = "Mobilitäts Upgrade"

L["weapon_ttt_slk_tele_desc"] = "Kontrolliere Gegenstände mit deinen Gedanken. \nMana Kosten: 75"
L["weapon_ttt_slk_scream_desc"] = "Schreie, um deine Gegner vor dir zu betäuben. \nMana Kosten: 50"
L["item_ttt_slk_lifesteal_desc"] = "Erhalbe Lebenspunkte zurück, wenn du Gegner mit deinen Krallen angreifst."
L["item_ttt_slk_mana_upgrade_desc"] = "Erweitere deinen Mana Vorrat um 100."
L["item_ttt_slk_mobility_desc"] = "Erhöht die Beweglichkeit, indem es dir ermöglicht, sehr große Sprünge auszuführen und Wände zu erklimmen."

--EPOP
L["slk_epop_title"] = "{nick} ist der Stalker!"
L["slk_epop_desc"] = "Tötet ihn, bevor er euch alle tötet!"
L["slk_epop_defeat_title"] = "{nick}, der Stalker, wurde besiegt!"
L["slk_epop_defeat_desc"] = "Der Stalker ist keine Gefahr mehr."

--EVENT STRINGS
L["slk_activate_title"] = "Ein Stalker hat seine Kräfte enfesselt"
L["slk_activate_desc"] = "{nick} hat den Verborgen-Modus aktiviert"
L["slk_defeat_title"] = "Ein Stalker wurde besiegt"
L["slk_defeat_score"] = "Stalker besiegt: "
L["tooltip_slk_defeat_score"] = "Stalker besiegt: {score}"

