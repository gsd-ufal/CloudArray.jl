#!/bin/bash

###=============================================================================
#
#          FILE: install.sh
# 
#         USAGE: chmod +x install.sh && ./install.sh
# 
#   DESCRIPTION: install CloudArrayDaemon service
# 
#       OPTIONS: ---
#  DEPENDENCIES: 
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raphael P. Ribeiro
#  ORGANIZATION: GSD-UFAL
#       CREATED: 2016-03-30 11:00
###=============================================================================

# Make sure only root can run the script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

function julia_install()
{
	mkdir -p /opt/julia_0.4.5 && \
	curl -s -L https://julialang.s3.amazonaws.com/bin/linux/x64/0.4/julia-0.4.5-linux-x86_64.tar.gz | tar -C /opt/julia_0.4.5 -x -z --strip-components=1 -f -
	ln -fs /opt/julia_0.4.5 /opt/julia

	echo "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/opt/julia/bin\"" > /etc/environment && \
	echo "export PATH" >> /etc/environment && \
	echo "source /etc/environment" >> /root/.bashrc
}

function daemon_install()
{
    apt-get install -y cmake

    /opt/julia/bin/julia -e "Pkg.add(\"Requests\")"
    /opt/julia/bin/julia -e "Pkg.build(\"MbedTLS\")"
    /opt/julia/bin/julia -e "Pkg.add(\"HttpServer\")"
    cp daemon/cloudarraydaemon /usr/bin/cloudarraydaemon && chmod +x /usr/bin/cloudarraydaemon
    cp daemon/cloudarraydaemon.init /usr/bin/cloudarraydaemon.init && chmod +x /usr/bin/cloudarraydaemon.init
    cp daemon/cloudarraydaemon.service /etc/systemd/system/cloudarraydaemon.service
    systemctl daemon-reload && systemctl enable cloudarraydaemon && systemctl start cloudarraydaemon
}

if ! which julia >/dev/null; then
    julia_install
fi

daemon_install

if ! which docker >/dev/null; then
    curl -fsSL https://get.docker.com/ | sh
    service docker stop
    sed -i "/DOCKER_OPTS=/c\DOCKER_OPTS='-H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock'" /etc/init.d/docker
    service docker start
fi
