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

## Requirements

A Raspberry Pi. When possible buy them from official distributors, not from amazon third party sellers.
* Recommended [Raspberry Pi 4 Model B](https://www.raspberrypi.org/products/raspberry-pi-4-model-b/).
* Minimal supported configuration [Raspberry Pi 3 Model B+](https://www.raspberrypi.org/products/raspberry-pi-3-model-b-plus/).

A case of your liking adapted to the model you are using.

A new SD card. SD cards are to be considered as disposable, especially if your Raspberry Pi is subject to power outages SD card will eventually break down.
Cards optimised for high R/W operations are recommended, such as Samsung PRO Endurance series ([Buy on amazon](https://amzn.to/2XOH0c3)) or others.

Install [Raspberry Pi OS Lite](https://www.raspberrypi.org/software/operating-systems/#raspberry-pi-os-32-bit) (recommended).
Use the [Raspberry Pi Imager](https://www.raspberrypi.org/software/) for easy install of the OS on the SD card. "Raspberry Pi OS Lite" is available under the "Raspberry Pi OS (other)" menu.
Follow the documentation on how to [enable SSH on a headless Raspberry Pi](https://www.raspberrypi.org/documentation/remote-access/ssh/README.md) and if needed [configure WiFi](https://www.raspberrypi.org/documentation/configuration/wireless/headless.md).
For convenience a ```ssh``` and a ```wpa_supplicant.conf``` file are included. Edit wpa_supplicant.conf as needed (Country code and WiFi information) and copy both files on the "boot" partition of your SD card.

A [supported adapter](https://www.zigbee2mqtt.io/information/supported_adapters.html) flashed with the zigbee2mqtt firmware ([Buy one already flashed](https://www.aliexpress.com/item/4000818147676.html)).

## Usage

While this script may be adapted to work with previous versions, in it's actual state it will not work as [nodesource](https://nodesource.com) do not provide distributions of Node v12 for older hardware.

```sh
sudo apt-get install git
git clone https://github.com/emc2cube/domoticz_zigbee_install_script.git /home/pi/domoticz_zigbee_install_script
chmod +x /home/pi/domoticz_zigbee_install_script/update_domoticz.sh
/home/pi/domoticz_zigbee_install_script/update_domoticz.sh
```

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
