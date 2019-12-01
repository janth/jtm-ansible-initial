```
wget -qO- https://raw.githubusercontent.com/janth/jtm-ansible-initial/master/bootstrap.sh | bash
```
(do NOT pipe with sudo)


Now do:
cd ${repodir} && ./run-eg.sh

to get some examples of how to run ansible

Config files:
ansible.cfg
hosts

Playbook (what to run):
plays/base.yml

Varialbles ( = puppet hieradata):
group_vars/all.yml

Ansible code:
roles/jtm.base/tasks/main.yml


Collection of interresting ansible urls: [urls.md]


