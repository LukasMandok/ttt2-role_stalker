RECHARGE_STATUS = {}

-- register networkt messages
util.AddNetworkString("ttt2_recharge_status_effect_add")
util.AddNetworkString("ttt2_recharge_status_effect_timer")
util.AddNetworkString("ttt2_recharge_status_effect_recharge")
util.AddNetworkString("ttt2_recharge_status_effect_set_id")
util.AddNetworkString("ttt2_recharge_status_effect_remove")

---
-- Adds a status for a given @{Player}
-- @param Player ply The @{Player} that should receive this status update
-- @param string id The id of the registered @{RECHARGE_STATUS}
-- @param[default=1] number active_icon The numeric id of a specific status icon
-- @realm server
function RECHARGE_STATUS:AddStatus(ply, id, active_icon)
	net.Start("ttt2_recharge_status_effect_add")
        net.WriteString(id)
        net.WriteUInt(active_icon or 1, 8)
	net.Send(ply)
end

---
-- Adds a times status for a given @{Player}
-- @param Player ply The @{Player} that should receive this status update
-- @param string id The id of the registered @{RECHARGE_STATUS}
-- @param number duration The duration of the @{RECHARGE_STATUS}. If the time elapsed,
-- the @{RECHARGE_STATUS} will be removed automatically
-- @param[default=false] boolean showDuration Whether the duration should be shown
-- @param[default=1] number active_icon The numeric id of a specific status icon
-- @realm server
function RECHARGE_STATUS:SetRechargeTimer(ply, id, duration, showDuration)
	net.Start("ttt2_recharge_status_effect_timer")
        net.WriteString(id)
        net.WriteUInt(duration, 32)
        net.WriteBool(showDuration or false)
	net.Send(ply)
end


function RECHARGE_STATUS:SetRecharge(ply, id, bool)
	net.Start("ttt2_recharge_status_effect_recharge")
		net.WriteString(id)
		net.WriteBool(bool)
	net.Send(ply)
end

---
-- Changes the active icon for a specifiv active effect for a given @{Player}
-- @param Player ply The @{Player} that should receive this status update
-- @param string id The id of the registered @{RECHARGE_STATUS}
-- @param[default=1] number active_icon The numeric id of a specific status icon
-- @realm server
function RECHARGE_STATUS:SetActiveIcon(ply, id, active_icon)
	net.Start("ttt2_recharge_status_effect_set_id")
        net.WriteString(id)
        net.WriteUInt(active_icon or 1, 8)
	net.Send(ply)
end

---
-- Removes a status for a given @{Player}
-- @param Player ply The @{Player} that should receive this status update
-- @param string id The id of the registered @{RECHARGE_STATUS}
-- @realm server
function RECHARGE_STATUS:RemoveStatus(ply, id)
	net.Start("ttt2_recharge_status_effect_remove")
	    net.WriteString(id)
	net.Send(ply)
end