--redstone sides
gearshift   = "right" -- Reverse all motions
side_gantryX = "back" -- Gantry moving on X axis
side_gantryZ = "front" -- Gantry moving on Z axis
top = "top"
drill_control = "left"

local port = 1
local modem = peripheral.wrap("top")

--helper function for redstone
function reds(side, bool)
  redstone.setOutput(side, bool)
end

function check_drill_position()
  -- True -> Drill present
  -- False -> Drill mining
  return redstone.getOutput(drill_control)
end 

function processCmd(cmd)
  -- turn on clutch to not break anything
  -- This probably leads to more breaking than not having it
  --reds(side_clutch, true) 
  --os.sleep(0.2)
  
  if(cmd=="up") then
    print("Moving "..cmd)
    reds(side_gantryX, true)
    reds(side_gantryZ, true)
    reds(gearshift, true)
  elseif(cmd=="down") then
    print("Moving "..cmd)
    reds(side_gantryX, true)
    reds(side_gantryZ, true)
    reds(gearshift, false)
  
  if check_drill_position() then
    if(cmd=="left") then
      print("Moving "..cmd)
      reds(side_gantryX, true)
      reds(side_gantryZ, false)
      reds(gearshift, true)
    elseif(cmd=="right") then
      print("Moving "..cmd)
      reds(side_gantryX, true)
      reds(side_gantryZ, false)
      reds(gearshift, false)
    elseif(cmd=="forward") then
      print("Moving "..cmd)
      reds(side_gantryX, false)
      reds(side_gantryZ, false)
      reds(gearshift, false)
    elseif(cmd=="back") then
      print("Moving "..cmd)
      reds(side_gantryX, false)
      reds(side_gantryZ, false)
      reds(gearshift, true)
    end
  else then
    print("Drillhead not in position. Ignoring command")
  end
  -- resume movement
  --reds(side_clutch, false)
  --os.sleep(0.2)
end

--main begins here
  
  
if not modem.isWireless then
  print("NO top modem found!")
  print("Terminating")
  return
end
print("Running gantry client on port"..port)
modem.open(port)
while(true) do
  local event, modemSide, senderChannel,
        replyChannel, message, senderDistance = os.pullEvent("modem_message")   
  print("Received message "..message)
  if(string.find(message, "quarry")) then
    --cut out the "quarry:" prefix and process the rest
    processCmd(string.sub(message, 8, 99))
  end
end

function processOSEvent(event)

end
