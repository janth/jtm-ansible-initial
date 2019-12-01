base role
=========

Basic configuration of Centos7 for Genesis

Requirements
------------

None

Role Variables
--------------

Dependencies
------------

None

Tags
------------
Using tags and varibles to limit which tasks are applied

# do yum update
do_yumupdate: true

# Avoid adding the epel repo
skip_epel: true

# Avoid messing with disk devices and mountpoints in fstab
skip_devs: true

# Avoid installing the @base group packages
skip_basepkgs: true

# Avoid setting SELinux to permissive
selinux_enforce: true

# Avoid creating /data root:root 0755
skip_datadir: true

Logging
------------

Logging of bash commands for every user is accomplished through /etc/profile.d/**bashrc-logging.sh** (source: files/bash-logging.sh) (automatically sourced at login)
The script tries to pick up / determine the remote user from the sshd logging, and then sets PROMPT_COMMAND (the contents of this variable are executed as a regular Bash command just before Bash displays a prompt).
PROMPT_COMMAND is set to log to syslog using the utility logger(1)

Changes to rsyslog config:
/etc/rsyslog.d/50-sshkey.conf (source: files/50-sshkey.conf) Duplicate mathing messages to separate file (amongst other things...):
```
:msg, contains, "Accepted publickey for " /var/log/ssh-logon.log
```

**bashrc-log.sh** reads last line from /var/log/ssh-logon.log and then uses /etc/sshkeys2user.map (source: files/ssh-key-fingerprints) to map the fingerprint to a user.


/etc/sshkeys2user.map (source: files/ssh-key-fingerprints)
Generating the file:
```

# Get fingerprint of single file
ssh-keygen -l -f ~/.ssh/id_rsa.pub

# run at top of ansible repo:
 while IFS= read -r ln ; do echo $ln | ssh-keygen -lf - ; done < <( grep -h  -- "- 'ssh" host_vars/* group_vars/* | sed -e "s/^.*'ssh/ssh/" | sort -u | sed -e "s/'$//"  ) | sed -e 's/^.*SHA256//' -E -e 's/\(RSA|ED25519\)//' -e 's/[ ()]*$//' -e 's/ /:/' | awk -F: '{print $3 ":" $2}' | sort -t: -k2,2 -u

# Run on a host
for fp in $( grep -o 'SHA256:.*$' /var/log/ssh-logon.log | sort -u ) ; do grep $fp /var/log/ssh-logon.log | tail -1 ; done


```


It is not hard at all to circumvent or disable this logging, so it is not at all intended as any form of audit, but more as a trace of events/commands.


(bash have had history to syslog feature since version 4.1, but it is disabled by default (#define SYSLOG_HISTORY)...)

For audit, use the builtin auditd with appropriate config...

Other alternative to PROMPT_COMMAND is https://github.com/a2o/snoopy (which uses LD_PRELOAD to enable logging), or use the trap DEBUG hack suggested at the end of bashrc-logging.sh

Links:
* https://jichu4n.com/posts/debug-trap-and-prompt_command-in-bash/
* http://mywiki.wooledge.org/BashFAQ/077
* https://access.redhat.com/solutions/20707
* https://www.loggly.com/ultimate-guide/managing-linux-logs/
* Google centos auditd...
