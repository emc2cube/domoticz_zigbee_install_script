#!/usr/bin/env bash

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

# Check for a "config" file in the same directory than the script, if present load custom options from it
if [ -f "$(dirname "$(realpath "${0}")")/config" ]
then
	echo ""
	source "$(dirname "$(realpath "${0}")")/config"
	echo "Custom configuration file imported"
fi

echo ""
echo "Domoticz: $(if [ "${domoticzbeta}" = true ]; then echo "Beta"; else echo "Stable"; fi)"
echo "Homebridge: ${homebridge}"
echo "Zigbee: ${zigbee}"
echo "MySensors: ${mysensors} $(if [ -n "${irqpin}" ]; then echo "with IRQ pin on GPIO ${irqpin}"; fi)"

# Make sure all filesystems are in rw mode
sudo mount -o remount,rw /
sudo mount -o remount,rw /boot

# Update system
echo ""
echo "system: Updating..."
sudo apt-get update && sudo apt-get -y upgrade
echo "system: Updated."

# Update domoticz
echo ""
if [ ! -d /home/pi/domoticz ]
then
	echo "domoticz: Installing..."
	echo "For dedicated installations it is recommended to choose the port 80 for HTTP and 443 for HTTPS"
	curl -sSL install.domoticz.com | sudo bash
	if [ "${domoticzbeta}" = true ]
	then
		echo "domoticz: switching to beta..."
		cd /home/pi/domoticz/ || exit
		./updatebeta
	fi
	# Install the auto restart domoticz service from https://github.com/agambier/domoticz_addons
	sudo curl https://raw.githubusercontent.com/agambier/domoticz_addons/master/systemd/domoticz.service.d/restart.conf --create-dirs -o /etc/systemd/system/domoticz.service.d/restart.conf
	sudo systemctl daemon-reload
	echo "domoticz: Installed."
else
	echo "domoticz: Updating..."
	cd /home/pi/domoticz/ || exit
	if [ "${domoticzbeta}" = false ]
	then
		./updaterelease
	else
		./updatebeta
	fi
	echo "domoticz: Updated."
fi

# homebridge
if [ "${homebridge}" = true ]
then
	echo ""
	if [ "$(whereis homebridge)" = "homebridge:" ]
	then
		echo "homebridge: Installing"
		if [ "$(whereis node)" = "node:" ]
		then
			echo "node: Installing..."
			curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
			sudo apt-get install -y nodejs
			sudo npm install -g npm
			echo "node: Installed."
		fi
		if [ "$(whereis mosquitto)" = "mosquitto:" ]
		then
			echo "mosquitto: Installing..."
			sudo apt-get install -y mosquitto mosquitto-clients python3-dev
			sudo systemctl enable mosquitto.service
			sudo systemctl start mosquitto.service
			echo "mosquitto: Installed."
		fi
		sudo npm install -g --unsafe-perm homebridge homebridge-config-ui-x homebridge-edomoticz homebridge-alexa homebridge-gsh
		sudo hb-service install --user homebridge
		echo ""
		echo "homebridge installed, configure it at"
		echo "http://$(hostname -A | tr -d '[:space:]'):8581"
		echo "default is admin:admin - change it as soon as possible"
	else
		echo "homebridge: Updating..."
		sudo npm install -g --unsafe-perm homebridge homebridge-config-ui-x homebridge-edomoticz homebridge-alexa homebridge-gsh
		sudo systemctl restart homebridge
		echo "homebridge: Updated."
	fi
fi

# MySensors
if [ "${mysensors}" = true ]
then
	echo ""
	if [ ! -d /home/pi/MySensors/ ]
	then
		echo "MySensors gateway: Installing..."
		git clone https://github.com/mysensors/MySensors.git /home/pi/MySensors --branch master
		cd /home/pi/MySensors/ || exit
		./configure
		make
		sudo make install
		sudo systemctl enable mysgw
		sudo systemctl start mysgw
		echo "MySensors gateway: Installed."
	else
		echo "MySensors gateway: Updating..."
		cd /home/pi/MySensors/ || exit
		git fetch
		if [ "$(git rev-parse HEAD)" == "$(git rev-parse "@{u}")" ]
		then
			echo "MySensors gateway: Already up-to-date."
		else
			git pull
			if [ -n "${irqpin}" ]
			then
				# With IRQ
				./configure --my-rf24-irq-pin=${irqpin}
			else
				# Without IRQ
				./configure
			fi
			make
			sudo make install
			sudo systemctl restart mysgw
			echo "MySensors gateway: Updated."
		fi
	fi
fi

# Zigbee
if [ "${zigbee}" = true ]
then

	# zigbee2mqtt
	echo ""
	if [ ! -d /opt/zigbee2mqtt ]
	then
		echo "zigbee2mqtt: Installing..."
		if [ "$(whereis node)" = "node:" ]
		then
			echo "node: Installing..."
			curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
			sudo apt-get install -y nodejs
			sudo npm install -g npm
			echo "node: Installed."
		fi
		if [ "$(whereis mosquitto)" = "mosquitto:" ]
		then
			echo "mosquitto: Installing..."
			sudo apt-get install -y mosquitto mosquitto-clients python3-dev
			sudo systemctl enable mosquitto.service
			sudo systemctl start mosquitto.service
			echo "mosquitto: Installed."
		fi
		sudo git clone https://github.com/Koenkk/zigbee2mqtt.git /opt/zigbee2mqtt
		sudo chown -R pi:pi /opt/zigbee2mqtt
		cd /opt/zigbee2mqtt || exit
		npm ci
		mkdir -p /opt/zigbee2mqtt/data
		cat >> "/opt/zigbee2mqtt/data/configuration.yaml" << NEWAPI
experimental:
  new_api: true
frontend:
  port: 1890
NEWAPI
		sudo bash -c "cat > /etc/systemd/system/zigbee2mqtt.service" << SYSTEMD
[Unit]
Description=zigbee2mqtt
After=network.target

[Service]
ExecStart=/usr/bin/npm start
WorkingDirectory=/opt/zigbee2mqtt
StandardOutput=inherit
StandardError=inherit
Restart=always
User=pi

[Install]
WantedBy=multi-user.target
SYSTEMD
		sudo systemctl start zigbee2mqtt
		sudo systemctl enable zigbee2mqtt.service
		echo "zigbee2mqtt: Installed."
		echo "Standalone web interface available on"
		echo "http://$(hostname -A | tr -d '[:space:]'):1890"
	else
		echo "zigbee2mqtt: Updating..."
		# Stop zigbee2mqtt and go to directory
		sudo systemctl stop zigbee2mqtt
		cd /opt/zigbee2mqtt || exit
		# Backup configuration
		cp -R data data-backup
		# Update
		#git reset --hard
		git checkout HEAD -- npm-shrinkwrap.json
		git fetch
		#git checkout dev # Change 'dev' to 'master' to switch back to the release version
		if [ "$(git rev-parse HEAD)" == "$(git rev-parse "@{u}")" ]
		then
			# Restore configuration
			cp -R data-backup/* data
			rm -rf data-backup
			# Start zigbee2mqtt
			sudo systemctl start zigbee2mqtt
			echo "zigbee2mqtt: Already up-to-date."
		else
			git pull
			npm ci
			# Restore configuration
			cp -R data-backup/* data
			rm -rf data-backup
			# Start zigbee2mqtt
			sudo systemctl start zigbee2mqtt
			echo "zigbee2mqtt: Updated."
		fi
	fi

	# zigbee2mqtt plugin
	echo ""
	if [ ! -d /home/pi/domoticz/plugins/Zigbee2Mqtt/ ]
	then
		echo "zigbee2mqtt domoticz plugin: Installing..."
		cd /home/pi/domoticz/plugins/ || exit
		git clone https://github.com/stas-demydiuk/domoticz-zigbee2mqtt-plugin.git Zigbee2Mqtt --branch master
		echo "zigbee2mqtt domoticz plugin: Installed."
	else
		echo "zigbee2mqtt domoticz plugin: Updating..."
		cd /home/pi/domoticz/plugins/Zigbee2Mqtt/ || exit
		git fetch
		if [ "$(git rev-parse HEAD)" == "$(git rev-parse "@{u}")" ]
		then
			echo "zigbee2mqtt domoticz plugin: Already up-to-date."
		else
			git pull
			echo "zigbee2mqtt domoticz plugin: Updated."
		fi
	fi

fi

# Make sure all changes are properly written on disk
sync

echo ""
echo "Restarting domoticz to apply all changes"
sudo systemctl restart domoticz
echo "Your installation is now up to date."

exit 0