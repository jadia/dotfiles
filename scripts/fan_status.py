#!/usr/bin/env python3

import psutil
import os
from time import sleep
import signal
import sys
import logging
import datetime as dt

logfile_name = dt.datetime.now().strftime('fan_status_%Y_%m_%d.log')

path = '/home/nitish/cron'
logfile_path = os.path.join(path,'logs',logfile_name)

logging.basicConfig(filename=logfile_path,
                            filemode='a',
                            format='%(pathname)s, %(asctime)s, %(levelname)s %(message)s',
                            datefmt='%H:%M:%S',
                            level=logging.DEBUG)

log = logging.getLogger('fan_speed')

def signal_handler(signal, frame):
  print("Exiting the fan_status process")
  sys.exit(0)

# Handle Ctrl+C
signal.signal(signal.SIGINT, signal_handler)

log.info("Process started.")
fan_running = False
try:
    while True:
        fan_speed = psutil.sensors_fans()['dell_smm'][0][1] # output: {'dell_smm': [sfan(label='', current=0)]}
        log.debug(f'fan_speed: {fan_speed}')
        if fan_speed != 0 and not fan_running:
            log.info("Fan started running! Sleeping for 5min.")
            cmd = f'notify-send "Fan started! {fan_speed} RPM" -t 100000 -u critical'
            fan_running = True
            sleep_time = 300 # seconds
        elif fan_speed != 0 and fan_running:
            log.info("Fan still running! Sleeping for 5min.")
            cmd = f'notify-send "Fan speed: {fan_speed} RPM" -t 10000 -u normal'
            sleep_time = 300
        else:
            if fan_running:
                cmd = 'notify-send "Fan stopped!" -t 100000 -u low'
                fan_running = False
            else:
                cmd = None
            # log.info("Fan not running")
            sleep_time = 15
        if cmd:
            os.system(cmd)
        sleep(sleep_time)
except Exception as e:
    log.exception("Something went wrong.")
