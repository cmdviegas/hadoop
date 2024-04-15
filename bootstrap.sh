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
# (C) 2024 CARLOS M D VIEGAS
# https://github.com/cmdviegas
#

### Description:
# This is a bash script to initialize services

### How it works:
# On first startup:
# - Load .bashrc
# - Start SSH server
# - Format namenode HDFS (node-master only)
# - Creates HDFS folders and copy files to them (node-master only)
# - Edit HADOOP properties in .xml/.conf files according to values defined in .env
# - Start HDFS and YARN

# In the next startups:
# - Load .bashrc
# - Start SSH server
# - Edit HADDOP properties in .xml/.conf files according to values defined in .env
# - Start HDFS and YARN

# Some coloring
RED_COLOR=$(tput setaf 1)
GREEN_COLOR=$(tput setaf 2) 
YELLOW_COLOR=$(tput setaf 3)
LIGHTBLUE_COLOR=$(tput setaf 6)
RESET_COLORS=$(tput sgr0)
INFO="[${GREEN_COLOR}INFO${RESET_COLORS}]${LIGHTBLUE_COLOR}"
WARN="[${RED_COLOR}ERROR${RESET_COLORS}]${YELLOW_COLOR}"

###
#### Load env variables
if [[ -f "${HOME}/.env" ]]; then 
    source "${HOME}/.env"
fi
###

###
#### .bashrc
# Replace username in the .bashrc (HDFS_NAMENODE_USER)
sed -i "s/^export\? HDFS_NAMENODE_USER=.*/export HDFS_NAMENODE_USER=${USERNAME}/" "${HOME}/.bashrc"

# Load .bashrc
eval "$(tail -n +10 ${HOME}/.bashrc)" # Workaround for ubuntu .bashrc (i.e. source .bashrc)
###

###
#### Init ssh server
sudo service ssh start
###

###
#### /etc/hosts and ~/hadoop/etc/hadoop/workers
# Creates /etc/hosts dynamically according to number of replicas and update hadoop workers file accordingly.
truncate -s 0 ${HADOOP_CONF_DIR}/workers
{
    echo "127.0.0.1 localhost"
    echo "${IP_NODEMASTER} node-master"
    for i in $(seq 1 "${NODE_REPLICAS}"); do
        echo "${IP_RANGE%0/*}$((i+2)) node-$i"
        echo "node-$i" >> "${HADOOP_CONF_DIR}/workers"
    done
} > "${HOME}/.hosts"
# Copy hosts file to /etc/hosts
sudo bash -c "cat ${HOME}/.hosts > /etc/hosts"
{
    echo "node-master"
    cat "${HADOOP_CONF_DIR}/workers"
} > "${HOME}/.hostlist"
###

###
#### Hadoop properties
# Functions to update hadoop and spark properties dynamically according vars in .env file.
function update_xml_values() {
    sed -i "/<name>$1<\/name>/{n;s/<value>.*<\/value>/<value>$2<\/value>/;}" "$3"
}

# Update core-site.xml, yarn-site.xml, mapred-site.xml, hdfs-site.xml
update_xml_values "hadoop.http.staticuser.user" "${SYS_USERNAME}" "${HADOOP_CONF_DIR}/core-site.xml"
update_xml_values "yarn.nodemanager.resource.memory-mb" "${MEM_RM}" "${HADOOP_CONF_DIR}/yarn-site.xml"
update_xml_values "yarn.scheduler.maximum-allocation-mb" "${MEM_MAX}" "${HADOOP_CONF_DIR}/yarn-site.xml"
update_xml_values "yarn.scheduler.minimum-allocation-mb" "${MEM_MIN}" "${HADOOP_CONF_DIR}/yarn-site.xml"
update_xml_values "yarn.scheduler.capacity.maximum-am-resource-percent" "${MAX_SCHED}" "${HADOOP_CONF_DIR}/yarn-site.xml"
update_xml_values "yarn.app.mapreduce.am.resource.mb" "${MEM_AM}" "${HADOOP_CONF_DIR}/mapred-site.xml"
update_xml_values "mapreduce.map.memory.mb" "${MEM_MAP}" "${HADOOP_CONF_DIR}/mapred-site.xml"
update_xml_values "mapreduce.reduce.memory.mb" "${MEM_RED}" "${HADOOP_CONF_DIR}/mapred-site.xml"
update_xml_values "dfs.namenode.name.dir" "\/home\/${SYS_USERNAME}\/hdfs-data\/nameNode" "${HADOOP_CONF_DIR}/hdfs-site.xml"
update_xml_values "dfs.datanode.data.dir" "\/home\/${SYS_USERNAME}\/hdfs-data\/dataNode" "${HADOOP_CONF_DIR}/hdfs-site.xml"
if [ "$NODE_REPLICAS" -eq 1 ]; then
    update_xml_values "dfs.replication" "1" "${HADOOP_CONF_DIR}/hdfs-site.xml"
elif [ "$NODE_REPLICAS" -ge 2 ]; then
    update_xml_values "dfs.replication" "2" "${HADOOP_CONF_DIR}/hdfs-site.xml"
fi

###
#### Init services

# Initialize hadoop services (only at node-master)
if [ "${HOSTNAME}" == "node-master" ] ; then

    # Format HDFS
    printf "${INFO} Formatting filesystem${RESET_COLORS}...\n"
    hdfs namenode -format -nonInteractive

    # Start HDFS and YARN services
    # Test if all workers are alive and ready to create the cluster
    ATTEMPTS=0
    while true
    do
        printf "${INFO} Waiting for WORKERS to be ready${RESET_COLORS}...\n"
        WORKERS_REACHABLE=true
        # Read the file containing the IP addresses
        while IFS= read -r ip; do
            if ! ssh -o "ConnectTimeout=1" "$ip" exit >/dev/null 2>&1; then
                # If any worker node is not reachable, set WORKERS_REACHABLE to false and break the loop
                WORKERS_REACHABLE=false
                break
            fi
        done < ${HOME}/.hostlist
        if ${WORKERS_REACHABLE}; then
            # If all worker nodes are reachable, start hdfs and yarn and exit the loop
            printf "${INFO} Starting HDFS and YARN services${RESET_COLORS}...\n"
            sleep 1
            start-dfs.sh
            sleep 1
            start-yarn.sh
            break
        fi
        # Wait before checking again
        sleep 5

        ATTEMPTS=$((ATTEMPTS+1))
        if [ ${ATTEMPTS} -ge 10 ]; then
            printf "${WARN} There are no reachable WORKERS. Exiting.${RESET_COLORS}\n"
            exit 1
        fi
    done

    sleep 1

    # Creating /user folders inside HDFS
    FILE=.first_boot
    if [ ! -e "${FILE}" ] ; then
        # Check if there are live datanodes in the cluster
        if hdfs dfsadmin -report | grep -q "Live datanodes"; then
            printf "${INFO} Creating folders in HDFS${RESET_COLORS}...\n"
            hdfs dfs -mkdir -p /user/${HDFS_NAMENODE_USER}
        else
            printf "${WARN} There are no live nodes in the cluster. Exiting.${RESET_COLORS}\n"
            exit 1
        fi
        # Creating .first_boot file as a flag to indicate that first boot has already done
        touch ${FILE}
    fi

    # Checking HDFS status (optional)
    printf "${INFO} Checking HDFS nodes report${RESET_COLORS}...\n"
    hdfs dfsadmin -report

    # Checking YARN status (optional)
    printf "${INFO} Checking YARN nodes list${RESET_COLORS}...\n"
    yarn node -list

    printf "\n${INFO} ${GREEN_COLOR}$(tput blink)ALL SET!${RESET_COLORS}\n\n"
    printf "TIP: To access node-master, type: ${YELLOW_COLOR}docker exec -it node-master /bin/bash${RESET_COLORS}\n"
fi
# Starting bash terminal
/bin/bash

unset USERNAME
unset PASSWORD
