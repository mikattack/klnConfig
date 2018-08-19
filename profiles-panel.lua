---------------------------------------------------------------------
-- Main panel setup
---------------------------------------------------------------------

local _, ns = ...
local OptionsFrame = LibStub("kln-OptionsFrame")


local layout = OptionsFrame:New("Profiles", "KellenUI", nil, function(panel)
  local currentProfile = kln.profiles:Current()
  local profiles = kln.profiles:List()

  -------------------------------------------------------------------
  -- Frame's Headline and instructions

  local title, notes = panel:CreateHeader(
    "Profiles",
    "Select the current configuration profile, or create a new one."
  )
  
  -------------------------------------------------------------------
  -- List box

  -- Build list of list items
  local listdata = {}
  for i = 1, #profiles do
    listdata[i] = {
      id    = profiles[i],
      label = profiles[i],
    }
  end

  local listbox = panel:CreateListBox(listdata)
  listbox:SetPoint("TOPLEFT", panel, "CENTER", -175, 100)
  listbox:SetPoint("BOTTOMRIGHT", panel, "CENTER", 175, -100)
end)
