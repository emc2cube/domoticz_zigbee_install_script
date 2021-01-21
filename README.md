# User friendly Domoticz install and update script

![GitHub package.json version](https://img.shields.io/github/package-json/v/emc2cube/domoticz_zigbee_install_script)![GitHub top language](https://img.shields.io/github/languages/top/emc2cube/domoticz_zigbee_install_script?color=green)![GitHub](https://img.shields.io/github/license/emc2cube/domoticz_zigbee_install_script?color=yellow)

> Easy install and update script for [Domoticz](https://domoticz.com) with [zigbee2mqtt](https://www.zigbee2mqtt.io) and [MySensors](https://www.mysensors.org) support.
>
> Out of the box open source support for:
> * [Domoticz](https://domoticz.com)
> * [Auto restart domoticz service](https://github.com/agambier/domoticz_addons)
> * [zigbee2mqtt](https://www.zigbee2mqtt.io)
> * [domoticz-zigbee2mqtt-plugin](https://github.com/stas-demydiuk/domoticz-zigbee2mqtt-plugin)
> * [MySensors](https://www.mysensors.org)
> * [Apple HomeKit](https://developer.apple.com/homekit/) through [homebridge](https://github.com/homebridge/homebridge)
> * [Amazon Alexa](https://alexa.amazon.com/) through [homebridge-alexa](https://github.com/NorthernMan54/homebridge-alexa)
> * [Google Smart Home](https://assistant.google.com) through [homebridge-gsh](https://github.com/oznu/homebridge-gsh)

## Purpose

This script and guide are intended to help set up a DIY smart device hub using a Raspberry Pi with open source [Domoticz](https://domoticz.com/) software utilizing the Zigbee wireless protocol, which supports a wide variety of retail smart devices. While the software is intended for general home automation tasks, it can easily be adapted for other more specialized use cases requiring monitoring and/or automation.

## Requirements

* A Raspberry Pi. When possible buy from official distributors, not from third party Amazon sellers.
	* Raspberry Pi 2 Model B minimum, [Raspberry Pi 4 Model B](https://www.raspberrypi.org/products/raspberry-pi-4-model-b/) recommended.  The software may run on other models (Pi 1 and Pi Zero) but it is not recommended and not supported by this install script as ([nodesource](https://nodesource.com) does not provide distributions of Node.js v12 for ARMv6 hardware).
	* A Raspberry Pi case (either retail or 3D printed) is strongly recommended.

* A high quality micro SD card, minimum 4GB class 10 UHS-1. Cards rated with an Application Performance Class (A1 or A2) or rated for heavy usage are ideal, such as the Samsung Pro Endurance series: [Buy on Amazon](https://amzn.to/2XOH0c3).

* Raspbian OS installed on the SD card.
	* Use the [Raspberry Pi Imager](https://www.raspberrypi.org/software/) for easy installation. "Raspberry Pi OS Lite" is recommended for headless (no display) installations and is available under "Raspberry Pi OS (other)".
	* [Enable SSH on a headless Raspberry Pi](https://www.raspberrypi.org/documentation/remote-access/ssh/README.md) (step 3) and if needed [configure WiFi](https://www.raspberrypi.org/documentation/configuration/wireless/headless.md).
	* For convenience an `ssh` and a `wpa_supplicant.conf` file are included. Edit wpa_supplicant.conf as needed (Country code and WiFi information) and copy both files on the "boot" partition of your SD card.

* A [supported Zigbee wireless adapter](https://www.zigbee2mqtt.io/information/supported_adapters.html) flashed with zigbee2mqtt firmware.
	* It is strongly recommended to buy a pre-flashed adapter such as [this one](https://www.aliexpress.com/item/4000818147676.html) as the flashing process can be quite difficult and complicated.
	* Adapters are also available with external antennas if you think you may need more range.
	* Cases may be available from some sources, or they can be 3D printed.

## Usage

### Installation

The following commands will download and install all necessary files to the `/home/pi/` folder.

```sh
sudo apt-get -y install git
cd /home/pi/
git clone https://github.com/emc2cube/domoticz_zigbee_install_script.git
chmod +x /home/pi/domoticz_zigbee_install_script/update_domoticz.sh
```

### [Optional] Custom configuration

By default the script will install and update all components required to support Zigbee, MySensors, and Homebridge (supports Apple HomeKit, Amazon Alexa, and Google Smart Home.)
You can customize that behavior by editing the script itself, changing variables to **true** or **false** as needed. Though this is not recommended as git may complain if you make changes and then perform a git pull to check for eventual updates of the script.

A better solution is to create a text file named `config` in the `/home/pi/domoticz_zigbee_install_script/` folder containing these options. The script will automatically use configuration options from this file when present.

```sh
###########
# Options #
###########
#
# Use domoticz beta channel instead of stable (at your own risk)
domoticzbeta=false
#
# Install Homebridge
# Provides support for Apple HomeKit through homebridge (https://github.com/homebridge/homebridge)
# Provides support for Amazon Alexa through homebridge-alexa (https://github.com/NorthernMan54/homebridge-alexa)
# Provides support for Google Smart Home through homebridge-gsh (https://github.com/oznu/homebridge-gsh)
# You will need to link these to your accounts - see respective homebridge plugin websites
homebridge=true
#
# Install Zigbee
# Provides support for Zigbee devices through zigbee2mqtt (https://www.zigbee2mqtt.io) and
# domoticz integration through domoticz-zigbee2mqtt-plugin (https://github.com/stas-demydiuk/domoticz-zigbee2mqtt-plugin)
zigbee=true
#
# Install MySensors
# Provides support for MySensors (https://www.mysensors.org)
mysensors=true
# Setting for IRQ support, default to pin 18 as used in most recent versions of
# the MySRaspiGW adapter (https://github.com/emc2cube/MySRaspiGW)
# Leave empty if your nRF24L01 module do not support IRQ.
irqpin="18"
#
###########
```

### Running the script

The following commands will make sure your ```domoticz_zigbee_install_script``` is up to date and then update your system.

```sh
cd /home/pi/domoticz_zigbee_install_script/ && git pull
/home/pi/domoticz_zigbee_install_script/update_domoticz.sh
```

### Initial Domoticz Setup:
* Determine the new IP address of your Raspberry Pi and access Domoticz through your web browser `http://<Pi IP>/` (or `http://<Pi IP>:8080/` if you left the Domoticz ports at their default values.)
* From the menu at the top, select Setup->Settings. Set a location (used for sunrise/sunset timing) and set a username and password if you desire. Make sure to click Apply Settings.

### Connecting Zigbee devices:
* From the menu, select Custom->Zigbee2mqtt. Check the "Allow new zigbee devices to join" checkbox, then click the Pair Device button. Initiate pairing on your smart device. Once the pairing process is complete, close the pairing popup box. You should see a new entry on the devices list.
* From the top menu, select Setup->Devices. This page shows all the sensors and controls provided by your devices. There may be several per device. Find the item you want to use and click the green arrow towards the right side of its line in order to enable it in Domoticz. Give the device a name.

### Setting up devices:
* Configure devices using the appropriate tab in the top menu (switches, temperature, weather, utility.) Humidity sensors are included under temperature. The star symbol pins devices to the main dashboard page.
* Switches can be manually toggled simply by clicking on the switch icon. The log page for sensors can be opened by clicking on the device icon and will display history graphs.

### Known Issues:
* Sudden power loss can cause SD card corruption on a Raspberry Pi so it is recommended to use an uninterruptible power supply (UPS.) If you ever need to unplug your Raspberry Pi, use the command `sudo shutdown now` or the Domoticz menu item Setup->More Options->Shutdown System to shut it down safely before unplugging.
* Raspberry Pi devices do not come with a real-time clock (RTC) so the clock will not run while the device is unplugged or during a power outage.
	* The OS will perform a network time sync within several minutes of booting, but sensor logging and timers may function at the wrong time until then. In addition, a significant clock change will cause Domoticz to crash.
	* The installation/update script includes an auto-restart function to protect against this, but installing an RTC is recommended.
	* Follow the guide [Adding a Real Time Clock to Raspberry Pi](https://learn.adafruit.com/adding-a-real-time-clock-to-raspberry-pi?view=all) to add an RTC to your Raspberry Pi.
* If a timer event is missed for any reason (such as a communication issue) it will be skipped. For that reason it's recommended to set up a failsafe script (Setup->More Options->Events) in Domoticz. An example [dzVents](https://www.domoticz.com/wiki/DzVents:_next_generation_Lua_scripting) failsafe script `failsafe.script` is included in this repository that checks the status of various switches every 15 minutes and corrects when necessary.

## Author(s) contributions

👤 **Julien Couthouis**

*Initial work and releases*

* Github: [@emc2cube](https://github.com/emc2cube)

👤 **John Christmann**

*Guide and documentation*

* Github: [@JohnChristmann](https://github.com/JohnChristmann/)

## Show your support

Give a ![GitHub stars](https://img.shields.io/github/stars/emc2cube/domoticz_zigbee_install_script?style=social) if this project helped you!

## License

Copyright © 2021.
This project is [GPLv3](https://github.com/emc2cube/domoticz_zigbee_install_script/blob/master/LICENSE) licensed.
