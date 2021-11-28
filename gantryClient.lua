--redstone sides
side_shift   = "right"
side_gantryX = "left"
side_gantryZ = "back"
side_clutch = "front"
top = "top"

local port = 1
local modem = peripheral.wrap("top")

--helper function for redstone
function reds(side, bool)
  redstone.setOutput(side, bool)
end

function processCmd(cmd)
  -- turn on clutch to not break anything
  reds(side_clutch, true)
  os.sleep(0.2)
  if(cmd=="up") then
    reds(side_gantryX, true)
    reds(side_gantryZ, true)
    reds(side_shift, true)
  elseif(cmd=="down") then
    reds(side_gantryX, true)
    reds(side_gantryZ, true)
    reds(side_shift, false)
  elseif(cmd=="left") then
    reds(side_gantryX, true)
    reds(side_gantryZ, false)
    reds(side_shift, true)
  elseif(cmd=="right") then
    reds(side_gantryX, true)
    reds(side_gantryZ, false)
    reds(side_shift, false)
  elseif(cmd=="forward") then
    reds(side_gantryX, false)
    reds(side_gantryZ, false)
    reds(side_shift, false)
  elseif(cmd=="back") then
    reds(side_gantryX, false)
    reds(side_gantryZ, false)
    reds(side_shift, true)
  end
  -- resume movement
  reds(side_clutch, false)
  os.sleep(0.2)
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