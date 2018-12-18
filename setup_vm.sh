#!/bin/bash

set -e;

USEFUL_PACKAGES="sysstat mlocate telnet dos2unix wget curl openssh-client openssh-server";
USER_LIST="habiel tevfik andy";

install_useful_packages_centos(){
  USEFUL_PACKAGES="${USEFUL_PACKAGES} vim-enhanced bind-utils";
  sudo yum update -y;
  sudo yum install -y ${USEFUL_PACKAGES};
  return 0;
}

install_useful_packages_ubuntu(){
  sudo apt-get update;
  sudo apt-get upgrade;
  sudo apt-get install ${USEFUL_PACKAGES};
  return 0;
}

create_user_centos()
{
# Creates a user if it does not exist
  USER="$1";
  id "${USER}" || sudo useradd -m "${USER}";
  return 0;
}

create_user_ubuntu()
{
# Creates a user if it does not exist
  USER="$1";
  id "${USER}" || sudo adduser --disabled-password --gecos "${USER}" "${USER}";
  return 0;
}

create_ssh_keys()
{
  USER="$1";
  HOME_DIRECTORY="$(cat /etc/passwd | grep "${USER}" | cut -d: -f6)";
  readlink -e "${HOME_DIRECTORY}";
  ID_FILE="${HOME_DIRECTORY}/.ssh/id_rsa";
  SSH_DIRECTORY="$(dirname "${ID_FILE}")";
  AUTHORIZED_KEYS="${SSH_DIRECTORY}/authorized_keys";
  
  if [[ ! -f "${ID_FILE}" ]]; then
    sudo mkdir -vp "${SSH_DIRECTORY}";
    sudo ssh-keygen -t rsa -C "${USER}" -f "${ID_FILE}" -P ""
    sudo su -c "cat '${ID_FILE}.pub' >> '${AUTHORIZED_KEYS}'";
  fi
  sudo chown -Rv ${USER}:${USER} "${SSH_DIRECTORY}";
  return 0;
}

give_sudo_rights()
{
  USER="$1";
  SUDOERS_FILE="./${USER}_sudo";
  echo "${USER}  ALL=(ALL)       NOPASSWD: ALL" > "${SUDOERS_FILE}";
  sudo cp -v "${SUDOERS_FILE}" /etc/sudoers.d/;
  sudo rm -v "${SUDOERS_FILE}";

  return 0;
}


##########################################################################################
################################### ACTUAL EXECUTION #####################################
##########################################################################################


cat /etc/*release | grep -iq -e "centos" -e "rhel" && OPERATING_SYSTEM="CENTOS";
cat /etc/*release | grep -iq "ubuntu" && OPERATING_SYSTEM="UBUNTU";


case ${OPERATING_SYSTEM} in
"CENTOS")
  install_useful_packages_centos;
  for USER in ${USER_LIST}; do
    create_user_centos "${USER}";
	create_ssh_keys "${USER}";
	give_sudo_rights "${USER}";
  done;
  ;;
"UBUNTU")
  install_useful_packages_ubuntu;
  for USER in ${USER_LIST}; do
    create_user_ubuntu "${USER}";
	create_ssh_keys "${USER}";
	give_sudo_rights "${USER}";
  done
  ;;
*)
  echo "Could not determine operating system";
  exit 1;
  ;;
esac

exit 0;
