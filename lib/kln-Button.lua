--[[
Button

Meaty, clickable, red button.

New:
  parent      - (frame) Frame to attach button to.
  label       - (string) Textual label of the button.
  tooltipText - (string) Descriptive hover text. Optional.
--]]

local MINOR_VERSION = 20180810

local lib, oldminor = LibStub:NewLibrary("kln-Button", MINOR_VERSION)
if not lib then return end

------------------------------------------------------------------------

local scripts = {}
scripts.OnLeave = GameTooltip_Hide


function scripts:OnEnter() -- See: InterfaceOptionsCheckButtonTemplate
  if self.tooltipText then
    GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
    GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
  end
end


function scripts:OnClick(button)
  PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
  local callback = self.OnClick or self.Callback or self.callback
  if callback then
    callback(self, button)
  end
end

---------------------------------------------------------------------

function lib:New(parent, label, tooltipText)
  assert(type(parent) == "table" and parent.CreateFontString, "kln-Button: parent must be a frame")
  if type(label) ~= "string" then label = nil end
  if type(tooltipText) ~= "string" then tooltipText = nil end

  local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  button:GetFontString():SetPoint("CENTER", -1, 0)
  button:SetMotionScriptsWhileDisabled(true)
  button:RegisterForClicks("AnyUp")

  for name, func in pairs(scripts) do
    button:SetScript(name, func)
  end

  button:SetText(label)
  button:SetWidth(max(110, button:GetFontString():GetStringWidth() + 24))
  button.tooltipText = tooltipText

  return button
end


function lib.CreateButton(...) return lib:New(...) end
