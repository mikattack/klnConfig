--[[
Panel

Bordered area within a layout.

New:
  parent    - (frame) Frame to attach panel to.
  labelText - (string) Text label above the panel.
  width     - (number) Width of the panel.
  height    - (number) Height of the panel
--]]

local MINOR_VERSION = 20180810

local lib, oldminor = LibStub:NewLibrary("kln-Panel", MINOR_VERSION)
if not lib then return end

---------------------------------------------------------------------

local panelBackdrop = {
  bgFile   = [[Interface\Tooltips\UI-Tooltip-Background]], tile = true, tileSize = 16,
  edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 16,
  insets   = { left = 5, right = 5, top = 5, bottom = 5 }
}


local function SetPoint(self, a, to, b, x, y)
  if self.labelText:GetText() and strmatch(a, "^TOP") then
    if x and not y then
      -- TOPLEFT, UIParent, 10, -10
      a, to, b, x, y = a, to, a, b, x
    elseif b and not x then
      -- TOPLEFT, 10, -10
      a, to, b, x, y = a, f:GetParent(), a, to, b
    elseif a and not to then
      -- TOPLEFT
      a, to, b, x, y = a, f:GetParent(), a, 0, 0
    end
    y = y - self.labelText:GetHeight()
  end
  self:orig_SetPoint(a, to, b, x, y)
end


local function SetText(fs, text)
  local f = fs:GetParent()
  local prev = fs:GetText()
  fs:orig_SetText(text)
  if (not not prev) ~= (not not labelText) then
    for i = 1, f:GetNumPoints() do
      f:SetPoint(f:GetPoint(i))
    end
  end
end

---------------------------------------------------------------------

function lib:New(parent, labelText, width, height)
  assert(type(parent) == "table" and type(rawget(parent, 0)) == "userdata", "kln-Panel: parent must be a frame")
  
  local frame = CreateFrame("Frame", nil, parent)
  frame:SetBackdrop(panelBackdrop)
  frame:SetBackdropColor(0.06, 0.06, 0.06, 0.4)
  frame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

  if labelText ~= false then
    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 4, 0)
    label:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -4, 0)
    label:SetJustifyH("LEFT")
    frame.labelText = label

    label:SetText(labelText)
    label.orig_SetText = label.SetText
    label.SetText = SetText

    frame.orig_SetPoint = frame.SetPoint
    frame.SetPoint = SetPoint
  end

  if width and height then
    frame:SetSize(width, height)
  end

  return frame
end


function lib.CreatePanel(...) return lib:New(...) end
