#!/bin/bash
# check and send ip address to email
 
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
