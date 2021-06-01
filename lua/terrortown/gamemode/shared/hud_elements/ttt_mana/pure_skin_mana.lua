local base = "pure_skin_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then -- CLIENT
	local pad = 7 -- padding
	local iconSize = 64

	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 365, h = 32},
		minsize = {w = 225, h = 32}
	}

	function HUDELEMENT:PreInitialize()
		BaseClass.PreInitialize(self)

		local hud = huds.GetStored("pure_skin")
		if not hud then return end

		hud:ForceElement(self.id)

		hudelements.RegisterChildRelation(self.id, "pure_skin_playerinfo", false)
	end

	function HUDELEMENT:Initialize()
		self.scale = 1.0
		self.basecolor = self:GetHUDBasecolor()
		self.pad = pad
		self.iconSize = iconSize

		BaseClass.Initialize(self)
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, false
	end
	-- parameter overwrites end

	function HUDELEMENT:GetDefaults()
		const_defaults["basepos"] = {
			x = 10 * self.scale,
			y = ScrH() - self.size.h - 146 * self.scale - self.pad - 10 * self.scale
		}

		return const_defaults
	end

	function HUDELEMENT:PerformLayout()
		self.scale = self:GetHUDScale()
		self.basecolor = self:GetHUDBasecolor()
		self.iconSize = iconSize * self.scale
		self.pad = pad * self.scale

		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:DrawComponent(multiplier, col, text, val)
		multiplier = multiplier or 1

		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local w, h = size.w, size.h

		self:DrawBg(x, y, w, h, self.basecolor)

		-- draw bar
		self:DrawBar(x + pad, y + pad, w - pad * 2, h - pad * 2, col, multiplier, self.scale, text)

		if val then
			draw.AdvancedText("-" .. tostring(val), "PureSkinBar", x + w - 3 * pad, y + h / 2, util.GetDefaultColor(Color(234, 41, 41)), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, false, self.scale)
		end

		self:DrawLines(x, y, w, h, self.basecolor.a)
	end

	function HUDELEMENT:ShouldDraw()
		local client = LocalPlayer()

		--return IsValid(client)
		return HUDEditor.IsEditing or (client:IsActive() and client:Alive() and client:GetSubRole() == ROLE_STALKER and client:GetNWBool("ttt2_hd_stalker_mode", false))
	end

	function HUDELEMENT:Draw()
		local client = LocalPlayer()
		local multiplier, mana, mana_cost

		local color = Color(36, 154, 198) -- STALKER.color
		if not color then return end

		if client:IsActive() and client:Alive() and client:GetSubRole() == ROLE_STALKER then
			mana = client:GetMana()
			mana_cost = client:GetManaCost()
			multiplier = mana / client:GetMaxMana()
		end

		-- if client:IsActive() and client:Alive() and client:GetSubRole() == ROLE_STALKER then
		-- 	if not client:GetNWBool("InBloodlust", false) then
		-- 		local bloodlustTime = client:GetNWInt("Bloodlust", 0)
		-- 		local delay = GetGlobalInt("ttt2_vamp_bloodtime")

		-- 		multiplier = bloodlustTime - CurTime()
		-- 		multiplier = multiplier / delay

		-- 		local secondColor = VAMPIRE.bgcolor
		-- 		local r = color.r - (color.r - secondColor.r) * multiplier
		-- 		local g = color.g - (color.g - secondColor.g) * multiplier
		-- 		local b = color.b - (color.b - secondColor.b) * multiplier

		-- 		color = Color(r, g, b, 255)
		-- 	else
		-- 		multiplier = 0
		-- 	end
		-- end

		if HUDEditor.IsEditing then
			self:DrawComponent(1, color)
		elseif mana then
			self:DrawComponent(multiplier, color, LANG.GetTranslation("slk_mana_name") .. ": " .. tostring(mana), mana_cost)
		end
	end
end
