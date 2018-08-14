--[[
Header

Large font string with optional smaller descriptive text.

New:
  parent    - (frame) Frame to attach header to.
  titleText - (string) Text of the title.
  notesText - (string) Descriptive text. Optional.
--]]

local MINOR_VERSION = 20180810

local lib, oldminor = LibStub:NewLibrary("kln-Header", MINOR_VERSION)
if not lib then return end

---------------------------------------------------------------------

function lib:New(parent, titleText, notesText)
  assert(type(parent) == "table" and type(rawget(parent, 0)) == "userdata", "kln-Header: parent must be a frame")
  if type(titleText) ~= "string" then titleText = nil end
  if type(notesText) ~= "string" then notesText = nil end

  if not titleText then
    titleText = parent.name
  end
  
  local title = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetPoint("TOPRIGHT", -16, -16)
  title:SetJustifyH("LEFT")
  title:SetText(titleText)

  local notes
  if notesText then
    notes = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    notes:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    notes:SetPoint("RIGHT", -16, 0)
    notes:SetHeight(32)
    notes:SetJustifyH("LEFT")
    notes:SetJustifyV("TOP")
    notes:SetNonSpaceWrap(true)
    notes:SetText(notesText)
  end

  return title, notes
end


function lib.CreateHeader(...) return lib:New(...) end
