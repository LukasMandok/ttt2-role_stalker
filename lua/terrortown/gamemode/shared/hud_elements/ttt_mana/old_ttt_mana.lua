local base = "old_ttt_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then -- CLIENT
	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 0, h = 45},
		minsize = {w = 0, h = 45}
	}

	function HUDELEMENT:PreInitialize()
		BaseClass.PreInitialize(self)

		local hud = huds.GetStored("old_ttt")
		if hud then
			hud:ForceElement(self.id)
		end

		self.disabledUnlessForced = true

		hudelements.RegisterChildRelation(self.id, "old_ttt_info", false)
	end

	function HUDELEMENT:Initialize()
		BaseClass.Initialize(self)
	end

	function HUDELEMENT:GetDefaults()
		local height = 45
		local parent = self:GetParentRelation()
		local parentEl = hudelements.GetStored(parent)
		local x, y = 15, ScrH() - height - self.maxheight - self.margin

		if parentEl then
			x = parentEl.pos.x
			y = parentEl.pos.y - self.margin - height - 30
		end

		const_defaults["basepos"] = {x = x, y = y}
		const_defaults["size"] = {w = self.maxwidth, h = 45}
		const_defaults["minsize"] = {w = self.maxwidth, h = 45}

		return const_defaults
	end

	function HUDELEMENT:DrawComponent(name, col, val, multiplier, val2)
		multiplier = multiplier or 1

		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local width, height = size.w, size.h

		draw.RoundedBox(8, x, y, width, height, self.bg_colors.background_main)

		local bar_width = width - self.dmargin
		local bar_height = height - self.dmargin

		local tx = x + self.margin
		local ty = y + self.margin

		self:PaintBar(tx, ty, bar_width, bar_height, col, multiplier)

		if val then
			self:ShadowedText(val, "HealthAmmo", tx + bar_width * 0.95, ty + bar_height * 0.5, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end

		if val2 then
			self:ShadowedText("-" .. tostring(val2), "HealthAmmo", tx + bar_width * 0.5, ty + bar_height * 0.5, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end 

		draw.SimpleText(name, "TabLarge", x + self.margin * 2, y, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local edit_colors = {
		border = COLOR_WHITE,
		background = Color(0, 0, 10, 200),
		fill = Color(100, 100, 100, 255)
	}

	-- function HUDELEMENT:ShouldDraw()
	-- 	print("ShouldDraw old ttt")
	-- 	local client = LocalPlayer()

	-- 	--return IsValid(client)
	-- 	return HUDEditor.IsEditing or (client:IsActive() and client:Alive() and client:GetSubRole() == ROLE_STALKER and client:GetNWBool("ttt2_slk_stalker_mode", false))
	-- end

	function HUDELEMENT:Draw()
		local client = LocalPlayer()

		if not IsValid(client) then return end

		local multiplier, mana, mana_cost

		local color = STALKER.color --self.sprint_colors 
		if not color then return end

		if client:IsActive() and client:Alive() and client:GetSubRole() == ROLE_STALKER and client:GetNWBool("ttt2_slk_stalker_mode", false) then
			mana = client:GetMana()
			multiplier = mana / client:GetMaxMana()
			mana_cost = client:GetManaCost()

			-- if not client:GetNWInt("Mana", 0) > 0 then
			-- 	local bloodlustTime = client:GetNWInt("Bloodlust", 0)
			-- 	local delay = GetGlobalInt("ttt2_vamp_bloodtime")

			-- 	multiplier = bloodlustTime - CurTime()
			-- 	multiplier = multiplier / delay

			-- 	local secondColor = VAMPIRE.bgcolor
			-- 	local r = color.r - (color.r - secondColor.r) * multiplier
			-- 	local g = color.g - (color.g - secondColor.g) * multiplier
			-- 	local b = color.b - (color.b - secondColor.b) * multiplier

			-- 	color = Color(r, g, b, 255)
			-- else
			-- 	multiplier = 0
			-- end
		end

		if HUDEditor.IsEditing then
			self:DrawComponent(LANG.GetTranslation("slk_mana_name"), edit_colors, "100")
		elseif mana then
			local col_tbl = {
				border = COLOR_WHITE,
				background = self.bg_colors.background_main,
				fill = color
			}

			self:DrawComponent(LANG.GetTranslation("slk_mana_name"), col_tbl, tostring(mana), multiplier, mana_cost)
		end
	end
end
