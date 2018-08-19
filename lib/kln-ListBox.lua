--[[
ListBox

Container for displaying an interactive list of options.

Lists are vertically oriented and display their contents by
rows. Each item may be interacted with by hovering and clicking.
If many options are specified, the list can be made scrollable.

Actions may be assigned when items are selected.

New:
  parent      - (frame) Frame to attach dropdown to.
  data        - (table) Data used to generate the list display.
                See "SetRowData()".
  scrollable  - (boolean) Whether listbox is scrollable.
                Default: true.

SetRowData: Sets the data used to generate the list display.
  data - (table) Collection of values. Caller is responsible
         for sorting the contents. Each item of the data must
         have the following properties (as required):

            id       - (string|number) Unique identifier for
                       the row. This value is used when determining
                       what is selected in the listbox.
            data     - (mixed) Data to associate to the row.
                       Optional. Default: nil.
            label    - (string) Visual label of the row.
            icon     - (string) Icon texture to associate with
                       the row. Optional.
            disabled - (boolean) Whether to disable the list item.
                       Optional. Default: false.

Refresh: Refreshes the listbox display. Usually used after
         a call to SetRowData.

GetSelectedRow: Returns the "id" and "data" of the selected element
                of the listbox.

SetSelectedRow: Sets the currently selected row of the listbox.
  id - Identifier of the row to set as selected.

GetRow: Returns a single row, if found.
  id - Identifier of the row to fetch.

Enable: Enables the listbox for interaction.

Disable: Disables interaction with the listbox.

EnableRow: Enables a given row of the listbox.

DisableRow: Disables a given row of the listbox.

Events: Functions that will be called after their respective
        built-in events are triggered by a listbox. Each function
        is passed the row element the event occurred on.

        The following events are available:
  
          - OnRowClick
          - OnRowEnter
          - OnRowLeave
          - OnSelect
          - OnDeselect
          - OnRowUpdate

        Attach a function to the listbox of the name of the
        event to augment. Example:

            listbox.OnSelect = function(row) ... end

        The row structure is:

          data  - (mixed) Data to associate to the row.
          id    - (string|number) Unique identifier of the row.
                  This value is used when determining what is
                  selected in the listbox.
          icon  - (frame) Icon frame.
          label - (FontString) Row label.
--]]

local MINOR_VERSION = 20180810

local lib, oldminor = LibStub:NewLibrary("kln-ListBox", MINOR_VERSION)
if not lib then return end

-- NOTE: This is a best effort element. The amount of things you
--       can do with this element is very broad...meaning there
--       are also many ways to inadvertantly create a poorly
--       performing pig. Use good judgement.

---------------------------------------------------------------------

local ListFont = "GameFontNormalLarge"
local colors = {
  enabled     = { 1, 1, 0 },
  disabled    = { 0.4, 0.4, 0.4 },
  highlighted = { 0.8, 0.8, 0 },
}

local panelBackdrop = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
  insets = { left = 4, right = 4, top = 4,  bottom = 4 },
}

lib.listboxes = lib.listboxes or {}   -- Object pool

---------------------------------------------------------------------
-- Creates container frames of the listbox

local function CreateFrames(parent, scrollable)
  -- Main frame
  panel = CreateFrame("Frame", nil, parent)
  panel:SetBackdrop(panelBackdrop)
  panel:SetBackdropColor(0, 0, 0, 0.3)
  panel:SetBackdropBorderColor(0.6, 0.6, 0.6)

  panel.scrollable = scrollable

  -- Make area vertically scollable
  do
    scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 4, -4)
    scrollFrame:SetPoint("BOTTOMRIGHT", -26, 4) -- Room for scrollbar

    if scrollable then
      local scrollBar = scrollFrame.ScrollBar
      scrollBar:EnableMouseWheel(true)
      scrollBar:SetScript("OnMouseWheel", function(self, delta)
        ScrollFrameTemplate_OnMouseWheel(scrollFrame, delta)
      end)

      -- Scrollbar rail
      local barBG = scrollFrame:CreateTexture(nil, "BACKGROUND", nil, -6)
      barBG:SetPoint("TOP")
      barBG:SetPoint("RIGHT", 27, 0)
      barBG:SetPoint("BOTTOM")
      barBG:SetWidth(28)
      barBG:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
      barBG:SetTexCoord(0, 0.45, 0.1640625, 1)
      barBG:SetAlpha(0.5)
    end

    scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(scrollFrame:GetWidth(), 100)
    scrollFrame:SetScrollChild(scrollChild)
    scrollFrame.scrollChild = scrollChild
    scrollFrame:SetScript("OnSizeChanged", function(self)
      scrollChild:SetWidth(self:GetWidth())
    end)
  end

  panel.display  = scrollFrame
  panel.scroller = scrollChild
  return panel
end

---------------------------------------------------------------------
-- ListBox event handlers

local internal = {}


local function Select(self)
  self.highlight:Show()
  self.label:SetTextColor(unpack(colors.enabled))
  if self.OnSelect and type(self.OnSelect) == "function" then
    self.OnSelect(self)
  end
end


local function Deselect(self)
  self.highlight:Hide()
  if self.data == "default" then
    self.label:SetTextColor(unpack(colors.disabled))
  else
    self.label:SetTextColor(unpack(colors.enabled))
  end
  if self.OnDeselect and type(self.OnDeselect) == "function" then
    self.OnDeselect(self)
  end
end


-- Walk list of items, deselect everything except clicked element
-- This gets attached to "listbox.display".
function internal:UpdateSelected()
  for i = 1, #self.rows do
    local row = self.rows[i]
    if self.selected and self.selected == row.id then
      row.selected = true
      Select(row)
    else
      row.selected = nil
      Deselect(row)
    end
  end
end


local function OnEnter(self)
  if not self.selected then
    Select(self)
  end
  if self.OnEnter and type(self.OnEnter) == "function" then
    self.OnEnter(self)
  end
end


local function OnLeave(self)
  if not self.selected then
    Deselect(self)
  end
  if self.OnLeave and type(self.OnLeave) == "function" then
    self.OnLeave(self)
  end
end


local function OnClick(self)
  PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
  
  local container = self:GetParent()
  container.selected = self.id
  container:UpdateSelected()

  if self.OnClick and type(self.OnClick) == "function" then
    self.OnClick(self)
  end
end


local function OnMouseWheel(self, delta)
  ScrollFrameTemplate_OnMouseWheel(scrollFrame, delta)
end

---------------------------------------------------------------------
-- Listbox data structure

local function CreateDataStructure(self, frame)
  local rowHeight = self.rowHeight or 24
  local rows = setmetatable({}, { __index = function(t, i)
    local row = CreateFrame("Button", nil, frame)
    row:SetHeight(rowHeight)
    row:SetPoint("LEFT")
    row:SetPoint("RIGHT")
    if i > 1 then
      row:SetPoint("TOP", t[i-1], "BOTTOM", 0, -1)
    else
      row:SetPoint("TOP")
    end

    row.id = nil
    row.data = nil
    row.label = ""
    row.disabled = false

    row:EnableMouse(true)
    row:EnableMouseWheel(true)

    row:SetScript("OnEnter", OnEnter)
    row:SetScript("OnLeave", OnLeave)
    row:SetScript("OnClick", OnClick)
    if self.scrollable then
      row:SetScript("OnMouseWheel", OnMouseWheel)
    end

    local highlight = row:CreateTexture(nil, "BACKGROUND")
    highlight:SetAllPoints(true)
    highlight:SetBlendMode("ADD")
    highlight:SetTexture([[Interface\QuestFrame\UI-QuestLogTitleHighlight]])
    highlight:SetVertexColor(0.2, 0.4, 0.8)
    highlight:Hide()
    row.highlight = highlight

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("LEFT")
    icon:SetSize(rowHeight, rowHeight)
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    row.icon = icon

    local label = row:CreateFontString(nil, "ARTWORK", ListFont)
    label:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    label:SetJustifyH("LEFT")
    row.label = label

    t[i] = row
    return row
  end })
  return rows
end

---------------------------------------------------------------------
-- Public API

local methods = {}


function EmptyRow(row)
  row.id = nil
  row.data = nil
  row.label = ""
  row.disabled = false
  row:Hide()
end


function EmptyAll(rows, index)
  if index == nil then index = 1 end
  if index > #rows then return end
  for i = index, #rows do
    EmptyRow(rows[i])
  end
end


function methods:SetRowData(data)
  assert(type(data) == "table", "kln-ListBox: listbox data must be a table")
  for k, v in pairs(data) do
    if v.id == nil or v.label == nil then
      print("kln-ListBox: row data missing 'id' and/or 'label'")
      return
    end
  end
  self.data = data
  self:Refresh()
end


function methods:Refresh()
  -- Empty the display if there's no data
  if self.data == nil or #self.data == 0 then
    EmptyAll(self.display.rows)
    return
  end

  -- Update list display with items
  local height = 0
  local lastIndex = nil
  for i = 1, #self.data do
    local item = self.data[i]
    local row = self.display.rows[i]

    row.id = item.id
    row.data = item.data or nil
    row.label:SetText(item.label)

    row.label:ClearAllPoints()
    if item.icon then
      row.icon:SetTexture(item.icon)
      row.label:SetPoint("LEFT", icon, "RIGHT", 8, 0)
      row.icon:Show()
    else
      row.label:SetPoint("LEFT", 5, 0)
      row.label:SetPoint("RIGHT", -5, 0)
      row.icon:Hide()
    end

    if row.disabled then
      row.label:SetTextColor(unpack(colors.disabled))
    else
      row.label:SetTextColor(unpack(colors.enabled))
    end

    if self.display.selected == row.id then
      row.selected = true
    end

    -- OnUpdate hook
    if self.OnRowUpdate and type(self.OnRowUpdate) == "function" then
      self.OnRowUpdate(row)
    end

    row:Show()
    height = height + 1 + row:GetHeight()

    lastIndex = i
  end

  -- If there are remaining elements in the display, empty them
  EmptyAll(self.data, lastIndex + 1)

  -- Update scrolling
  if height > 0 then
    self.scroller:SetHeight(height)
    self.scroller.isEmpty = false
    self.display.height = height
    self.display:UpdateSelected()
  else
    self.display.height = 100
    self.scroller:SetHeight(self.display.height)
    self.scroller.isEmpty = true
  end
end


function methods:GetSelectedRow()
  if self.display.selected == nil then return nil end
  local rows = self.display.rows
  for i = 1, #rows do
    if rows[i].id == self.display.selected then return rows[i] end
  end
  return nil
end


function methods:SetSelectedRow(id)
  local rows = self.display.rows
  for i = 1, #rows do
    if rows[i].id == id then
      self.display.selected = rows[i].id
    end
  end
end


function methods:GetRow(id)
  local rows = self.display.rows
  if self.display.selected == nil then return nil end
  for i = 1, #rows do
    if rows[i].id == id then return rows[i] end
  end
  return nil
end

---------------------------------------------------------------------
-- Create a listbox

function lib:New(parent, data, scrollable)
  assert(type(parent) == "table" and type(rawget(parent, 0)) == "userdata", "kln-ListBox: parent must be a frame")
  if type(scrollable) ~= "boolean" then scrollable = true end

  local listbox = CreateFrames(parent, scrollable)
  listbox.data = {}

  -- Public API
  for name, fn in pairs(methods) do
    listbox[name] = fn
  end

  -- Internal functions on the display frame
  listbox.display.selected = nil
  listbox.display.rows = CreateDataStructure(listbox, listbox.display)
  listbox.display.height = 100
  for name, fn in pairs(internal) do
    listbox.display[name] = fn
  end

  -- Lists are empty to begin with
  listbox.scroller:SetHeight(listbox.display.height)
  listbox.scroller.isEmpty = true

  listbox:SetRowData(data)
  return listbox
end


function lib.CreateListBox(...) return lib:New(...) end
