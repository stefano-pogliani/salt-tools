SaltStack Tools
===============
A set of tools to run and manage SaltStack deployments.

These tools complement a package based approach to states and configuration.
The script `bin/saltify` configures the session to use these scripts.
The packages directory can be set with the `SALTIFY_PACKAGE`
environment variable and defaults to `${PWD}/../salt-packages`.


Master tests
------------
While packages are tested indipendenlty using `kitchen-salt` there is a need to
also test that a salt-master is configured correctly in a bootstrap scenario.

On top of that having a virtual `salt-master` auto-configured in minutes
is very useful for testing and experimenting.

The virtual `salt-master` is created with [kitchen](http://kitchen.ci/)
and `kitchen-docker`.
Assuming you have `ruby` and `docker` installed, run the following:
```bash
. bin/saltify
install-gems

cd test/master
./collect-packages
kitchen converge docker
```


From zero to master
-------------------
This are the step to create a new `salt-master` that runs in the
way I described in http://www.spogliani.net/content/blog/saltstack-setup/

  1. Download the latest raspbian from https://www.raspberrypi.org/downloads/raspbian/
  2. Install it to an sdcard and start the RPi.
  3. Upload [salt-bootstrap.sh](https://github.com/saltstack/salt-bootstrap)
     and all SPM packages (see https://github.com/stefano-pogliani/salt-packages)
     to the RPi.
  4. Install the `salt-master`.
  5. Install essential SPM packages using local install.
  6. Accept any salt-minion keys needed.
  7. Use salt-master orchestration to highstate all minions in the correct
     order.

Commands to do the above:
```bash
# TODO: image install

# Find RPi IP
sudo nmap 10.42.0.0/24
export RPI_IP="RPI IP ADDRESS"

# Prepare system
ssh pi@${RPI_IP}
sudo apt-get update
sudo apt-get upgrade
sudo raspi-config
sudo mkdir /data
sudo vi /etc/fstab
#  /dev/mmcblk0p3  /data           ext4    defaults,noatime  0       1
sudo shutdown -r now

# Copy salt script and packages.
scp -r ../salt-packages/out/ pi@${RPI_IP}:~/spm-packages
ssh pi@${RPI_IP}
wget https://github.com/saltstack/salt-bootstrap/raw/stable/bootstrap-salt.sh
chmod +x bootstrap-salt.sh

# Install salt and packages to configure SPM repo.
sudo ./bootstrap-salt.sh -M -X -i "lon01-lef0"
sudo systemctl stop salt-minion
sudo systemctl stop salt-master

sudo spm local install spm-packages/sp-master-conf-201701-1.spm
sudo spm local install spm-packages/sp-nginx-201608-1.spm
sudo spm local install spm-packages/sp-spm-repo-201701-1.spm

sudo systemctl start salt-master
sudo systemctl start salt-minion

sudo salt lon01-lef0 saltutil.sync_states
sudo salt lon01-lef0 state.sls sp.spm.repo

# Fill and update SPM repo.
sudo rm /data/www/spm/repo/*
sudo cp spm-packages/* /data/www/spm/repo
sudo spm create_repo /data/www/spm/repo

# Can now install the SPM repo and the needed packages.
sudo spm local install spm-packages/sp-spm-repo-conf-201701-1.spm
sudo spm update_repo
sudo spm install --force sp-glue

# Set up GPG key
sudo mkdir -p /etc/salt/gpgkeys
sudo chmod 0700 /etc/salt/gpgkeys
sudo cp master-keys/* /etc/salt/gpgkeys
rm -r master-keys/
```


VirtualPi with QEMU (broken)
----------------------------
It is possible to run a virtualise RPi using QEMU.

Install QEMU and create an image:
```bash
sudo dnf install qemu
export VIRPI_IMAGE=virpi/2016-09-23-raspbian-jessie-lite.img
virpi/make-image.sh
```

Run QEMU from the generated cow image:
```bash
virpi/run.sh "virpi/workdir"
```
