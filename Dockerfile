FROM ubuntu:17.10

MAINTAINER Marco Obermeyer "marco.obermeyer@obcon.de"

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

#
# INIT 0
#

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 /usr/bin/dumb-init
RUN chmod +x /usr/bin/dumb-init

#
# SW-UPDATE BASE-TOOLS
#

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y ca-certificates wget apt-transport-https software-properties-common vim rsync nano curl tar zip unzip make build-essential language-pack-en-base && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#
# GITLAB-RUNNER
#

RUN echo "deb https://packages.gitlab.com/runner/gitlab-runner/ubuntu/ zesty main" > /etc/apt/sources.list.d/runner_gitlab-runner.list && \
    wget -q -O - https://packages.gitlab.com/gpg.key | apt-key add - && \
    apt-get update -y && \
    apt-get install -y gitlab-runner && \
    apt-get clean && \
    mkdir -p /etc/gitlab-runner/certs && \
    chmod -R 700 /etc/gitlab-runner && \
    rm -rf /var/lib/apt/lists/*

#
# DOCKER
#

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN apt-key fingerprint 0EBFCD88
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu zesty stable"
RUN apt-get update && \
    apt-get install -y docker-ce
RUN usermod -aG docker gitlab-runner

#
# PYTHON 3.6
#

RUN apt-get update && \
    apt-get install -y python3.6 python3.6-venv python3.6-dev libpq-dev && \
    wget https://bootstrap.pypa.io/get-pip.py && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    python get-pip.py && \
    rm get-pip.py && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


#
# PYTHON PIPs
#

RUN pip install awscli ansible pipenv docker-compose

#
# TERRAFORM
#



RUN mkdir /opt/terraform && \
    cd /opt/terraform && \
    wget https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip && \
    unzip terraform_0.11.8_linux_amd64.zip && \
    ln -s /opt/terraform/terraform /usr/local/bin/ && \
    rm terraform_0.11.8_linux_amd64.zip

#
# PACKER
#

RUN mkdir /opt/packer && \
    cd /opt/packer && \
    wget https://releases.hashicorp.com/packer/1.3.1/packer_1.3.1_linux_amd64.zip && \
    unzip packer_1.3.1_linux_amd64.zip && \
    ln -s /opt/packer/packer /usr/local/bin/ && \
    rm packer_1.3.1_linux_amd64.zip

#
# ENTRYPOINT
#

ADD entrypoint /
RUN chmod +x /entrypoint

VOLUME ["/etc/gitlab-runner", "/home/gitlab-runner"]
ENTRYPOINT ["/usr/bin/dumb-init", "/entrypoint"]
CMD ["run", "--user=gitlab-runner", "--working-directory=/home/gitlab-runner"]
