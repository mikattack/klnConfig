--[[
EditBox

Container that allows typed input.

New:
  parent      - (frame) Frame to attach button to.
  labelText   - (string) Textual label of the button.
  tooltipText - (string) Descriptive hover text. Optional.
  maxLetters  - (number) Maximum number of input characters.
  isNumeric   - (boolean) Only allow numeric input.

SetPoint: Positions the edit box.
  a   - (string) Anchor point of the edit box (ex. "TOPLEFT").
  to  - (frame) Frame to position edit box relative to.
  b   - (string) Ancho point of relative element.
  x   - (number) X offset.
  y   - (number) Y offset.

SetFormattedText: Set the edit box's text, `printf` style.
  text  - (string) Either a regular or formatted string.
  ...   - (string) If a formatted string was used, all other
          arguments are assumed to be strings used by the format.
--]]

local MINOR_VERSION = 20180810

local lib, oldminor = LibStub:NewLibrary("kln-EditBox", MINOR_VERSION)
if not lib then return end

lib.editboxes = lib.editboxes or { } -- Pool

---------------------------------------------------------------------

local scripts = {}
scripts.OnLeave = GameTooltip_Hide

function scripts:OnEnter()
  if self.tooltipText then
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
  end
end


function scripts:OnEditFocusGained()
  CloseDropDownMenus()
  local text = self:GetValue()
  self.currText, self.origText = text, text
  self:HighlightText()
end


function scripts:OnEditFocusLost()
  self:SetValue(self.origText or "")
  self:HighlightText(0, 0)
  self.currText, self.origText = nil, nil
end


function scripts:OnTextChanged()
  if not self:HasFocus() then return end

  local text = self:GetValue()
  if text == "" then text = nil end

  local callback = self.OnTextChanged
  if callback and text ~= self.currText then
    callback(self, text)
  end

  self.currText = text
end


function scripts:OnEnterPressed()
  local text = self:GetValue()
  self.origText = text
  self:ClearFocus()

  if text == "" then text = nil end
  local callback = self.OnValueChanged or self.Callback or self.callback
  if callback then
    callback(self, text)
  end
end


function scripts:OnEscapePressed()
  self:ClearFocus()
end


function scripts:OnReceiveDrag()
  local type, id, info = GetCursorInfo()
  if type == "item" then
    if self:GetNumeric() then
      self:SetNumber(id)
    else
      self:SetText(info)
    end
    scripts.OnEnterPressed(self)
    ClearCursor()
  elseif type == "spell" then
    if self:GetNumeric() then
      self:SetNumber(id)
    else
      local name = GetSpellInfo(id, info)
      self:SetText(name)
    end
    scripts.OnEnterPressed(self)
    ClearCursor()
  end
end

------------------------------------------------------------------------

local methods = {}

function methods:SetPoint(a, to, b, x, y)
  if self.labelText:GetText() and strmatch(a, "^TOP") then
    if x and not y then
      -- TOPLEFT, UIParent, 10, -10
      a, to, b, x, y = a, to, a, b, x
    elseif b and not x then
      -- TOPLEFT, 10, -10
      a, to, b, x, y = a, self:GetParent(), a, to, b
    elseif a and not to then
      -- TOPLEFT
      a, to, b, x, y = a, self:GetParent(), a, 0, 0
    end
    y = y - self.labelText:GetHeight()
  end
  return self:orig_SetPoint(a, to, b, x, y)
end


function methods:SetFormattedText(text, ...)
  return self:SetText(format(text, ...))
end

------------------------------------------------------------------------

function lib:New(parent, labelText, tooltipText, maxLetters, isNumeric)
  assert(type(parent) == "table" and parent.CreateFontString, "PhanxConfig-EditBox: Parent is not a valid frame!")
  if type(name) ~= "string" then name = nil end
  if type(tooltipText) ~= "string" then tooltipText = nil end
  if type(maxLetters) ~= "number" then maxLetters = nil end

  local editbox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
  tinsert(lib.editboxes, editbox)

  editbox.Left:SetPoint("TOPLEFT")   editbox.Left:SetPoint("BOTTOMLEFT")
  editbox.Right:SetPoint("TOPRIGHT") editbox.Right:SetPoint("BOTTOMRIGHT")
  editbox.Middle:SetPoint("TOP")     editbox.Middle:SetPoint("BOTTOM")
  editbox:SetSize(180, 22)

  editbox:EnableMouse(true)
  editbox:SetAltArrowKeyMode(false)
  editbox:SetAutoFocus(false)
  editbox:SetFontObject(ChatFontSmall)
  editbox:SetTextInsets(6, 6, 2, 0)

  local label = editbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  label:SetPoint("BOTTOMLEFT", editbox, "TOPLEFT", 6, 0)
  label:SetPoint("BOTTOMRIGHT", editbox, "TOPRIGHT", -6, 0)
  label:SetJustifyH("LEFT")
  editbox.labelText = label

  for name, func in pairs(scripts) do
    editbox:SetScript(name, func)
  end

  editbox.orig_SetPoint = editbox.SetPoint
  for name, func in pairs(methods) do
    editbox[name] = func
  end

  editbox.labelText:SetText(labelText)
  editbox.tooltipText = tooltipText
  editbox:SetMaxLetters(maxLetters or 256)

  if isNumeric then
    editbox:SetNumeric(true)
    editbox.GetValue = editbox.GetNumber
    editbox.SetValue = editbox.SetNumber
  else
    editbox.GetValue = editbox.GetText
    editbox.SetValue = editbox.SetText
  end

  return editbox
end

function lib.CreateEditBox(...) return lib:New(...) end
