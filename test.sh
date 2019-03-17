#!/bin/bash
set -x
set -e
#TODO
# - fare in modo che quando faccio pull del latest si prenda l'ultima immagine x86_64

# docker1 -> 192.168.122.10
# docker2 -> 192.168.122.11
# mockup  -> 192.168.122.20
dockerList=(
docker1
docker2
docker3
)
certificateList=(
api.ipify.org
)
docker1Key=".vagrant/machines/docker1/libvirt/private_key"
docker1IP="192.168.122.10"
docker1User="vagrant"
docker2Key=".vagrant/machines/docker2/libvirt/private_key"
docker2IP="192.168.122.11"
docker2User="vagrant"
docker3IP="192.168.122.12"
docker3User="vagrant"
docker3Key=".vagrant/machines/docker3/libvirt/private_key"
mockupIP="192.168.122.20"
mockupKey=".vagrant/machines/mockup/libvirt/private_key"
mockupUser="vagrant"

stackToDeploy=$1
_pwd=$PWD
tempDir=$(mktemp -d)

if [ ! -e $stackToDeploy ] ; then
  echo "The stack \"$stackToDeploy\" doesn't exist, define another one"
  exit 1
fi
# Vagrant up
vagrant up

# Set infrastructure

ansible-playbook -i vagrant-hosts.list setHA_at_home.yml

# Edit /etc/hosts to point to
# getip api
# dynu api
# dns resolver
for _host in ${dockerList[@]} ; do
#  eval ssh  -i \$${_host}Key -o StrictHostKeyChecking=no \$${_host}User@\$${_host}IP \"sudo nmcli connection reload  \"
#  eval ssh  -i \$${_host}Key -o StrictHostKeyChecking=no \$${_host}User@\$${_host}IP \"sudo systemctl restart network.service  \"
  eval ssh  -i \$${_host}Key -o StrictHostKeyChecking=no \$${_host}User@\$${_host}IP \"sudo apt install -y dnsmasq \"
  eval ssh  -i \$${_host}Key -o StrictHostKeyChecking=no \$${_host}User@\$${_host}IP \"sudo apt-get purge -y  dns-root-data \"
  eval ssh  -i \$${_host}Key -o StrictHostKeyChecking=no \$${_host}User@\$${_host}IP \"sudo su -c \\\"echo nameserver 127.0.0.1 \> /etc/resolv.conf \\\"  \"
  eval ssh  -i \$${_host}Key -o StrictHostKeyChecking=no \$${_host}User@\$${_host}IP \"sudo chmod 444 /etc/resolv.conf \"
  eval ssh  -i \$${_host}Key -o StrictHostKeyChecking=no \$${_host}User@\$${_host}IP \"grep -q server /etc/dnsmasq.d/docker.conf \|\| sudo su -c \\\"echo server=1.1.1.1 \>\> /etc/dnsmasq.d/docker.conf \\\"  \"
  eval ssh  -i \$${_host}Key -o StrictHostKeyChecking=no \$${_host}User@\$${_host}IP \"grep -q addn-hosts /etc/dnsmasq.d/docker.conf \|\| sudo su -c \\\"echo addn-hosts=/etc/hosts \>\> /etc/dnsmasq.d/docker.conf \\\"  \"
  eval ssh  -i \$${_host}Key -o StrictHostKeyChecking=no \$${_host}User@\$${_host}IP \"sudo su -c \\\"echo $mockupIP api.ipify.org \>\> /etc/hosts \\\"  \"
  eval ssh  -i \$${_host}Key -o StrictHostKeyChecking=no \$${_host}User@\$${_host}IP \"sudo systemctl restart dnsmasq\"
  eval ssh  -i \$${_host}Key -o StrictHostKeyChecking=no \$${_host}User@\$${_host}IP \"sudo systemctl restart docker\"
  eval ssh  -i \$${_host}Key -o StrictHostKeyChecking=no \$${_host}User@\$${_host}IP \"sudo ip addr flush eth1 \; sleep 1 \; sudo systemctl restart systemd-networkd.service\"
  eval ssh  -i \$${_host}Key -o StrictHostKeyChecking=no \$${_host}User@\$${_host}IP \"pgrep dhclient \&\& sudo killall dhclient \|\| echo nessun dhclient \"


done


# fix problem with DHCP
# avoidlost IP
ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo ip addr flush eth1 ; sleep 1 ; sudo systemctl restart systemd-networkd.service"
ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo killall dhclient"
# copy of the certificates in the virtual machines

# installation of apache and setup reverse proxy (docker?)
ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo apt update && sudo apt install -y python3 python3-pip "
ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo pip3 install flask "
ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo pip3 install flask-cors "

# copy or clone of the mockups (docker?)
scp -i $mockupKey -o StrictHostKeyChecking=no   test/mockup/api.ipify.org.py $mockupUser@$mockupIP:/tmp/api.ipify.org.py
ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo cp -v /tmp/api.ipify.org.py /usr/local/bin/api.ipify.org.py && sudo chmod +x /usr/local/bin/api.ipify.org.py"


# deploy
ansible-playbook -i vagrant-hosts.list deployStack.yml --extra-vars "stack_file=$stackToDeploy"

ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo python3 /usr/local/bin/api.ipify.org.py "


[ -n "$tempDir" ] && rm -rf "$tempDir"
