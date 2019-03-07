#!/bin/bash
set -x
set -e
#TODO
# - verificare che nell'immagine x86_64 ci sia il curl
# - fare in modo che quando faccio pull del latest si prenda l'ultima immagine x86_64
# - capire perche' le vm perdono IP statici, forse sto sbagliando sintassi vagrant, uso stesso nome su tutti
# - rendere  robusto script dynu se non c'e' api.ipify.org disponibile
# - capire chi sovrascrive il /etc/resolv.conf (il dhcp?)

# docker1 -> 192.168.122.10
# docker2 -> 192.168.122.11
dockerList=(
docker1
docker2
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
mockupIP="192.168.122.20"
mockupKey=".vagrant/machines/mockup/libvirt/private_key"
mockupUser="vagrant"

_pwd=$PWD
tempDir=$(mktemp -d)

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
  eval ssh  -i \$${_host}Key -o StrictHostKeyChecking=no \$${_host}User@\$${_host}IP \"sudo killall dhclient\"


done



# creation of CA or selfsigned certificate
cd $tempDir
cp -v $_pwd/test/ca.crt $tempDir/
cp -v $_pwd/test/ca.key $tempDir/

##create CA
#openssl genrsa -out ca.key 2048
#openssl req -new -x509 -key ca.key -out ca.crt -config <(
#cat <<-EOF
#[req]
#req_extensions = v3_req
#distinguished_name = dn
#prompt = no
#
#[ v3_req ]
#basicConstraints = CA:FALSE
#keyUsage = nonRepudiation, digitalSignature, keyEncipherment
#
#[ dn ]
#C=IT
#ST=Italy
#L=Trento
#O=End Point
#OU=Testing Domain
#emailAddress=test@example.com
#CN = my test root CA
#EOF
#)


# create certificates
openssl req -new -sha256 -nodes -out api.ipify.org.csr -newkey rsa:2048 -keyout api.ipify.org.key -config <(
cat <<-EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C=IT
ST=Italy
L=Trento
O=End Point
OU=Testing Domain
emailAddress=test@example.com
CN = api.ipify.org

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = api.ipify.org
DNS.2 = www.api.ipify.org
EOF
)
# sign certificate
openssl x509 -req -in api.ipify.org.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out api.ipify.org.crt


cd $_pwd

# fix problem with DHCP
#ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo nmcli connection reload"
#ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo systemctl restart network.service"

# avoidlost IP
ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo ip addr flush eth1 ; sleep 1 ; sudo systemctl restart systemd-networkd.service"
ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo killall dhclient"
# copy of the certificates in the virtual machines
scp -i $mockupKey -o StrictHostKeyChecking=no   $tempDir/api.ipify.org.crt  $mockupUser@$mockupIP:/tmp/api.ipify.org.crt
ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo cp -v /tmp/api.ipify.org.crt /etc/ssl/certs/api.ipify.org.crt"

scp -i $mockupKey -o StrictHostKeyChecking=no   $tempDir/api.ipify.org.key  $mockupUser@$mockupIP:/tmp/api.ipify.org.key
ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo cp -v /tmp/api.ipify.org.key /etc/ssl/private/api.ipify.org.key"

# installation of apache and setup reverse proxy (docker?)
ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo apt update && sudo apt install -y apache2 python3 python3-pip "
ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo pip3 install flask "
ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo pip3 install flask-cors "

# copy or clone of the mockups (docker?)
scp -i $mockupKey -o StrictHostKeyChecking=no   test/mockup/api.ipify.org.py $mockupUser@$mockupIP:/tmp/api.ipify.org.py
ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo cp -v /tmp/api.ipify.org.py /usr/local/bin/api.ipify.org.py && sudo chmod +x /usr/local/bin/api.ipify.org.py"

scp -i $mockupKey -o StrictHostKeyChecking=no   test/mockup/apache.conf $mockupUser@$mockupIP:/tmp/apache.conf
ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo cp -v /tmp/apache.conf /etc/apache2/sites-available/api.ipify.org-ssl.conf && sudo ln -fs ../sites-available/api.ipify.org-ssl.conf /etc/apache2/sites-enabled/api.ipify.org-ssl.conf"

ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo a2enmod ssl "
ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo a2enmod proxy "
ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo a2enmod proxy_http "
ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo systemctl restart apache2 "

# deploy
ansible-playbook -i vagrant-hosts.list deployStack.yml --extra-vars "stack_file=stacks/httpd_es.yml"

ssh -i $mockupKey -o StrictHostKeyChecking=no $mockupUser@$mockupIP "sudo python3 /usr/local/bin/api.ipify.org.py "

# deploy of stack
ansible-playbook -i vagrant-hosts.list deployStack.yml --extra-vars "stack_file=stacks/httpd_es.yml"

[ -n "$tempDir" ] && rm -rf "$tempDir"
