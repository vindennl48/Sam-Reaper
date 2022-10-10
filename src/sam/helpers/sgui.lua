--------------------------------------------------------------------------------
-- IMPORTS
--------------------------------------------------------------------------------
local COUNT = require('helpers.counter')
local REP   = require('helpers.rep')
-- Scythe import --
local GUI  = require('gui.core')
local Font = require('public.font')
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Add font presets to GUI
Font:addFonts({ LB = { 'monospace', 20, '' } })

-- Get length of a table
function Length(tbl)
  local getN = 1
  for n in pairs(tbl) do 
    getN = getN + 1 
  end
  return getN
end

-- Start of the SGUI class
local SGUI = {}
-- local staticvar = 5 -- add static variables here
SGUI.__index = SGUI

-- Constructor of SGUI
function SGUI.new(name, isDock)
  name   = name or 'default'
  isDock = isDock or false
  if isDock then isDock = 257 else isDock = 0 end

  local instance = setmetatable({}, SGUI)

  instance.window = GUI.createWindow({
    name = name,
    dock = isDock,
  })

  instance.wln       = {}
  instance.layers    = {}
  instance.lastLayer = ''
  instance.X         = COUNT.new()
  instance.Y         = COUNT.new()

  return instance
end

-- Add a layer that consists of a button menu
function SGUI:addButtonMenu(name, title, ...)
  name  = name or 'default'
  title = title or 'default'
  local items = {...}
  self.X:set(10)
  self.Y:set(10)

  local layer = GUI.createLayer({ name = name })
  layer:hide()
  layer:addElements( GUI.createElement({
    name    = 'lbl_title_'..name,
    type    = 'Label',
    caption = title,
    x       = self.X:get(),
    y       = self.Y:add(30),
  }))

  -- if multiple buttons have the same name, add a label and this will create a
  -- unique button name for each including the last label name
  local category = nil

  for i, item in ipairs(items) do
    if item['type'] == 'spacer' then
      self.Y:add(30)

    elseif item['type'] == 'label' then
      layer:addElements( GUI.createElement({
        name    = 'lbl_label_'..item.name,
        type    = 'Label',
        caption = item.name,
        x       = self.X:get(),
        y       = self.Y:add(30),
      }))

      category = item.name

    else
      if item['name'] == nil then
        REP.print('Error: Missing name from addButtonMenu')
        return
      end

      local newButton = {
        name    = 'btn_'..name..'_'..category..'_'..item.name,
        type    = 'Button',
        caption = item.name,
        x       = self.X:get(),
        y       = self.Y:add(30),
        w       = 150
      }

      if item['func'] ~= nil then
        newButton.func = item.func
      end

      layer:addElements( GUI.createElement(newButton) )
    end
  end

  self:_addLayer(name, layer)
end

-- Add a layer that consists of a button menu
function SGUI:addButtonMenu_bup(name, title, ...)
  name  = name or 'default'
  title = title or 'default'
  local buttons = {...}
  self.X:set(10)
  self.Y:set(10)

  local layer = GUI.createLayer({ name = name })
  layer:hide()
  layer:addElements( GUI.createElement({
    name    = 'lbl_title_'..name,
    type    = 'Label',
    caption = title,
    x       = self.X:get(),
    y       = self.Y:add(30),
  }))

  for i, button in ipairs(buttons) do
    if button['name'] == nil then
      return
    end

    local newButton = {
      name    = 'btn_'..button.name..'_'..name,
      type    = 'Button',
      caption = button.name,
      x       = self.X:get(),
      y       = self.Y:add(30),
      w       = 150
    }

    if button['func'] ~= nil then
      newButton.func = button.func
    end

    layer:addElements( GUI.createElement(newButton) )
  end

  self:_addLayer(name, layer)
end

-- Add layer to choose from a list of options
function SGUI:addChooseMenu(name, title, okFunc, cancelFunc)
  name       = name or 'default'
  title      = title or 'default'
  -- options    = options or {'one', 'two', 'three'}
  okFunc     = okFunc or function() REP.print('Warning: Need to add okFunc') end
  cancelFunc = cancelFunc or function() REP.print('Warning: Need to add okFunc') end

  self.X:set(10)
  self.Y:set(10)

  local layer = GUI.createLayer({ name = name })
  layer:hide()

  layer:addElements( GUI.createElement({
    name    = 'lbl_title_'..name,
    type    = 'Label',
    caption = title,
    x       = self.X:get(),
    y       = self.Y:add(30),
  }))

  local listbox = GUI.createElement({
    name     = 'lb_options_'..name,
    type     = 'Listbox',
    textFont = 1,
    list     = {'one', 'two', 'three'},
    pad      = 10,
    x        = self.X:get(),
    y        = self.Y:add(310),
    w        = 300,
    h        = 300,
  })
  layer:addElements(listbox)
  -- Gives us a func to get the result
  function layer:val(options)
    if not options then
      -- listbox:val() returns the placement in the listbox.list.  This allows
      -- us to get the text that was selected instead.
      return listbox.list[listbox:val()]
    end

    -- If we do have options, lets add those to the listbox
    listbox.list = options
    listbox:val(0) -- reset previous selection
  end

  layer:addElements( GUI.createElements(
    {
      name    = 'btn_ok_'..name,
      type    = 'Button',
      caption = 'OK',
      x       = self.X:add(225),
      y       = self.Y:get(),
      w       = 75,
      func    = okFunc
    },
    {
      name    = 'btn_cancel_'..name,
      type    = 'Button',
      caption = 'Cancel',
      x       = self.X:get(),
      y       = self.Y:get(),
      w       = 75,
      func    = cancelFunc
    }
  ))

  self:_addLayer(name, layer)
end

-- Get user input with popup and textbox
function SGUI:getUserInput(title, label)
  -- local ret, retvals_csv = reaper.GetUserInputs( 'New Song', 1,'New song name', '' )
  local status, name = reaper.GetUserInputs( title, 1, label, '' )
  if not status then return end
  return name
end

-- Show specific layer to user
function SGUI:showLayer(layerName, options)
  for i, layer in ipairs(self.layers) do
    if not layer.hidden then
      self.lastLayer = layer.name
    end
    layer:hide()
  end

  self.layers[self.wln[layerName]]:show()

  if type(options) == 'table' then
    if options['listbox'] ~= nil then
      self.layers[self.wln[layerName]]:val(options.listbox)
    end
  end
end

-- Return back to previous layer
function SGUI:showPreviousLayer()
  self:showLayer(self.lastLayer)
end

-- Get the current layer object
function SGUI:getCurrentLayer()
  for i, layer in ipairs(self.layers) do
    if not layer.hidden then
      return layer
    end
  end
end

-- Start the window/plugin
function SGUI:run(layerName)
  layerName      = layerName or 1
  self.lastLayer = layerName

  self:showLayer(layerName)

  self.window:open()
  GUI.Main()
end

-- Add layer to window.  Used internally
function SGUI:_addLayer(name, layer)
  self.wln[name]              = Length(self.wln)
  self.layers[#self.layers+1] = layer
  self.window:addLayers(layer)
end

return SGUI
