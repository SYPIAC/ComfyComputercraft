--have to do init here for it to be available for functions
local port = 100
local modem = peripheral.wrap("back")
if not modem then
  print("No wireless modem on back")
  return
end
print("Running elevator client on port "..port)
local label = os.getComputerLabel()
if(not string.find(label, "floor")) then
  print("Control PC label should start with 'floorX' where X is floor number")
  return
end

--creates a 1 wide button and returns the window to control it
function createButton(y,color, text)
  ret = window.create(term.current(), 1, y, 15, 1, true)
  ret.setBackgroundColor(color)
  ret.y = y
  ret.text = text
  return ret
end

--renders the button, scr is the window from createButton
function drawButton(scr)
  scr.clear()
  scr.setCursorPos(1,1)
  scr.write(scr.text)
end

function drawFloors()
	mon.clear()
	--for each line on screen
	for i = 0, 10 do -- 10 is line limit of one monitor
		--only process defined buttons
		if(floors[i]) then
			--render
			drawButton(floors[i])
		end
	end
end

function MonitorEvent(event) -- Select floors etc.
	if floors[event[4]] then-- Click Y
		for i = 0, 10 do -- 10 is line limit of one monitor
			--only process defined buttons
			if(floors[i]) then
				floors[i].text = floors[i].text:gsub(">>","")
			end
		end
	
		--add chevrons to whichever button was hit
		floors[event[4]].text = ">>"..floors[event[4]].text
		lastButtonHit = event[4]
		drawFloors()
    modem.transmit(port,port, "elevator:"..lastButtonHit)
	else
		return
    end
end

function ColorPicker()
	mon.clear()
	local _colors = {colors.orange, colors.lightBlue, colors.yellow, colors.pink, colors.cyan, colors.purple, colors.blue, colors.green, colors.red, colors.black}
	for i = 1, 10 do
		drawButton(createButton(i,_colors[i], ""))
	end
	
	while true do -- Wait till you get a valid input
		_,_,_,y = os.pullEvent("monitor_touch")
		if y then return _colors[y] end
	end
end

-- Draws all floors to the monitor, either existing ones, or free spots
function FloorPicker(onlyExistingFloors)
	mon.clear()
	local _colors = {colors.orange, colors.lightBlue, colors.yellow, colors.pink, colors.cyan, colors.purple, colors.blue, colors.green, colors.red, colors.black}
	local allowed = {}
	for i = 1, 10 do
		if floors[i] then
			if onlyExistingFloors then
				drawButton(floors[i])
				allowed[i] = true
			else -- Occupied spot, but only free floors are needed
				drawButton(createButton(i,colors.white, "")) -- "None" spot
				allowed[i] = false
			end
		else
			if not onlyExistingFloors then -- Free floor spot
				drawButton(createButton(i,_colors[i], "Floor "..tostring(i)))
				allowed[i] = true
			else -- Free spot, but only existing floors are needed
				drawButton(createButton(i,colors.white, "")) -- "None" spot
				allowed[i] = false
			end
		end
	end
	while true do -- Wait till you get a valid input
		_,_,_,y = os.pullEvent("monitor_touch")
		if y and allowed[y] then return y end
	end
end

function ConsoleEvent() -- Enter computer to get console
	mon.clear()
	print("Operations:\n1. Add floor\n2. Edit floor\n3.Delete floor\nPlease pick one (1-3)...")
	operation = string.sub(read(), 1,1) -- Limit to first character
	operation = tonumber(operation)
	if operation then -- Is a number
		if operation == 1 then -- Add new floor
			local color = ColorPicker() -- Pick a color
			mon.clear()
			local floor = FloorPicker(false) -- Pick a free floor position
			mon.clear()
			mon.setCursorPos(1, 2)
			print("Name: ")
			local name = read()
			floors[floor] = createButton(floor,color, name)
			
		elseif operation == 2 then -- Edit floor
			local color = ColorPicker() -- Pick a color
			mon.clear()
			local floor = FloorPicker(true)  -- Pick an existing floor position
			mon.clear()
			mon.setCursorPos(1, 2)
			print("Name: ")
			local name = read()
			floors[floor] = createButton(floor,color, name) -- Overwrite with new parameters
			
		elseif operation == 3 then -- Delete floor
			local floor = FloorPicker(true) -- Pick an existing floor position
			floors[floor] = nil -- "Delete" floor position
		else -- No valid input
			mon.write("Invalid!")
		end
		drawFloors()
	end
end

--MAIN STARTS HERE
--modem init
--cut off just the floor number from label
local floorLocation = tonumber(string.sub(label, 6,6)) 
--use advanced monitor on top for rendering
mon = peripheral.wrap("top")
term.redirect(mon)
--smaller text = more pixels to work with
mon.setTextScale(0.5)
mon.clear()


--last button pressed
local lastButtonHit = 0
--list of buttons
floors = {}
floors[1] = createButton(1, colors.green, "1:Surface")
floors[2] = createButton(2, colors.cyan, "2:Manufacturing")
floors[3] = createButton(3, colors.red, "3:Crushing?")
floors[4] = createButton(4, colors.orange, "4:Smelting?")
floors[5] = createButton(5, colors.purple, "5:Nether Portal")
floors[6] = createButton(6, colors.gray, "6:Andesite Mine")
drawFloors(floors)

while true do
  local eventData = {os.pullEvent()} -- Pull all events
  
  if eventData[1] == "monitor_touch" then
	mon.setCursorPos(1, eventData[4])
	mon.write("Nothing at "..tostring(eventData[4]))
	MonitorEvent(eventData)
  elseif eventData[1] == "key" and eventData[2] == keys.c and not eventData[3] then -- Key C not holding down for opening console
	mon.setCursorPos(1, 1)
	ConsoleEvent()
	-- Send updated floor plan to master
  elseif eventData[1] == "modem_message" then
	-- Update locally saved floorplan with received master floorplan
	-- drawFloors(floors) to update monitor
  --someone pressed the call button
  elseif eventData[1] == "redstone" then
    if(redstone.getInput("top") == true) then
      modem.transmit(port,port, "elevator:"..floorLocation)
    end
  end
end