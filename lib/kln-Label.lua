--[[
Label

Basic text label.

New:
  parent    - (frame) Frame to attach header to.
  text      - (string) Text of the label.
--]]

local MINOR_VERSION = 20180810

local lib, oldminor = LibStub:NewLibrary("kln-Label", MINOR_VERSION)
if not lib then return end

---------------------------------------------------------------------

function lib:New(parent, text)
  assert(type(parent) == "table" and type(rawget(parent, 0)) == "userdata", "kln-Label: parent must be a frame")
  if type(text) ~= "string" then text = nil end
  
  label = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightMedium")
  label:SetJustifyH("LEFT")
  label:SetJustifyV("TOP")
  label:SetNonSpaceWrap(true)
  label:SetText(text)

  return label
end


function lib.CreateLabel(...) return lib:New(...) end
