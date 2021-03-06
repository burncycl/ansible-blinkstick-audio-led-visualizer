#!/bin/bash

# 2020/10 BuRnCycL
# Script Updates Blinkstick Viz Software. Compares Git hashes. Works in conjunction with a cron job and Ansible.

# App Vars
BSV_SCRIPT="blinkstick-audio-led-visualizer"
BSV_DJANGO="django-blinkstick-audio-led-visualizer"
BSV_ANSIBLE="ansible-blinkstick-audio-led-visualizer"
GIT_BASE_URL="https://github.com/burncycl"
APPS_DIR="/home/pi"
USER="pi"

# Functions
fetch_latest_ansible () {
	rm -rf ${APPS_DIR}/${BSV_ANSIBLE}
	su - ${USER} -c "cd ${APPS_DIR} && git clone ${GIT_BASE_URL}/${BSV_ANSIBLE}.git"
}

stop_services () {
	echo "Stopping blinkstickviz service..."
	systemctl stop blinkstickviz
	systemctl stop nginx
	systemctl stop redis-server
	sleep 1
	killall -9 celery 2&> /dev/null
	killall -9 pulseaudio 2&> /dev/null
	killall -9 uwsgi 2&> /dev/null
}

# Check Network Health
/usr/bin/wget -q --tries=10 --timeout=20 --spider ${GIT_BASE_URL}
if [[ $? -eq 0 ]]; then
	echo "Online - Can Update. Continuing..."

	# Determine what type of node we are.
	IS_RECEIVE=`grep "receive_node" /etc/systemd/system/blinkstickviz.service`
	IS_TRANSMIT=`grep "transmit_node" /etc/systemd/system/blinkstickviz.service`
	IS_DJANGO=`grep "django_node" /etc/systemd/system/blinkstickviz.service`

	if [ ${#IS_RECEIVE} != "0" ]; then
		echo "Determiend Receive Node."
		BSV_SCRIPT_RHASH=`git ls-remote ${GIT_BASE_URL}/${BSV_SCRIPT}.git HEAD | cut -c1-7`
		BSV_SCRIPT_LHASH=`cd ${APPS_DIR}/${BSV_SCRIPT} && git rev-parse --verify HEAD | cut -c1-7`
		if [ "$BSV_SCRIPT_RHASH" = "$BSV_SCRIPT_LHASH" ]; then
			echo "Hashes Match - $BSV_SCRIPT_RHASH = $BSV_SCRIPT_LHASH"
			echo "No Updated Needed."
		else
			echo "Hashes Do Not Match - $BSV_SCRIPT_RHASH != $BSV_SCRIPT_LHASH"
			echo "Update Available. Proceeding..."
			stop_services
			fetch_latest_ansible
			sed -i 's/hosts: transmit_node, receive_nodes/hosts: receive_nodes/g' ${APPS_DIR}/${BSV_ANSIBLE}/blinkstick-visualizer_local.yml # Modify playbook to only target receive node.
			su - ${USER} -c "cd ${APPS_DIR}/${BSV_ANSIBLE} && /usr/bin/make bsv_local"
 			/sbin/reboot
	fi

	elif [ ${#IS_TRANSMIT} != "0" ]; then
		echo "Determined Transmit Node."
		BSV_SCRIPT_RHASH=`git ls-remote ${GIT_BASE_URL}/${BSV_SCRIPT}.git HEAD | cut -c1-7`
		BSV_SCRIPT_LHASH=`cd ${APPS_DIR}/${BSV_SCRIPT} && git rev-parse --verify HEAD | cut -c1-7`
		if [ "$BSV_SCRIPT_RHASH" = "$BSV_SCRIPT_LHASH" ]; then
			echo "Hashes Match - $BSV_SCRIPT_RHASH = $BSV_SCRIPT_LHASH"
			echo "No Updated Needed."
		else
			echo "Hashes Do Not Match - $BSV_SCRIPT_RHASH != $BSV_SCRIPT_LHASH"
			echo "Update Available. Proceeding..."
			stop_services
			fetch_latest_ansible
			sed -i 's/hosts: transmit_node, receive_nodes/hosts: transmit_node/g' ${APPS_DIR}/${BSV_ANSIBLE}/blinkstick-visualizer_local.yml # Modify playbook to only target transmit node.
			su - ${USER} -c "cd ${APPS_DIR}/${BSV_ANSIBLE} && /usr/bin/make bsv_local"
 			/sbin/reboot
		fi

	elif [ ${#IS_DJANGO} != "0" ]; then
		echo "Determined Django Node."
		BSV_DJANGO_RHASH=`git ls-remote ${GIT_BASE_URL}/${BSV_DJANGO}.git HEAD | cut -c1-7`
		BSV_DJANGO_LHASH=`cd ${APPS_DIR}/${BSV_DJANGO} && git rev-parse --verify HEAD | cut -c1-7`
		if [ "$BSV_DJANGO_RHASH" = "$BSV_DJANGO_LHASH" ]; then
			echo "Hashes Match - $BSV_DJANGO_RHASH = $BSV_DJANGO_LHASH"
			echo "No Updated Needed."
		else
			echo "Hashes Do Not Match - $BSV_DJANGO_RHASH != $BSV_DJANGO_LHASH"
			echo "Update Available. Proceeding..."
			stop_services
			fetch_latest_ansible
			su - ${USER} -c "cd ${APPS_DIR}/${BSV_ANSIBLE} && /usr/bin/make bsvapp_local"
 			/sbin/reboot
		fi
	fi
else
	echo "Offline - Cannot Update. Exiting."
	exit 0
fi
