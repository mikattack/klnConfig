--[[
Checkbox

Boolean selection widget.

New:
  parent      - (frame) Frame to attach checkbox to.
  label       - (string) Text label of the checkbox.
  tooltipText - (string) Descriptive hover text. Optional.
--]]

local MINOR_VERSION = 20180810

local lib, oldminor = LibStub:NewLibrary("kln-Checkbox", MINOR_VERSION)
if not lib then return end

---------------------------------------------------------------------

local scripts = {}

function scripts:OnDisable()
  self.labelText:SetFontObject(GameFontNormalLeftGrey)
end


function scripts:OnEnable()
  self.labelText:SetFontObject(GameFontHighlightLeft)
end


function scripts:OnClick(button)
  local checked = self:GetChecked()
  PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
  local callback = self.OnValueChanged or self.OnClick or self.Callback or self.callback
  if callback then
    return callback(self, checked)
  end
end

---------------------------------------------------------------------

function lib:New(parent, label, tooltipText)
  assert(type(parent) == "table" and type(rawget(parent, 0) == "userdata"), "kln-Checkbox: parent must be a frame")
  if type(label) ~= "string" then label = nil end
  if type(tooltipText) ~= "string" then tooltipText = nil end

  local check = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
  check:SetMotionScriptsWhileDisabled(true)
  check.labelText = check.Text

  for name, func in pairs(scripts) do
    check:SetScript(name, func)
  end
  check.GetValue = check.GetChecked
  check.SetValue = check.SetChecked

  check.labelText:SetText(label)
  check:SetHitRectInsets(0, -1 * max(100, check.labelText:GetStringWidth() + 4), 0, 0)
  check.tooltipText = tooltipText

  return check
end


function lib.CreateCheckbox(...) return lib:New(...) end
