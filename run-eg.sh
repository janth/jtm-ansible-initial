#!/bin/bash

cat << X

# sudo apt install python3-pi aptitude
# sudo pip3 nstall 'ansible==2.7.2'
# sudo pip3 install ansible

ansible --version

ansible-playbook plays/base.yml --syntax-check
ansible-playbook plays/base.yml --check
ansible-playbook plays/base.yml --check --diff
ansible-playbook plays/base.yml -v
ansible-playbook plays/base.yml -vv
ansible-playbook plays/base.yml -vvv
ansible-playbook plays/base.yml -vvvv
ansible-playbook plays/base.yml --limit "host1,host2"
ansible-playbook plays/base.yml --limit "all:!host1,host2"
ansible-playbook plays/base.yml --limit "all:!host1,host2" --list-hosts
ansible-playbook plays/base.yml --extra-vars="skip_epel=true" -e "skip_devs=true"
ansible-playbook plays/base.yml --list-tags
ansible-playbook plays/base.yml --tags="sshkeys"
ansible-playbook plays/base.yml --tags "sshkeys,g_bashrc"
ansible-playbook plays/base.yml --skip-tags 'sudoers'
ansible-playbook plays/base.yml --start-at-task=foobar
ansible-playbook plays/base.yml --step

X
