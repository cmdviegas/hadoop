# ██████╗  ██████╗ █████╗
# ██╔══██╗██╔════╝██╔══██╗
# ██║  ██║██║     ███████║
# ██║  ██║██║     ██╔══██║
# ██████╔╝╚██████╗██║  ██║
# ╚═════╝  ╚═════╝╚═╝  ╚═╝
# DEPARTAMENTO DE ENGENHARIA DE COMPUTACAO E AUTOMACAO
# UNIVERSIDADE FEDERAL DO RIO GRANDE DO NORTE, NATAL/RN
#
# (C) 2022-2025 CARLOS M D VIEGAS
# https://github.com/cmdviegas

### Description:
# This Dockerfile creates an image of Apache Hadoop 3.4.1.

### How it works:
# This file uses debian linux as base system and then downloads hadoop. In installs all dependencies to run the cluster. The docker image will contain a fully distributed hadoop cluster with multiple worker nodes.

###
##### BUILD STAGE
FROM ubuntu:24.04 AS build-hadoop

# Use bash with pipefail to catch errors in pipelines
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Environment vars
ARG HADOOP_VERSION \
    MY_USERNAME \
    MY_PASSWORD \
    MY_WORKDIR="/home/${MY_USERNAME}"

ENV MY_USERNAME="${MY_USERNAME}" \
    HADOOP_VERSION="${HADOOP_VERSION}" \
    HADOOP_HOME="${MY_WORKDIR}/hadoop" \
    DEBIAN_FRONTEND=noninteractive

# Set container workdir
WORKDIR ${MY_WORKDIR}

# Copy hadoop file (if exist) to the container workdir
COPY hadoop-*.tar.gz .

RUN \
    # Check if hadoop exists inside workdir, if not, download it \
    if [ ! -f "${MY_WORKDIR}/hadoop-${HADOOP_VERSION}.tar.gz" ]; then \
        # Install aria2c to download hadoop \
        apt-get update -qq && \
        apt-get install -y --no-install-recommends \
            aria2 \
            ca-certificates \
        && \
        update-ca-certificates \
        && \
        # Clean apt cache \
        apt-get autoremove -yqq --purge && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* \
        && \
        # Download hadoop \
        aria2c --disable-ipv6 -x 16 --allow-overwrite=false \
        https://archive.apache.org/dist/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz; \
    fi \
    && \
    # Extract Hadoop to the container filesystem \
    tar -zxf hadoop-${HADOOP_VERSION}.tar.gz -C ${MY_WORKDIR} && \
    rm -rf hadoop-${HADOOP_VERSION}.tar.gz && \
    ln -sf ${MY_WORKDIR}/hadoop-3* ${HADOOP_HOME}

###
##### FINAL IMAGE
FROM ubuntu:24.04 AS final

# Use bash with pipefail to catch errors in pipelines
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Environment vars
ARG HADOOP_VERSION \
    MY_USERNAME \
    MY_PASSWORD

ENV MY_USERNAME="${MY_USERNAME}" \
    MY_PASSWORD="${MY_PASSWORD}" \
    MY_WORKDIR="/home/${MY_USERNAME}" \
    HADOOP_VERSION="${HADOOP_VERSION}" \
    HADOOP_HOME="${MY_WORKDIR}/hadoop" \
    DEBIAN_FRONTEND=noninteractive

RUN \
    # Update system and install required packages \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        openjdk-11-jdk-headless \
        python3.12-minimal \
        sudo \
        dos2unix \
        nano \
        ssh \
        wget \
        iproute2 \
        iputils-ping \
        net-tools \
        ca-certificates \
    && \
    update-ca-certificates \
    && \
    # Clean apt cache \
    apt-get autoremove -yqq --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    && \
    # Creates symbolic link to make 'python' and 'python3' recognized as a system command \
    ln -sf /usr/bin/python3.12 /usr/bin/python && \
    ln -sf /usr/bin/python /usr/bin/python3 \
    && \
    # Creates user and adds it to sudoers \
    adduser --disabled-password --gecos "" ${MY_USERNAME} && \
    echo "${MY_USERNAME}:${MY_PASSWORD}" | chpasswd && \
    usermod -aG sudo ${MY_USERNAME} && \
    echo "${MY_USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${MY_USERNAME}

# Set new user
USER ${MY_USERNAME}
WORKDIR ${MY_WORKDIR}

# Copy all files from build stage to the container
COPY --from=build-hadoop --chown=${MY_USERNAME}:${MY_USERNAME} ${MY_WORKDIR}/hadoop ${HADOOP_HOME}/

# Copy all files from local folder to container, except the ones in .dockerignore
COPY --chown=${MY_USERNAME}:${MY_USERNAME} config_files/ ${MY_WORKDIR}/config_files
COPY --chown=${MY_USERNAME}:${MY_USERNAME} bootstrap.sh config-services.sh start-services.sh .env ${MY_WORKDIR}/

RUN \
    # Convert charset from UTF-16 to UTF-8 to ensure compatibility \
    dos2unix -q -k ${MY_WORKDIR}/config_files/* *.sh .env \
    && \
    # Load environment variables into .bashrc file \
    cat "${MY_WORKDIR}/config_files/system/bash_profile" >> "${MY_WORKDIR}/.bashrc" && \
    sed -i "s/^export\? HDFS_NAMENODE_USER=.*/export HDFS_NAMENODE_USER=${MY_USERNAME}/" "${MY_WORKDIR}/.bashrc" \
    && \
    # Set JAVA_HOME dynamically based on installed Java version \
    JAVA_HOME_DIR=$(dirname "$(dirname "$(readlink -f "$(command -v java)")")") && \
    sed -i "s|^export JAVA_HOME=.*|export JAVA_HOME=\"$JAVA_HOME_DIR\"|" "${MY_WORKDIR}/.bashrc" \
    && \
    # Copy config files to Hadoop config folder \
    mv ${MY_WORKDIR}/config_files/hadoop/* ${HADOOP_HOME}/etc/hadoop/ && \
    chmod 0755 ${HADOOP_HOME}/etc/hadoop/*.sh \
    && \
    # Configure ssh for passwordless access \
    mkdir -p ./.ssh && \
    cat ${MY_WORKDIR}/config_files/system/ssh_config >> .ssh/config && \
    ssh-keygen -q -N "" -t rsa -f .ssh/id_rsa && \
    cat .ssh/id_rsa.pub >> .ssh/authorized_keys && \
    chmod 0600 .ssh/authorized_keys .ssh/config \
    && \
    # Cleaning and permission set \
    rm -rf ${MY_WORKDIR}/config_files/ && \
    sudo rm -rf /tmp/* /var/tmp/* && \
    chmod 0700 bootstrap.sh config-services.sh start-services.sh && \
    mkdir -p /tmp/hadoop/mapred/{done,intermediate-done}

# Run 'bootstrap.sh' on startup
ENTRYPOINT ["./bootstrap.sh"]
