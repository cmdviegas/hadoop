#!/bin/bash
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
#

### Description:
# This is a bash script to initialize services

### How it works:
# On first startup:
# - Load .bashrc 
# - Start SSH server
# - Format namenode HDFS (master only)
# - Creates HDFS folders and copy files to them (master only)
# - Edit HADOOP properties in .xml/.conf files according to values defined in .env
# - Start HDFS, YARN 

# In the next startups:
# - Load .bashrc
# - Start SSH server
# - Edit HADDOP properties in .xml/.conf files according to values defined in .env
# - Start HDFS, YARN

###
#### Load env variables
[ -f "${HOME}/.env" ] && . "${HOME}/.env"
###

###
#### Set JAVA_HOME dynamically based on installed Java version
#JAVA_HOME_DIR=$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")
#sed -i "s|^export JAVA_HOME=.*|export JAVA_HOME=\"$JAVA_HOME_DIR\"|" ${HOME}/.bashrc

###
#### Load .bashrc
eval "$(tail -n +10 ${HOME}/.bashrc)" # Alternative to 'source .bashrc'
###

###
#### Run script to update hadoop config files
[ -f "${HOME}/config-services.sh" ] && bash -c "${HOME}/config-services.sh"
###

###
#### Start ssh server
sudo service ssh start > /dev/null 2>&1
###

###
#### ~/hadoop/etc/hadoop/workers
# Update hadoop workers file according to the amount of worker nodes
truncate -s 0 ${HADOOP_CONF_DIR}/workers
for i in $(seq 1 "${NUM_WORKER_NODES}"); do
    echo "${STACK_NAME}-worker-$i" >> "${HADOOP_CONF_DIR}/workers"
done
###

###
#### Start services
# Start hadoop services (only at master)
if [ "$1" == "MASTER" ] ; then
    sleep 5
    [ -f "${HOME}/start-services.sh" ] && bash -c "${HOME}/start-services.sh"
else
    printf "I'm up and ready!\n"
fi

unset MY_USERNAME
unset MY_PASSWORD

/bin/bash
