#!/bin/bash

ansible-playbook -i ../test-bm-hosts.list deployStack.yml --extra-vars "stack_file=stacks/httpd_es.yml"

