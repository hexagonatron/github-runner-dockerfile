FROM ubuntu:24.04

ARG RUNNER_VERSION="2.326.0"

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common \
    && curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get -y install docker-ce

RUN apt update -y && apt upgrade -y && useradd -m ghrunner
RUN apt install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip dos2unix

RUN cd /home/ghrunner && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN chown -R ghrunner ~ghrunner && /home/ghrunner/actions-runner/bin/installdependencies.sh

# Copy and ensure the script has correct line endings
COPY start.sh /home/ghrunner/start.sh
RUN chmod +x /home/ghrunner/start.sh && dos2unix /home/ghrunner/start.sh

# Set working directory
WORKDIR /home/ghrunner

# Set the user to "ghrunner" so all commands are run as the ghrunner user
USER ghrunner

# Set entrypoint
ENTRYPOINT ["/home/ghrunner/start.sh"]
