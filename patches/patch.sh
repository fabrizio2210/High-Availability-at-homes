#!/bin/bash

# if < 2.7 
#sudo patch /lib/ansible/modules/cloud/docker/docker_network.py docker_network.patch

# if >2.7
sudo patch /usr/lib/python2.7/dist-packages/ansible/modules/cloud/docker/docker_network.py docker_network.patch
