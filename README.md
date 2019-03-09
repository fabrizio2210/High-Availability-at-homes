# High-Availability-at-homes
The project aims to deploy webservices with high availabilty on multiple node in the world

You can read the motivations and the logic about this project on https://medium.com/@fabrizio2210/high-availability-at-homes-dc01439662b3

## Playbooks
There are two playbooks:
- setHA_at_home.yml, creates the infrastructure where the stacks will be deployed;
- deployStack.yml, deploys the stacks adding supporting containers that make the magic happen.

### setHA_at_home.yml
It has to be run on all the nodes.
ansible-playbook -i myinventory.ini setHA_at_home.yml

### deployStack.yml
It wants as argument the stack to deploy

ansible-playbook -i myinventory.ini deployStack.yml --extra-vars "stack_file=stacks/stackToDeploy.yml"


Example of inventory:

[peripheral-raspberry]
node-docker-01 ansible_host=myoffice.xy.no-ip.org ansible_become=yes
node-docker-02 ansible_host=myhome2.xy.no-ip.org  ansible_become=yes

[target:children]
peripheral-raspberry

