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

--use advanced monitor on top for rendering
mon = peripheral.wrap("top")
term.redirect(mon)

--last button pressed
local lastButtonHit = 0
--list of buttons
local floors = {}
floors[0] = createButton(2, colors.orange, "button 0")
floors[1] = createButton(3, colors.cyan, "button 1")
floors[2] = createButton(4, colors.red, "button 2")

--smaller text = more pixels to work with
mon.setTextScale(0.5)
mon.clear()
while true do
  _, _, cx, cy = os.pullEvent("monitor_touch")
  --for each line on screen
  for i = 0, 10 do
    --only process defined buttons
    if(floors[i]) then
      --for 1 wide buttons this is ok - if y touched equals the button's y then we count it as pressed
      if(cy == floors[i].y) then
        --add chevrons to whichever button was hit and remove from previous
        floors[lastButtonHit].text = floors[lastButtonHit].text:gsub(">>","")
        drawButton(floors[lastButtonHit])
        floors[i].text = ">>"..floors[i].text
        lastButtonHit = i
      end
      --render
      drawButton(floors[i])
    end
  end
end