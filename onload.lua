---------------------------------------------------------------------
-- Configuration startup
---------------------------------------------------------------------

local _, ns = ...
klnConfig = ns


local Loader = CreateFrame("Frame", nil, UIParent)
Loader:RegisterEvent("ADDON_LOADED")
Loader:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, event, ...)
end)


function Loader:ADDON_LOADED(event, addon, ...)
  if addon ~= "klnConfig" then return end

  -- Do some setup

  self:UnregisterEvent(event)
  self:SetScript("OnEvent", nil)
end


function ns.Open()
  InterfaceOptionsFrame_OpenToCategory("KellenUI")
  InterfaceOptionsFrame_OpenToCategory("KellenUI")  -- Hmmm
  ns.MainOptionsFrame:Show()
end
