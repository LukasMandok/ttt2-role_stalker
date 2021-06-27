RECHARGE_STATUS = {}
RECHARGE_STATUS.registered = {}
RECHARGE_STATUS.active = {}

function RECHARGE_STATUS:RegisterStatus(id, data)
    if self.registered[id] ~= nil then return false end
    if not data.ready or not data.recharge then return false end

    -- register single status icons
    if not STATUS:RegisterStatus(id, data.ready) then return false end
    --STATUS:RegisterStatus(id .. "_inactive", data.inactive)


    self.registered[id] = data

    return true
end

function RECHARGE_STATUS:AddStatus(id, active_icon)
	if self.registered[id] == nil then return end

    STATUS:AddStatus(id, active_icon)

	self.active[id] = table.Copy(self.registered[id])
    self:SetActiveIcon(id, active_icon or 1)

    if self.registered[id].displaytime and self.registered[id].displaytime > CurTime() then
        self:SetRecharge(id, self.registered[id].displaytime - CurTime(), true)
    end

end

function RECHARGE_STATUS:SetRecharge(id, duration, showDuration)
    if self.active[id] == nil or duration <= 0 then return end

    STATUS.active[id] = self.active[id].recharge
    STATUS.active[id].displaytime = CurTime() + duration
    self.registered[id].displaytime = CurTime() + duration

    timer.Create(id, duration, 1, function()
		if not self then return end

		STATUS.active[id] = self.active[id].ready
        self.registered[id].displaytime = nil
	end)

    if showDuration then 
        STATUS.active[id].DrawInfo = function(slf)
            return tostring(math.ceil(math.max(0, slf.displaytime - CurTime()))) 
        end
    end
end

function RECHARGE_STATUS:SetActiveIcon(id, active_icon)
	if self.active[id] == nil then return end

	local max_amount_active = self.registered[id].ready.hud.GetTexture and 1 or #self.registered[id].ready.hud
    local max_amount_recharge = self.registered[id].recharge.hud.GetTexture and 1 or #self.registered[id].recharge.hud
	
    if not active_icon or active_icon < 1 or active_icon > max_amount_active or active_icon > max_amount_recharge then
		active_icon = 1
	end

    self.active[id].ready.active_icon = active_icon
    self.active[id].recharge.active_icon = active_icon
	STATUS.active[id].active_icon = active_icon
end

function RECHARGE_STATUS:RemoveStatus(id)
	if self.active[id] == nil then return end

    STATUS:RemoveStatus(id)

	self.active[id] = nil

	if timer.Exists(id) then
		timer.Remove(id)
	end
end

net.Receive("ttt2_recharge_status_effect_add", function()
	RECHARGE_STATUS:AddStatus(net.ReadString(), net.ReadUInt(8))
end)

net.Receive("ttt2_recharge_status_effect_recharge", function()
	RECHARGE_STATUS:SetRecharge(net.ReadString(), net.ReadUInt(32), net.ReadBool())
end)

net.Receive("ttt2_recharge_status_effect_set_id", function()
	RECHARGE_STATUS:SetActiveIcon(net.ReadString(), net.ReadUInt(8))
end)

net.Receive("ttt2_recharge_status_effect_remove", function()
	RECHARGE_STATUS:RemoveStatus(net.ReadString())
end)