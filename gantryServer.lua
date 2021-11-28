local port = 1
local modem = peripheral.wrap("back")

function processKey(key)
  if(key == keys.up or key == keys.w) then
    modem.transmit(port,port, "quarry:forward")
  elseif(key==keys.down or key == keys.s) then
    modem.transmit(port,port, "quarry:back")
  elseif(key==keys.left or key == keys.a) then
    modem.transmit(port,port, "quarry:left")
  elseif(key==keys.right or key == keys.d) then
    modem.transmit(port,port, "quarry:right")
  elseif(key==keys.z) then
    modem.transmit(port,port, "quarry:down")
  elseif(key==keys.x) then
    modem.transmit(port,prot, "quarry:up")
  end
end

--main starts here
if not modem.isWireless then
  print("No Modem!")
  return
end
print("Quarry controller")
print("X to go up, Z to go down!")
print("arrow keys or WASD to move!")
while(true) do
  local event, key, isHeld = os.pullEvent("key")
  -- do not repeat key event
  if(isHeld == false) then
    processKey(key)
  end
end
