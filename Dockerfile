FROM ubuntu:20.04

ARG RUNNER_VERSION="2.326.0"

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y && useradd -m docker
RUN apt install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip dos2unix

RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# Copy and ensure the script has correct line endings
COPY start.sh /home/docker/start.sh
RUN chmod +x /home/docker/start.sh && dos2unix /home/docker/start.sh

# Set working directory
WORKDIR /home/docker

# Set the user to "docker" so all commands are run as the docker user
USER docker

# Set entrypoint
ENTRYPOINT ["/home/docker/start.sh"]
