local port = 1
local modem = peripheral.wrap("top")
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
  print("Received message:"..message)
  if(string.find(message, "gantry")) then
    --cut out the "gantry:" prefix and process the rest
    processCmd(string.sub(message, 8, 99))
  end
end

function processCmd(cmd)
  if(cmd=="up") then
    redstone.setOutput("back", true)
  elseif(cmd=="down") then
    redstone.setOutput("back", false)
  end
end