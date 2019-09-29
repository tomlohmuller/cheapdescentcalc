README.txt

INSTALL:
This script requires FlyWithLua (this script was developed and tested with current version 2.6.7; it is unknown but could also work with other versions)
Copy the script to:
       <x-plane path>/Resources/plugins/flywithlua/scripts
Start up X-Plane (or click 'Reload all Lua files' on the plugin menu if sim is already running; also use this method to reload if making changes to the script)


RECOMMENDED: set to hidden on start
At the top of the lua script file, change "local showCalcHud = true" to be false and instead the HUD will be hidden on startup by default.

OPTIONAL: set a color preference
At the top of the lua script file you can change your HUD Color Preference (the variable is "local drawColor")
Current supported options:
  * "RED"
  * "CYAN"
  * "PURPLE"
  * "GREEN"
  * "YELLOW"
  * "ORANGE"
  * "BLUE"
  * "WHITE" (default)

OPTIONAL: change height of closed HUD on left side of screen
At the top of the lua script file, you can change how high the hidden HUD button will display (the variable is "local closedHUDStartingHeight"). The value is the number of pixels from the bottom of the xplane window screen. You may increase this or decrease this as you see fit. (This is useful when other add ons have similar side menus or buttons that the calculator can cover up and you get tired of dragging the closed HUD all the time.)

PURPOSE:
Ever so slightly reduce the task saturation of a pilot solo flying a virtual Boeing 727 (or other aircraft with similar equipment capabilities)
by providing quick approximate descent profile information based on desired target altitude and descent angle.

HOW IT WORKS:
 * Click or scroll over the "+/-" buttons to change the target descent altitude and target descent angle
 * The top of descent "T/D" is an approximate distance in nautical miles to begin a descent to reach the target altitude.
 * As you descend you will notice the T/D decrease to zero when you finally reach the desired altitude
 * Click and drag the HUD to reposition anywhere
 * Click the small red box to hide the HUD on the left side of screen
 * Move your mouse over near the left side of screen and a pop out button will show
 * Click the pop out to open the HUD

DISCLAIMER:
The author makes no guarantee that this script will work perfectly for you or that you will make your target descent consistently.

CREDITS:
The user interface drawing layout was inspired from ridoni's Autospeed - a fine plugin this author recommends for
all of the reader's time acceleration needs in x-plane. Thanks ridoni your script was my intro to FlyWithLua!
A huge thank you to twitch users @Keith210t, @JonathansGamecast, @JonFly, @MrSaminus, @B2__, and @Kelvo907 for assisting
in beta and pre-release testing.
You helped to make this into something other people may actually find useful and helped push this project further than I ever planned to take it.
Thank you all again and to anyone not mentioned who took time to make sure everything was tidy before release!

LICENSE:
Copyright (c) 2019 el_gargantuan <elgargantuangaming@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

