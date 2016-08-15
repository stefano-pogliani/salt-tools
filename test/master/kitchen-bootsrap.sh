#!/bin/bash
# Bootstrap a salt master for salt-tools.

# Variables.
DATA_DIR="/tmp/kitchen/data"


### MAIN ###
# Install chef (for ruby and busser).
if [ -d "/opt/chef" ]; then
  echo "*** Chef found, skipping install! ***"
else 
  curl -L https://omnitruck.chef.io/install.sh | bash
fi

# Install SaltStack if missing.
if [ -e /usr/bin/salt-master ]; then
  echo "*** Salt Master found, skipping install! ***"
else
  echo "Bootstrapping SaltStack ..."
  ${DATA_DIR}/bootstrap_salt.sh -M -X stable 2016.3
fi

# Bootstrap master with SPM packages.
spm -y local install ${DATA_DIR}/packages/sp-master-conf*.spm
spm -y local install ${DATA_DIR}/packages/sp-spm-repo-conf*.spm

# Ensure the master is in auto_accept mode.
MASTER_AUTO_ACCEPT=/etc/salt/master.d/1000-auto-accept.conf
if [ -e "${MASTER_AUTO_ACCEPT}" ]; then
  echo "*** Salt Master already auto accepting minions! ***"
else
  echo "Configuring salt-master to auto accept minions ..."
  echo "auto_accept: True" > "${MASTER_AUTO_ACCEPT}"
fi

# Set master to localhost.
sed -i 's/#master: salt/master: 127.0.0.1/' /etc/salt/minion

# Copy example salt states and pillars from data.
rsync --recursive "${DATA_DIR}/example/states/" "/srv/spm/salt/"
rsync --recursive "${DATA_DIR}/example/pillar/" "/srv/spm/pillar/"

# Copy the gpg test key for salt secrets.
rsync --recursive "${DATA_DIR}/gpgkeys" "/etc/salt/"
chmod 0700 /etc/salt/gpgkeys

# Start master and minion, and then enter high state.
master_proc=$(ps -ef | grep "salt-master --daemon" | grep -v grep)
if [ ! -z "${master_proc}" ]; then
  echo "*** Salt Master already running. ***"
else
  salt-master --daemon
  sleep 1
fi

minion_proc=$(ps -ef | grep "salt-minion --daemon" | grep -v grep)
if [ ! -z "${minion_proc}" ]; then
  echo "*** Salt Minion already running. ***"
else
  salt-minion --daemon
  sleep 1
fi

salt '*' state.highstate
