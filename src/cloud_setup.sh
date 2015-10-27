#!/bin/bash
#===============================================================================
#
#          FILE: cloud_setup.sh
# 
#         USAGE: ./cloud_setup.sh dns password
# 
#   DESCRIPTION: Configure SSH connection to Azure VM
# 
#       OPTIONS: ---
#  DEPENDENCIES: sshpass
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raphael P. Ribeiro
#  ORGANIZATION: GSD-UFAL
#       CREATED: 23-09-2015 16:09
#===============================================================================

host=$1
passwd=$2
ssh_folder=$HOME/.ssh
ssh_key=$HOME/.ssh/azkey

# file descriptors to logging
# Based: http://serverfault.com/questions/103501/how-can-i-fully-log-all-bash-scripts-actions

exec 3>&1 4>&2 #Saves file descriptors so they can be restored to whatever they were before redirection or used themselves to output to whatever they were before the following redirect.
trap 'exec 2>&4 1>&3' 0 1 2 3 # Restore file descriptors for particular signals. Not generally necessary since they should be restored when the sub-shell exits.
exec 1>cloud_setup.log 2>&1 # Redirect stdout to file log.out then redirect stderr to stdout. Note that the order is important when you want them going to the same file. stdout must be redirected before stderr is redirected to stdout.

echo "----- $(date) -----"

if [[ -z "$1" || -z "$2" ]]
  then
    echo "ERROR: No argument supplied!"
    echo "USAGE: cloud_setup.sh dns password"
    exit 1
fi
    
# check sshpass installation
[[ ! -e $(which sshpass) ]] && echo "** ERROR: Please, install sshpass!" && exit 1

configure_ssh() {
    ssh-keygen -f $ssh_folder/known_hosts -R $host
    rm -rf $ssh_key "$ssh_key".pub
    ssh-keygen -b 2048 -t rsa -f "$ssh_key" -q -N "" && chmod 600 "$ssh_key"*
    # copy ssh key to Azure VM
    cat "$ssh_key".pub | sshpass -p $passwd ssh -o StrictHostKeyChecking=no dockeru@$host 'umask 077; mkdir -p ~/.ssh; cat >> ~/.ssh/authorized_keys'
    if [[ $? == 0 ]]; then
        echo "** SSH successfully configured" && true
    else
        echo "** ERROR: SSH configuration failed! Cannot connect to hostname."
        exit 1
    fi
}

ssh_status() {
    ssh -i $ssh_key -o BatchMode=yes -o ConnectTimeout=3 dockeru@$host echo true 2>&1 # ssh test. "batchMode=yes" ignore prompt password 
}

if [[ ! -e $ssh_key ]]; then
    configure_ssh
elif [[ $(ssh_status) = true ]]; then
    echo "** SSH Already Configured" && true
else
    configure_ssh
fi
