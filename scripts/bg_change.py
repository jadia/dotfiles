#!/usr/bin/python3
#  Calls Feh, puts a randomized image on the background, and changes
# the image every 5 minutes.
# Adapted from: https://gist.github.com/FlyingJester/9142028

import subprocess
import time

wall_dir = '/home/nitish/dotfiles/wallpapers-haven/'

delay = 5 #5 minutes.

while True:
	feh = subprocess.Popen(['feh', '--bg-scale', '--randomize', wall_dir])
	time.sleep(delay * 60)
	
	#be a nice guy.
	feh.terminate()
