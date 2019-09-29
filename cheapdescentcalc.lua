local showCalcHud = true            -- RECOMMENDED: Change to false and the HUD will be hidden on startup by default.
local closedHUDStartingHeight = 200 -- OPTIONAL: Raise or Lower the veritcal position of the hiden HUD pop out
local drawColor = "DEFAULT"         -- OPTIONAL: Change Color Preference
-- Current supported options:
--   * "RED"
--   * "CYAN"
--   * "PURPLE"
--   * "GREEN"
--   * "YELLOW"
--   * "ORANGE"
--   * "BLUE"
--   * "WHITE" (default)

-- Cheap Descent Calculator
-- VERSION: 2.1
-- DATE: 2019-09-29
-- AUTHOR: el_gargantuan <elgargantuangaming@gmail.com>

-- PURPOSE: 
-- Ever so slightly reduce the task saturation of a pilot solo flying a virtual Boeing 727 (or other aircraft with similar equipment capabilities)
-- by providing quick approximate descent profile information based on desired target altitude and descent angle.

-- INSTALL:
-- This script requires FlyWithLua (this script was developed and tested with current version 2.6.7; it is unknown but could also work with other versions)
-- Copy this script to:
--        <x-plane path>/Resources/plugins/flywithlua/scripts
-- Start up X-Plane (or click 'Reload all Lua files' on the plugin menu if sim is already running)

-- HOW IT WORKS:
--  * Click or scroll over the "+/-" buttons to change the target descent altitude and target descent angle
--  * The top of descent "T/D" is an approximate distance in nautical miles to begin a descent to reach the target altitude.
--  * As you descend you will notice the T/D decrease to zero when you finally reach the desired altitude
--  * Click and drag the HUD to reposition anywhere
--  * Click the small red box to hide the HUD on the left side of screen
--  * Move your mouse over near the left side of screen and a pop out button will show
--  * Click the pop out to open the HUD
--  * Click and drag on the hidden HUD button to reposition vertically along the left side of screen

-- DISCLAIMER:
-- The author makes no guarantee that this script will work perfectly for you or that you will make your target descent consistently.

-- CREDITS:
-- The user interface drawing layout was inspired from ridoni's Autospeed - a fine plugin this author recommends for
-- all of the reader's time acceleration needs in x-plane. Thanks ridoni your script was my intro to FlyWithLua!
-- A huge thank you to twitch users @Keith210t, @JonathansGamecast, @JonFly, @MrSaminus, @B2__, and @Kelvo907 for assisting
-- in beta and pre-release testing.
-- You helped to make this into something other people may actually find useful and helped push this project further than I ever planned to take it.
-- Thank you all again and to anyone not mentioned who took time to make sure everything was tidy before release!

-- LICENSE:
-- Copyright (c) 2019 el_gargantuan <elgargantuangaming@gmail.com>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
-- -----------------------------------------------------------------------------------------------------------------------------------

require("graphics")

DataRef ("groundSpeedMetersPerSec" , "sim/flightmodel/position/groundspeed", "readonly")
DataRef ("indicatedAltitude" , "sim/flightmodel/misc/h_ind2", "readonly")

local width = 140                           -- width of HUD
local height = 20                           -- height of a row
local posX = 10                             -- horizontal HUD position
local posY = 200                            -- vertical HUD position
local hiddenBtm = closedHUDStartingHeight   -- vertical hidden HUD position
local hiddenTop = hiddenBtm + 135           -- vertical hidden HUD position
local targetAltitude = 1000                 -- the desired altitude to descend to
local descentAngleDegrees = 3               -- the desired descent angle/glideslope
local calcCanDragMove = false               -- only certain click spots can drag

do_every_draw("cheapCalcDrawDisplay()")
do_on_mouse_click("cheapCalcMouseClickEvents()")
do_on_mouse_wheel("cheapCalcMouseWheelEvents()")

function cheapCalcDrawDisplay()
  XPLMSetGraphicsState(0,0,0,1,1,0,0)
  graphics.set_width(1); -- reset since other lua scripts might change this
  if showCalcHud == true then
    -- background
    graphics.set_color(0.2, 0.2, 0.2, 0.4)
    graphics.draw_rectangle(posX, posY, posX + width, posY + height*7)

    -- red "X" background
    graphics.set_color(1, 0, 0, 0.3)
    graphics.draw_rectangle(posX+120, posY+height*6, posX + width , posY + height*7)

    -- set user color preference
    calcSetDrawColor(graphics)

    -- vertical lines
    graphics.draw_line(posX, posY, posX, posY + height*7)                                -- V1.left 
    graphics.draw_line(posX + width/2, posY + height*3, posX + width/2, posY + height*2) -- V2.Angle "-/+"
    graphics.draw_line(posX + width/2, posY + height*5, posX + width/2, posY + height*4) -- V3.Altitude "-/+"
    graphics.draw_line(posX+120, posY + height*7, posX+120, posY + height*6)             -- V4."X"
    graphics.draw_line(posX + width, posY + height*7, posX + width, posY)                -- V5.right

    -- horizontal lines
    graphics.draw_line(posX, posY + height*7, posX + width, posY + height*7) -- H0.top
    graphics.draw_line(posX, posY + height*6, posX + width, posY + height*6) -- H1
    graphics.draw_line(posX, posY + height*5, posX + width, posY + height*5) -- H2
    graphics.draw_line(posX, posY + height*4, posX + width, posY + height*4) -- H3
    graphics.draw_line(posX, posY + height*3, posX + width, posY + height*3) -- H4
    graphics.draw_line(posX, posY + height*2, posX + width, posY + height*2) -- H5
    graphics.draw_line(posX, posY, posX + width, posY)                       -- H6.bottom

    -- diagonal lines
    graphics.draw_line(posX+120, posY + height*7, posX + width, posY + height*6) -- D1."\ of the X"
    graphics.draw_line(posX+120, posY + height*6, posX + width, posY + height*7) -- D2."/ of the X"

    -- "+/-"
    draw_string_Helvetica_18(posX + width/4 - 4 , posY + height*4.5 - 6, "-")
    draw_string_Helvetica_18(posX + width/4 * 3 - 4 , posY +  height*4.5 - 6, "+")
    draw_string_Helvetica_18(posX + width/4 - 4 , posY + height*2.5 - 6, "-")
    draw_string_Helvetica_18(posX + width/4 * 3 - 4 , posY +  height*2.5 - 6, "+")

    -- text
    draw_string_Helvetica_10(posX + 13, posY + height*6.5 - 5, "Cheap Descent Calc")
    draw_string_Helvetica_12(posX + 5 , posY + height*5.5 - 6, "TARGET ALT:  "..targetAltitude.." ft")
    draw_string_Helvetica_12(posX + 5  , posY + height*3.5 - 6,  "ANGLE:  "..descentAngleDegrees.." deg")

    -- do some maths and display results
    local topOfDropToDisplay = cheapCalcRound(calcTopOfDescent())
    local descentRateToDisplay = 0
    if topOfDropToDisplay > 0 then
      descentRateToDisplay = cheapCalcRound(calcDescentRateFeetPerMin())
    end
    draw_string_Helvetica_12(posX + 5, posY + height*1.5 - 6, "RATE:  "..descentRateToDisplay.." fpm")
    draw_string_Helvetica_12(posX + 5, posY + height/2 - 6,  "T/D:  "..topOfDropToDisplay.." nm")

  else -- HUD is hidden
    -- pop out when the mouse is on left side of screen
    if (MOUSE_X < 80) then
      graphics.set_color(0.2, 0.2, 0.2, 0.4)
      graphics.draw_rectangle(1, hiddenBtm, 18, hiddenTop)
      calcSetDrawColor(graphics)
      graphics.draw_line(1, hiddenBtm, 1, hiddenTop)          -- V0.left
      graphics.draw_line(18, hiddenBtm, 18, hiddenTop)        -- V1.right
      graphics.draw_line(1, hiddenTop, 18, hiddenTop)         -- H0.top
      graphics.draw_line(1, hiddenBtm+78, 18, hiddenBtm+78)   -- H1.middle
      graphics.draw_line(1, hiddenBtm, 18, hiddenBtm)         -- H2.bottom
      draw_string_Helvetica_12(4, hiddenBtm+120, "C")
      draw_string_Helvetica_12(4, hiddenBtm+110, "H")
      draw_string_Helvetica_12(4, hiddenBtm+100, "E")
      draw_string_Helvetica_12(4, hiddenBtm+90, "A")
      draw_string_Helvetica_12(4, hiddenBtm+80, "P")
      draw_string_Helvetica_12(4, hiddenBtm+65, "D")
      draw_string_Helvetica_12(4, hiddenBtm+55, "E")
      draw_string_Helvetica_12(4, hiddenBtm+45, "S")
      draw_string_Helvetica_12(4, hiddenBtm+35, "C")
      draw_string_Helvetica_12(4, hiddenBtm+25, "E")
      draw_string_Helvetica_12(4, hiddenBtm+15, "N")
      draw_string_Helvetica_12(4, hiddenBtm+05, "T")
    end
  end
end

function calcSetDrawColor(g)
  if drawColor == "RED" then
    g.set_color(1, 0, 0, 0.6)
  elseif drawColor == "CYAN" then
    g.set_color(0, 1 , 1, 1)
  elseif drawColor == "PURPLE" then
    g.set_color(0.6, 0, 1, 1)
  elseif drawColor == "GREEN" then
    g.set_color(0, 1, 0, 1)
  elseif drawColor == "YELLOW" then
    g.set_color(1, 1, 0, 1)
  elseif drawColor == "ORANGE" then
    g.set_color(1, 0.4, 0, 1)
  elseif drawColor == "BLUE" then
    g.set_color(0, 0.5, 1, 1)
  elseif drawColor == "WHITE" then
    g.set_color(1, 1, 1, 1)
  else -- anything else
    g.set_color(1, 1, 1, 1) -- "WHITE"
  end
end

function cheapCalcRound(roundMe)
  return math.floor(roundMe + 0.5)
end

function calcTopOfDescent()
  local result = (calcDescentTime() / 60) * calcGroundSpeedInKnots()
  if result < 0 then
    result = 0
  end
  if addBufferToTD then
    result = result * 1.05
  end
  return result
end

function calcDescentTime()
  if calcDescentRateFeetPerMin() > 0 then
    return (calcCurrentAltitude() - targetAltitude) / calcDescentRateFeetPerMin()
  end
  return 0
end

function calcDescentRateFeetPerMin()
  return math.tan(math.rad(descentAngleDegrees)) * calcGroundSpeedInFeetPerMin()
end

function calcGroundSpeedInFeetPerMin()
  return cheapCalcRound(groundSpeedMetersPerSec * 196.85)
end

function calcCurrentAltitude()
  return cheapCalcRound(indicatedAltitude)
end

function calcGroundSpeedInKnots()
  return cheapCalcRound(groundSpeedMetersPerSec * 1.943844)
end

function cheapCalcMouseClickEvents()
  if showCalcHud == true then
    local angleRate = 0.1
    local altitudeRate = 1000

    if (MOUSE_STATUS == "down" and MOUSE_X > posX and MOUSE_X < posX+width and MOUSE_Y > posY and MOUSE_Y < posY+height*7) then
      RESUME_MOUSE_CLICK = true

      if (MOUSE_X > posX+120 and MOUSE_X < posX+width and MOUSE_Y > posY+height*6 and MOUSE_Y < posY+height*7) then
        showCalcHud = false
      end

      if (MOUSE_X > posX and MOUSE_X < posX+120 and MOUSE_Y > posY+height*4 and MOUSE_Y < posY+height*7) or
         (MOUSE_X > posX and MOUSE_X < posX+width and MOUSE_Y > posY+height*6 and MOUSE_Y < posY+height*7) or
         (MOUSE_X > posX and MOUSE_X < posX+width and MOUSE_Y > posY+height*3 and MOUSE_Y < posY+height*4) or
         (MOUSE_X > posX and MOUSE_X < posX+width and MOUSE_Y > posY and MOUSE_Y < posY+height*2) then
        calcCanDragMove = true
        xDiff = MOUSE_X - posX
        yDiff = MOUSE_Y - posY
      end

      -- Click Altitude "+"
      if MOUSE_X > posX+width/2 and MOUSE_X < posX+width and MOUSE_Y > posY+height*4 and MOUSE_Y < posY+height*5 then
        if targetAltitude < 18000 then
          altitudeRate = 100
        end
        if targetAltitude < 50000 then
          targetAltitude = targetAltitude + altitudeRate
        end
      end

      -- Click Altitude "-"
      if MOUSE_X > posX and MOUSE_X < posX+width/2 and MOUSE_Y > posY+height*4 and MOUSE_Y < posY+height*5 then
        if targetAltitude <= 18000 then
          altitudeRate = 100
        end
        if targetAltitude > 100 then
          targetAltitude = targetAltitude - altitudeRate
        end
      end

      -- Click Angle "+"
      if MOUSE_X > posX+width/2 and MOUSE_X < posX+width and MOUSE_Y > posY+height*2 and MOUSE_Y < posY+height*3 then
        if descentAngleDegrees < 9.9 then
          descentAngleDegrees = descentAngleDegrees + angleRate
        end
      end

      -- Click Angle "-"
      if MOUSE_X > posX and MOUSE_X < posX+width/2 and MOUSE_Y > posY+height*2 and MOUSE_Y < posY+height*3 then
        if descentAngleDegrees > 1 then
          descentAngleDegrees = descentAngleDegrees - angleRate
        end
      end
    end

    if (MOUSE_STATUS == "drag") then
        if calcCanDragMove then
          posX = MOUSE_X - xDiff
          if posX < 1 then posX = 1 end
          posY = MOUSE_Y - yDiff
        end
    end

    if (MOUSE_STATUS == "up") then
      calcCanDragMove = false
    end
  else -- HUD is hidden
    if MOUSE_STATUS == "drag" and MOUSE_X >= 0 and MOUSE_X < 18 and MOUSE_Y > hiddenBtm and MOUSE_Y < hiddenTop then
      showCalcHud = false
      hiddenBtm = MOUSE_Y - hiddenBtmDiff
      hiddenTop = MOUSE_Y - hiddenTopDiff
    end
    if MOUSE_STATUS == "down" and MOUSE_X >= 0 and MOUSE_X < 18 and MOUSE_Y > hiddenBtm and MOUSE_Y < hiddenTop then
      RESUME_MOUSE_CLICK = true
      calcCanDragMove = true
      hiddenBtmDiff = MOUSE_Y - hiddenBtm
      hiddenTopDiff = MOUSE_Y - hiddenTop
    end

    if (MOUSE_STATUS == "up" and MOUSE_X >= 0 and MOUSE_X < 18 and MOUSE_Y > hiddenBtm and MOUSE_Y < hiddenTop) then
      showCalcHud = true
    end
  end
end

function cheapCalcMouseWheelEvents()
  if showCalcHud == false then
    return
  end

  local angleRate = 0.1
  local altitudeRate = 1000
  if targetAltitude < 18000 then
    altitudeRate = 100
  end

  -- Altitude change scroll
  if (MOUSE_X > posX and MOUSE_X < posX+width) and (MOUSE_Y > posY+height*4 and MOUSE_Y < posY+height*5) then
    RESUME_MOUSE_WHEEL = true
    if targetAltitude < 51000 and targetAltitude > 0 then
      targetAltitude = targetAltitude + altitudeRate*MOUSE_WHEEL_CLICKS
      if targetAltitude > 50000 then
        targetAltitude = 50000
      end
      if targetAltitude > 18000 then
        local temp = targetAltitude / 1000
        local rounded = cheapCalcRound(temp)
        targetAltitude = rounded * 1000
      end
      if targetAltitude < 100 then
          targetAltitude = 100
      end
    end
  end

  -- Angle change scroll
  if (MOUSE_X > posX and MOUSE_X < posX+width) and (MOUSE_Y > posY+height*2 and MOUSE_Y < posY+height*3) then
    RESUME_MOUSE_WHEEL = true
    if descentAngleDegrees < 10.1 and descentAngleDegrees > 0.9 then
      descentAngleDegrees = descentAngleDegrees + angleRate*MOUSE_WHEEL_CLICKS
    end
    if descentAngleDegrees > 10 then
      descentAngleDegrees = 10
    end
    if descentAngleDegrees < 1 then
      descentAngleDegrees = 1
    end
  end
end

do_sometimes("cheapCalcDebugLogEvents()")   -- only every 10 seconds
local calcDEBUG = false
function cheapCalcDebugLogEvents()
    if calcDEBUG then
      logMsg("calcDescentRateOld() value: " .. cheapCalcRound(calcDescentRateOld()))
      logMsg("calcTopOfDescentOld() value: " .. cheapCalcRound(calcTopOfDescentOld()))
    end
end

function calcDescentRateOld()
  return (calcGroundSpeedInKnots() / 2 ) * 10
end

function calcTopOfDescentOld()
  local result = (calcCurrentAltitude() - targetAltitude) / 1000 * 3 + 10
  if result < 0 then
    result = 0
  end
  return result
end
