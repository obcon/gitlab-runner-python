FROM ubuntu:17.04

MAINTAINER Marco Obermeyer "marco.obermeyer@obcon.de"

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/bin/dumb-init
RUN chmod +x /usr/bin/dumb-init

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y ca-certificates wget apt-transport-https vim nano curl tar zip unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "deb https://packages.gitlab.com/runner/gitlab-ci-multi-runner/ubuntu/ zesty main" > /etc/apt/sources.list.d/runner_gitlab-ci-multi-runner.list && \
    wget -q -O - https://packages.gitlab.com/gpg.key | apt-key add - && \
    apt-get update -y && \
    apt-get install -y gitlab-ci-multi-runner=1.11.5 && \
    apt-get clean && \
    mkdir -p /etc/gitlab-runner/certs && \
    chmod -R 700 /etc/gitlab-runner && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y python3.6 python3.6-venv python3.6-dev && \
    ln -s /usr/bin/python3.6 /usr/bin/python3 && \
    ln -s /usr/bin/python3.6 /usr/bin/python && \
    wget https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip install awscli ansible

RUN mkdir /opt/terraform && \
    cd /opt/terraform && \
    wget https://releases.hashicorp.com/terraform/0.10.8/terraform_0.10.8_linux_amd64.zip && \
    unzip terraform_0.10.8_linux_amd64.zip && \
    ln -s /opt/terraform/terraform /usr/local/bin/

ADD entrypoint /
RUN chmod +x /entrypoint

VOLUME ["/etc/gitlab-runner", "/home/gitlab-runner"]
ENTRYPOINT ["/usr/bin/dumb-init", "/entrypoint"]
CMD ["run", "--user=gitlab-runner", "--working-directory=/home/gitlab-runner"]
