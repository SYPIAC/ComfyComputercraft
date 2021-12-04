--we'll read this value from floorDetector when not stopped
BETWEEN_FLOORS = 0
--is lift moving right now? don't process new commands
local movingNow = false
local floorToGo = 0
--unused
local currentFloor = 0

--stuff you'll need to place and directions
local side_floorDetector = "back" -- frequency #1:linear chassis
local side_clutch        = "right"
local side_gearshift     = "bottom"
local side_modem         = "top"

function readFloorDetector()
  return redstone.getAnalogInput(side_floorDetector)
end

function processCmd(cmd)
  --debug commands, won't be used for final client
  if(cmd=="up") then
    print("Moving up...")
    redstone.setOutput(side_gearshift, true)
    redstone.setOutput(side_clutch, false)
    movingNow = true
  elseif(cmd=="down") then
    print("Moving down..")
    redstone.setOutput(side_gearshift, false)
    redstone.setOutput(side_clutch, false)
    movingNow = true
  elseif(cmd=="stop") then
    print("Stopping")
    redstone.setOutput(side_clutch, true)
    movingNow = false
  end
  if(tonumber(cmd)) then
    floorToGo = tonumber(cmd)
    print("go to floor "..floorToGo)
    --we're not on the same floor - need to move. If we don't know which floor we're on - just go up 
    if(readFloorDetector() ~= floorToGo or readFloorDetector() == BETWEEN_FLOORS) then
      movingNow = true
      if(readFloorDetector() > floorToGo or readFloorDetector() == BETWEEN_FLOORS) then
        processCmd("up")
      else
        processCmd("down")
      end
    else
      print("same floor")
    end
  end
end

--when moving poll redstone to see which floor we're on
function redstoneWatch()
  while movingNow == true do
    if(readFloorDetector() == floorToGo) then
      currentFloor = floorToGo
      movingNow = false
    end
    --somehow we ended up at top without hitting the location to go, go down
    if(readFloorDetector() == 1 and floorToGo > 1) then
      processCmd("down")
    end
    --yield quickly or OS will stop the program("too long without yielding")
    os.queueEvent("tick")
    os.pullEvent()
  end
  processCmd("stop")
end

--when not moving watch for modem messages
function modemWatch()
  local event, modemSide, senderChannel,
        replyChannel, message, senderDistance = os.pullEvent("modem_message")   
  print("Received message "..message)
  if(string.find(message, "elevator")) then
    --cut out the "elevator:" prefix and process the rest
    processCmd(string.sub(message, 10, 99))
  end
end

--MAIN STARTS HERE
--modem init
local port = 100
local modem = peripheral.wrap(side_modem)
if not modem.isWireless then
  print("No wireless modem on "..side_modem)
  return
end
print("Running elevator server on port "..port)
modem.open(port)

while true do
  --only take commands when not moving
  if not movingNow then
    modemWatch()
  else
    redstoneWatch()
  end
end