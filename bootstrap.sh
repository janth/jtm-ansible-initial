#!/bin/bash

#ansible_ver=2.9
gitrepo=https://github.com/janth/jtm-ansible-initial.git

script_name=${0##*/}                               # Basename, or drop /path/to/file
script=${script_name%%.*}                          # Drop .ext.a.b
script_path=${0%/*}                                # Dirname, or only /path/to
script_path=$( [[ -d ${script_path} ]] && cd ${script_path} ; pwd)             # Absolute path
script_path_name="${script_path}/${script_name}"   # Full path and full filename to $0
absolute_script_path_name=$( /bin/readlink --canonicalize ${script_path}/${script_name})   # Full absolute path and filename to $0
absolute_script_path=${absolute_script_path_name%/*}                 # Dirname, or only /path/to, now absolute
script_basedir=${script_path%/*}                   # basedir, if script_path is .../bin/

set -o pipefail
set -o braceexpand
set -o allexport
set -o noclobber
set -o errexit
set -o nounset

if [[ -n ${SUDO_USER} ]] ; then
   echo "ERROR: This script must not be run using sudo."
   echo "Please re-run as yourself"
   exit 1
fi

log () {
   echo "$@"
}

declare -a pkgs=( python3-pip aptitude git wget )
for p in ${pkgs[*]} ; do
   /usr/bin/dpkg -l ${p} >/dev/null 2>&1 || { 
      log "Installing ${p}"
      /usr/bin/sudo DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get install -qq ${p} >/dev/null
}
done

# sudo pip3 install 'ansible==2.7.2'
log "Installing ansible (if not already installed)"
#/usr/bin/pip3 list | /usr/bin/grep '^ansible\s' > /dev/null || /usr/bin/sudo /usr/bin/pip3 install "ansible==${ansible_ver}" --progress-bar off
/usr/bin/pip3 list | /usr/bin/grep '^ansible\s' > /dev/null || /usr/bin/sudo /usr/bin/pip3 install ansible --progress-bar off
/usr/local/bin/ansible --version

set -o errexit
set -o nounset

MYSUDO=/etc/sudoers.d/00-sudoers-defaults
echo "Install ${MYSUDO}"
/usr/bin/sudo -v
{
cat << SUDOERS
# This file is managed by Ansibel/Puppet/TBD

### JanThM added
Defaults   insults
Defaults   !requiretty
Defaults   log_year
Defaults   log_host
Defaults   syslog=authpriv
Defaults   root_sudo
Defaults   set_home
Defaults   set_utmp
Defaults   loglinelen=0
#Defaults   passprompt="Sir/Madam, please provide [sudo] password for %p@%h (for running as %U): "
#Defaults   passprompt=“[sudo] password for %p:”
#Defaults   badpass_message="Sorry, try again."
Defaults   listpw=never
Defaults   logfile=/var/log/sudo.log
###

centos ALL=(ALL:ALL) NOPASSWD:ALL
vagrant ALL=(ALL:ALL) NOPASSWD:ALL

# Allow members of group wheek to execute any command
%wheel ALL=(ALL:ALL) NOPASSWD:ALL

# Allow members of group sudo to execute any command
%sudo ALL=(ALL:ALL) NOPASSWD:ALL
SUDOERS
} | /usr/bin/sudo /usr/bin/tee ${MYSUDO} > /dev/null
/usr/bin/sudo /bin/chmod --verbose 0440 ${MYSUDO}
/usr/bin/sudo /bin/chown --verbose root:root ${MYSUDO}
#/bin/ls -l ${MYSUDO}
/usr/bin/sudo /usr/sbin/visudo --check --strict --file=${MYSUDO}


ssh_id=${HOME}/.ssh/id_ed25519

umask 0022
[[ ! -d ${ssh_id%/*} ]] && mkdir ${ssh_id%/*}
if [[ ! -r ${ssh_id} ]] ; then
   echo "Generating ssh id for you (${ssh_id} does not exists)"
   /usr/bin/ssh-keygen -a 100 -t ed25519 -f ${ssh_id}
fi
if [[ ! -r ${ssh_id%/*}/authorized_keys ]] ; then
   /usr/bin/cp ${ssh_id}.pub ${ssh_id%/*}/authorized_keys
else
   /usr/bin/cat ${ssh_id}.pub >> ${ssh_id%/*}/authorized_keys
fi

reprodir=${gitrepo##*/}
repodir=${repodir%.*}
git clone ${gitrepo} ${repordir}
cat << X
Now do:
cd ${repodir}

./run-eg.sh

to get some examples of how to run ansible

X
