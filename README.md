# High-Availability-at-homes
The project aims to deploy webservices with high availabilty on multiple node in the world

You can read the motivations and the logic about this project on https://medium.com/@fabrizio2210/high-availability-at-homes-dc01439662b3

## Playbooks
There are two playbooks:
- setHA_at_home.yml, creates the infrastructure where the stacks will be deployed;
- deployStack.yml, deploys the stacks adding supporting containers that make the magic happen.

### setHA_at_home.yml
It has to be run on all the nodes.
```
ansible-playbook -i myinventory.ini setHA_at_home.yml
```
### deployStack.yml
It wants as argument the stack to deploy.
```
ansible-playbook -i myinventory.ini deployStack.yml --extra-vars "stack_file=stacks/stackToDeploy.yml"
```
### Inventroy

Example of inventory:
```
[peripheral-raspberry]
node-docker-01 ansible_host=myoffice.xy.no-ip.org ansible_become=yes
node-docker-02 ansible_host=myhome2.xy.no-ip.org  ansible_become=yes

[target:children]
peripheral-raspberry
```
### Stacks to deploy
I can not provide some working stack because it should contain the credential about Dynu.com access.
But I can provide two examples of stack.
The yaml reflects the grammar of Docker stack. I added an additional stanza _HA_at_homes_ to handle some options and credentials.

```
# Simple http example
version: '3.3'
services:
  http:
    image: fabrizio2210/passwordchart

HA_at_homes:
  domain_name: '*******.dynu.net'
  use_traefik: True
  node_name: 'pswchart'
  https: False
  exposed_service: 'http'
  exposed_port: '80'

################
# Dynu credentials
  dynu_user: '*****************'
  dynu_password: '******************'
  dynu_secret: '***************'
  dynu_username: '*******@***.***'
###################
```
Or:
```
version: '3.3'
services:
  grav:
    image: fabrizio2210/grav:x86_64
    environment:
      VIRTUAL_HOST: 'grav.*****.dynu.net'
    volumes:
      - data-grav:/usr/html/user
    restart: always
volumes:
  data-grav:

HA_at_homes:
  domain_name: '****.dynu.net'
  use_traefik: True
  node_name: 'grav'
  https: False
  exposed_service: 'grav'
  exposed_port: '80'

  dynu_user: '**************************'
  dynu_password: '**********************'
  dynu_secret: '******************'
  dynu_username: '*****@****.***'
  csync2_key: '********************'
  proxy_auth: 'proxy:********'
```


### Test
In the project you can find a test.sh script to simulate a scenario with Vagrant.
To have a stack on a fresh virtual infrstructure run:
```
./test.sh stacks/http_es.yml
```

The test script has the following requirements:
- it  has to be run on Linux host
- it wants Vagrant and libvirt/KVM installed
- it needs a Dynu.com account

To install Vagrant with libvirt I can suggest you the following two links:

https://docs.cumulusnetworks.com/display/VX/Vagrant+and+Libvirt+with+KVM+or+QEMU

https://computingforgeeks.com/using-vagrant-with-libvirt-on-linux/

