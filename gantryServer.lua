local port = 1
local keyZ, keyX     = 90, 88
local keyArrowUp, keyArrowDown, keyArrowLeft, keyArrowRight = 265, 264, 263, 262
local modem = peripheral.wrap("back")

function processKey(key)
  if(key == keyArrowUp) then
    modem.transmit(port,port, "quarry:forward")
  elseif(key==keyArrowDown) then
    modem.transmit(port,port, "quarry:back")
  elseif(key==keyArrowLeft) then
    modem.transmit(port,port, "quarry:left")
  elseif(key==keyArrowRight) then
    modem.transmit(port,port, "quarry:right")
  elseif(key==keyZ) then
    modem.transmit(port,port, "quarry:down")
  elseif(key==keyX) then
    modem.transmit(port,prot, "quarry:up")
  end
end

--main starts here
if not modem.isWireless then
  print("No Modem!")
  return
end
print("Quarry controller")
print("Z to go up, X to go down!")
print("arrow keys to move")
while(true) do
  local event, key, isHeld = os.pullEvent("key")
  -- do not repeat key event
  if(isHeld == false) then
    processKey(key)
  end
end