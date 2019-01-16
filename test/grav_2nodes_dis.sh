#!/bin/bash

ansible-playbook -i ../test-hosts.list deployStack.yml --extra-vars "stack_file=stacks/grav.yml" --extra-vars "uninstall=True"

