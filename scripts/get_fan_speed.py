#!/usr/bin/env python3

import psutil
import os

fan_speed = psutil.sensors_fans()['dell_smm'][0][1] # output: {'dell_smm': [sfan(label='', current=0)]}
cmd = f'notify-send "Fan speed: {fan_speed} RPM" -t 5000 -u normal'
os.system(cmd)