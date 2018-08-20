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

  local existingProfilesLabel = panel:CreateLabel("Existing Profiles:")
  existingProfilesLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -100)
  existingProfilesLabel:SetWidth(300)

  -- Build collection of profiles for listbox
  local listdata = {}
  for i = 1, #profiles do
    listdata[i] = {
      id    = profiles[i],
      label = profiles[i],
    }
  end

  local listbox = panel:CreateListBox(listdata)
  listbox:SetSelectedRow(currentProfile)
  
  listbox:SetPoint("TOPLEFT", existingProfilesLabel, "BOTTOMLEFT", 0, -5)
  listbox:SetWidth(300)
  listbox:SetHeight(375)


  -------------------------------------------------------------------
  -- Create profile controls

  local addProfileLabel = panel:CreateLabel("Create new profile:")
  addProfileLabel:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -16, -100)
  addProfileLabel:SetWidth(275)

  local createInput = panel:CreateEditBox(nil, nil, 40, false)
  createInput:SetPoint("TOPLEFT", addProfileLabel, "BOTTOMLEFT", 0, -5)
  createInput:SetWidth(175)

  local createTooltip = "Create a new profile with a name of your choice"
  local createButton = panel:CreateButton("Add", createTooltip)
  createButton:SetPoint("LEFT", createInput, "RIGHT", 5, 0)
  createButton:SetWidth(95)

  -------------------------------------------------------------------
  -- Duplicate profile controls

  local duplicateProfileLabel = panel:CreateLabel("Duplicate selected profile:")
  duplicateProfileLabel:SetPoint("TOPLEFT", createInput, "BOTTOMLEFT", 0, -50)
  duplicateProfileLabel:SetWidth(275)

  local duplicateInput = panel:CreateEditBox(nil, nil, 40, false)
  duplicateInput:SetPoint("TOPLEFT", duplicateProfileLabel, "BOTTOMLEFT", 0, -5)
  duplicateInput:SetWidth(175)

  local duplicateTooltip = "Duplicate the selected profile with a new name of your choice"
  local duplicateButton = panel:CreateButton("Duplicate", duplicateTooltip)
  duplicateButton:SetPoint("LEFT", duplicateInput, "RIGHT", 5, 0)
  duplicateButton:SetWidth(95)

  -------------------------------------------------------------------
  -- Profile activation and deletion controls

  local activateTooltip = "Activate the selected profile"
  local activateButton = panel:CreateButton("Activate", activateTooltip)
  activateButton:SetPoint("TOPLEFT", listbox, "BOTTOMLEFT", 0, -5)
  activateButton:SetWidth(75)

  local deleteTooltip = "Delete the selected profile"
  local deleteButton = panel:CreateButton("Delete", deleteTooltip)
  deleteButton:SetPoint("TOPRIGHT", listbox, "BOTTOMRIGHT", 0, -5)
  deleteButton:SetWidth(75)

end)
