--[[
OptionFrame

Container for holding other configuration widgets.

New:
  name      - (string|frame) Name of frame. If a Frame object is
              given, it becomes the basis of the new OptionsFrame.
  parent    - (string) Name a pre-existing OptionsFrame. Will make
              the new frame a subcategory of the given OptionsFrame
              in the addon configuration selector (lefthand column).
  construct - (function) One-time set up function.
  refresh   - (function) Action to take when frame is updated.

GetOptionsFrame:
  name      - (string) Name of OptionsFrame to fetch.
  parent    - (string) Parent name of the OptionsFrame to fetch.
--]]

local MINOR_VERSION = 20180810

local lib, oldminor = LibStub:NewLibrary("kln-OptionsFrame", MINOR_VERSION)
if not lib then return end

lib.objects = lib.objects or {}

local widgetTypes = {
  "Button",
  "Checkbox",
  --"ColorPicker",
  "Dropdown",
  "EditBox",
  "Header",
  "ListBox",
  --"MediaDropdown",
  "Panel",
  --"Slider",
}

---------------------------------------------------------------------

-- 
-- On option frame show, search through the side menu and
-- expand the frame's entry, if it exists.
-- 
local function OptionsFrame_OnShow(self)
  if InCombatLockdown() then return end
  local i, target = 1, self.parent or self.name
  while true do
    local button = _G["InterfaceOptionsFrameAddOnsButton"..i]
    if not button then break end
    local element = button.element
    if element and element.name == target then
      if element.hasChildren and element.collapsed then
        _G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"]:Click()
      end
      return
    end
    i = i + 1
  end
end


-- 
-- Allow a one-time function to run before showing the frame.
-- 
local function OptionsFrame_OnFirstShow(self)
  if type(self.runOnce) == "function" then
    local success, err = pcall(self.runOnce, self)self.runOnce(self)
    self.runOnce = nil
    if not success then error(err) end
  end

  if type(self.refresh) == "function" then
    self.refresh(self)
  end

  self:SetScript("OnShow", FramePanel_OnShow)
  if self:IsShown() then
    OptionsFrame_OnShow(self)
  end
end


-- 
-- On option frame hide, search through the side menu and
-- collapse the frame's entries, if they exists.
-- 
local function OptionsFrame_OnClose(self)
  if InCombatLockdown() then return end
  local i, target = 1, self.parent or self.name
  while true do
    local button = _G["InterfaceOptionsFrameAddOnsButton"..i]
    if not button then break end
    local element = button.element
    if element.name == target then
      if element.hasChildren and not element.collapsed then
        local selection = InterfaceOptionsFrameAddOns.selection
        if not selection or selection.parent ~= target then
          _G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"]:Click()
        end
      end
      return
    end
    i = i + 1
  end
end

---------------------------------------------------------------------

-- 
-- Create a new OptionsFrame in the internal pool.
-- 
function lib:New(name, parent, construct, refresh)
  local frame
  if type(name) == "table" and name.IsObjectType and name:IsObjectType("Frame") then
    frame = name
  else
    assert(type(name) == "string", "kln-OptionsFrame: Name is not a string!")
    if type(parent) ~= "string" then parent = nil end
    frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
    frame:Hide()
    frame.name = name
    frame.parent = parent
    InterfaceOptions_AddCategory(frame, parent)
  end

  if type(construct) ~= "function" then construct = nil end
  if type(refresh) ~= "function" then refresh = nil end

  -- Attach valid widget functions
  for _, widget in pairs(widgetTypes) do
    local lib = LibStub("kln-"..widget, true)
    -- print("kln-"..widget, lib)
    if lib then
      local method = "Create"..widget
      frame[method] = lib[method]
    end
  end

  frame.refresh = refresh
  frame.okay = OptionsFrame_OnClose
  frame.cancel = OptionsFrame_OnClose

  frame.runOnce = construct

  if frame:IsShown() then
    OptionsFrame_OnFirstShow(frame)
  else
    frame:SetScript("OnShow", OptionsFrame_OnFirstShow)
  end

  if InterfaceOptionsFrame:IsShown() and not InCombatLockdown() then
    InterfaceAddOnsList_Update()
    if parent then
      local parentFrame = self:GetOptionsFrame(parent)
      if parentFrame then
        OptionsFrame_OnShow(parentFrame)
      end
    end
  end

  self.objects[#self.objects + 1] = frame
  return frame
end


-- 
-- Fetch an OptionsFrame from the internal pool of frames.
-- 
function lib:GetOptionsFrame(name, parent)
  local frames = self.objects
  for i = 1, #frames do
    if frames[i].name == name and frames[i].parent == parent then
      return frames[i]
    end
  end
end


function lib.CreateOptionsFrame(...) return lib:New(...) end
