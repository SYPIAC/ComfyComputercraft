local port = 1
local keyUp, keyDown = 265, 264
local modem = peripheral.warp("back")

if not modem.isWireless then
  print("No Modem!")
  return
end
print("Quarry controller")
print("Up arrow to go up, down to go down!")
while(true) do
  local event, key, isHeld = os.pullEvent("key")
  -- do not repeat key event
  if(isHeld == false) then
    if(key == keyUp) then
	  print("Going up")
	  modem.transmit(port,port, "quarry:up")
	end
	if(key == keyDown) then
	  print("Going down")
	  modem.transmit(port,port, "quarry:down")
	end
  end
end