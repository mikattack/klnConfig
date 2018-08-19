---------------------------------------------------------------------
-- Main panel setup
---------------------------------------------------------------------

local _, ns = ...
local OptionsFrame = LibStub("kln-OptionsFrame")


local main = OptionsFrame:New("KellenUI", nil, function(panel)

  local title, notes = panel:CreateHeader(
    "KellenUI Configuration",
    "Mighty fine interface tools!"
  )

end)

-- Make option frame the "main" panel of the addon
ns.MainOptionsFrame = OptionsFrame:GetOptionsFrame("KellenUI")
