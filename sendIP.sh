#!/bin/bash

# Send Email when IP Address Changes
# Source:
# https://ariandy1.wordpress.com/2014/04/08/linux-send-email-when-ip-address-changes/
 
MYIP="$(ifconfig eno1 | grep 'inet'| awk '{print $2}' | cut -d ':' -f 2)";
PUBLICIP="$(curl https://ipinfo.io/ip)"
TIME="$(date)";
 
LASTIPFILE='/home/amplicade/.last_ip_addr';
PUBLICIPFILE='/home/amplicade/.last_publicip_addr';
LASTIP="$(cat "${LASTIPFILE}")";
LASTPUBLICIP="$(cat "${PUBLICIPFILE}")";
 
if [[ "${PUBLICIP}" != "${LASTPUBLICIP}" ]]
then
        echo "New public IP = '${PUBLICIP}'"
        echo "sending email.."
        echo -e "Hello\n\nTimestamp = ${TIME}\nPublicIP = ${PUBLICIP}\n\nBye" | \
                /usr/bin/mail -s "[INFO] New IP" apps@amplicade.com;
        echo "${PUBLICIP}" > "${PUBLICIPFILE}";
else
        echo "no public IP change!"
fi

# Enable cron job if it is not enabled
SCRIPT_FILE="$(readlink -e "${BASH_SOURCE}")";
FILENAME="$(basename "${SCRIPT_FILE}")";
crontab -l | grep "${FILENAME}" && exit 0;
find /etc/cron*/${FILENAME} && exit 0;
cp -v "${SCRIPT_FILE}" "/etc/cron.hourly/";
