#Credits to Sven Dowideit. Source https://docs.docker.com/examples/running_ssh_service/

#Source this image
FROM ubuntu:14.04 

MAINTAINER Raphael P Ribeiro <raphaelpr01@gmail.com>
RUN sudo apt-get install -y software-properties-common

#install julia and ssh, if you need more packages for you application, you can add it with \ package_name
RUN apt-get update && apt-get install -y \
openssh-server \
curl           \
wget           \
unzip          \
cmake 		   \
git


RUN mkdir -p /opt/julia_0.4.5 && \
	curl -s -L https://julialang.s3.amazonaws.com/bin/linux/x64/0.4/julia-0.4.5-linux-x86_64.tar.gz | tar -C /opt/julia_0.4.5 -x -z --strip-components=1 -f -

RUN ln -fs /opt/julia_0.4.5 /opt/julia

RUN echo "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/opt/julia/bin\"" > /etc/environment && \
    echo "export PATH" >> /etc/environment && \
    echo "source /etc/environment" >> /root/.bashrc

RUN /opt/julia/bin/julia -e "Pkg.add(\"Logging\")"
RUN /opt/julia/bin/julia -e "Pkg.add(\"MLBase\")"
RUN /opt/julia/bin/julia -e "Pkg.add(\"StatsBase\")"
RUN /opt/julia/bin/julia -e "Pkg.add(\"MultivariateStats\")"
RUN /opt/julia/bin/julia -e "Pkg.add(\"Distributions\")"
RUN /opt/julia/bin/julia -e "Pkg.add(\"Clustering\")"
RUN /opt/julia/bin/julia -e "Pkg.add(\"DataFrames\")"
RUN /opt/julia/bin/julia -e "Pkg.add(\"Distances\")"
RUN /opt/julia/bin/julia -e "Pkg.clone(\"https://github.com/anj1/NeuralNets.jl.git\")"


#Account configuration
RUN mkdir /var/run/sshd
########################################################################################################################
##Change your root password here, just remove the "123" value on 'root:123' and put your own custom password for the image
#
#
#
#
RUN echo 'root:cloudarray@' | chpasswd
#
#
#
#Change your root password here, just remove the "123" value on 'root:123' and put your own custom password for the image
########################################################################################################################

# SSH configuration
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed -i 's/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/' /etc/ssh/ssh_config
# This will send a keepalive signal to the server if no packets have been received in the preceding 60 seconds (as specified above).
RUN echo "ClientAliveInterval 120" | sudo tee -a /etc/ssh/sshd_config

# it only runs mesg -n if tty reports that stdin is a terminal
RUN sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile


#ssh keygen generation
RUN echo | ssh-keygen -t rsa
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

#Open port 22 for the ssh service
EXPOSE 22

#start sshd
CMD ["/usr/sbin/sshd", "-D"]
