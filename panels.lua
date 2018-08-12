---------------------------------------------------------------------
-- Main panel setup
---------------------------------------------------------------------

local _, ns = ...
local OptionsFrame = LibStub("kln-OptionsFrame")


local main = OptionsFrame:New("KellenUI", nil, function(panel)

  local title, notes = panel:CreateHeader(
    "KellenUI Configuration",
    "Mighty fine!"
  )

  --[[
  --------------------------------------------------------------------

  local outline = panel:CreateDropdown("Outlines", nil, {
    { value = "NONE", text = "None" },
    { value = "OUTLINE", text = "Thin" },
    { value = "THICKOUTLINE", text = "Thick" },
  })
  function outline:OnValueChanged(value)
    print("klnConfig:Outline:", value)
  end
  outline:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -8)
  outline:SetPoint("TOPRIGHT", notes, "BOTTOMRIGHT", 0, -8)

  --------------------------------------------------------------------

  local shadow = panel:CreateCheckbox("Shadow")
  shadow:SetPoint("TOPLEFT", outline, "BOTTOMLEFT", 0, -8)

  function shadow:OnValueChanged(value)
    print("klnConfig:Shadow:", value)
  end

  --------------------------------------------------------------------

  local testpanel = panel:CreatePanel("Test", 100, 100)
  testpanel:SetPoint("TOPLEFT", shadow, "BOTTOMLEFT", 0, -8)
  --]]
end)


OptionsFrame:New("Subcategory A", "KellenUI", function(panel)
  local title, notes = panel:CreateHeader("Subcategory A", "In-depth nothingness.")
end)

ns.MainOptionsFrame = OptionsFrame:GetOptionsFrame("KellenUI")
