#!/user/bin/env bash

# Place these lines into ~/.xprofile. These are retrieved by using
# cvt res_x res_y frame_rate, and the output added here.

xrandr --newmode "1280x800_90.00"  131.25  1280 1368 1504 1728  800 803 809 845 -hsync +vsync
xrandr --addmode DP-3 "1280x800_90.00"

xrandr --newmode "2560x1440_120.00"  661.25  2560 2784 3064 3568  1440 1443 1448 1545 -hsync +vsync
xrandr --addmode DP-3 "2560x1440_120.00"
