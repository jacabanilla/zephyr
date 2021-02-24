## Table of contents
* [General info](#general-info)
* [Technologies](#technologies)
* [Next Updates](#next-updates)
* [Application](#application)

## General info
While connecting an audio-video receiver (AVR) to a home theater for my in-laws, I discovered the receiver had a network port.  Being curious about the purpose, I read through a number of manuals to find that it used a simple command protocol across a TCP network connection to control the settings.  It provided an opportunity to work on a new project for a mobile application using Apple's latest offerings and have fun in the process!

## Technologies
Project is created with:
* iOS 14
* SwiftUI
* Combine

## Next Updates
* Include an option to tune the fm receiver
* Introduce a number of channel presets
* Create an ip address scanner to automatically find the AVR
* Sync the UI from control changes on the panel

## Application
To engage the ARV, launch the application, input the IP address of the unit, and establish a connection.  The AVR is multi-zoned with independent controls for each.
