#!/usr/bin/python3

import RPi.GPIO as GPIO

import time

LEDPORT = 24

GPIO.setmode(GPIO.BCM)
GPIO.setup(LEDPORT, GPIO.OUT)  # May get a warning here, it's OK

try:
	while True:
		GPIO.output(LEDPORT, True)
		time.sleep(1)
		GPIO.output(LEDPORT, False)
		time.sleep(1)
except KeyboardInterrupt:
	pass
finally:
	GPIO.cleanup()
