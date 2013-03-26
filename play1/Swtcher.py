#!/usr/bin/python3

# Read a switch using events and toggle and LED

# Module imports

from time import sleep
import sys

import RPi.GPIO as GPIO

# Fixed parameters

LEDPORT = 24
SWITCHPORT = 25
DEBUG = False		# Set True for messages

# Setup general

if DEBUG: print("Starting...")
GPIO.setmode(GPIO.BCM)
if DEBUG: print("Mode set")

# Setup LED

GPIO.setup(LEDPORT, GPIO.OUT, initial=GPIO.LOW)

# Setup switch

GPIO.setup(SWITCHPORT, GPIO.IN, pull_up_down=GPIO.PUD_UP)	# Input with pullup enabled

# Define the main switch function

def switchpushed():
	if DEBUG: print("switchpushed called")
	lednow = GPIO.input(LEDPORT)	# Can we read an output?
	newled = not lednow
	GPIO.output(LEDPORT, newled)
	if DEBUG: print("LED toggled")

GPIO.add_event_detect(SWITCHPORT, GPIO.FALLING, callback=switchpushed)	# Detect switch pushes

if DEBUG: print("Ready for action!")

try:
	while True:
#		if DEBUG: print("Switch state: " + str(GPIO.input(SWITCHPORT)))
#		GPIO.wait_for_edge(SWITCHPORT, GPIO.FALLING)
#		if DEBUG: print("Edge detect complete")
#		switchpushed()
#		GPIO.wait_for_edge(SWITCHPORT, GPIO.RISING)	# Wait for switch up
#		if DEBUG: print("Switch up")
		sleep(1)
except:
	if DEBUG: 
		exc = sys.exc_info()
		print("Exception! " + str(exc))
finally:
	if DEBUG: print("Cleaning up")
	GPIO.cleanup()

if DEBUG: print("All done...")
