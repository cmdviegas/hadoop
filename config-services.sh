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
# This script updates .xml config of hadoop and spark

###
#### Load env variables
[ -f "${HOME}/.env" ] && . "${HOME}/.env"
###

###
#### Hadoop properties
# Functions to update hadoop properties dynamically according vars in .env file.
function update_xml_values() { 
    sed -i "/<name>$1<\/name>/{n;s#<value>.*</value>#<value>$2</value>#;}" "$3"
}

# Update core-site.xml, yarn-site.xml, mapred-site.xml, hdfs-site.xml, hadoop-env.sh
#update_xml_values "fs.defaultFS" "hdfs://${MASTER_HOSTNAME}:9000" "${HADOOP_CONF_DIR}/core-site.xml"
update_xml_values "hadoop.http.staticuser.user" "${USER}" "${HADOOP_CONF_DIR}/core-site.xml"
#update_xml_values "yarn.resourcemanager.hostname" "${MASTER_HOSTNAME}" "${HADOOP_CONF_DIR}/yarn-site.xml"
update_xml_values "yarn.nodemanager.resource.memory-mb" "${YARN_NODEMANAGER_RESOURCE_MEMORY_MB}" "${HADOOP_CONF_DIR}/yarn-site.xml"
update_xml_values "yarn.scheduler.maximum-allocation-mb" "${YARN_SCHEDULER_MAXIMUM_ALLOCATION_MB}" "${HADOOP_CONF_DIR}/yarn-site.xml"
update_xml_values "yarn.scheduler.minimum-allocation-mb" "${YARN_SCHEDULER_MINIMUM_ALLOCATION_MB}" "${HADOOP_CONF_DIR}/yarn-site.xml"
update_xml_values "yarn.scheduler.capacity.maximum-am-resource-percent" "${YARN_SCHEDULER_CAPACITY_MAXIMUM_AM_RESOURCE_PERCENT}" "${HADOOP_CONF_DIR}/yarn-site.xml"
update_xml_values "yarn.app.mapreduce.am.resource.mb" "${YARN_APP_MAPREDUCE_AM_RESOURCE_MB}" "${HADOOP_CONF_DIR}/mapred-site.xml"
update_xml_values "mapreduce.map.memory.mb" "${MAPREDUCE_MAP_MEMORY_MB}" "${HADOOP_CONF_DIR}/mapred-site.xml"
update_xml_values "mapreduce.reduce.memory.mb" "${MAPREDUCE_REDUCE_MEMORY_MB}" "${HADOOP_CONF_DIR}/mapred-site.xml"
update_xml_values "dfs.namenode.name.dir" "\/home\/${MY_USERNAME}\/hdfs-data\/nameNode" "${HADOOP_CONF_DIR}/hdfs-site.xml"
update_xml_values "dfs.datanode.data.dir" "\/home\/${MY_USERNAME}\/hdfs-data\/dataNode" "${HADOOP_CONF_DIR}/hdfs-site.xml"
[ "$NUM_WORKER_NODES" -ge 2 ] && update_xml_values "dfs.replication" "2" "${HADOOP_CONF_DIR}/hdfs-site.xml"
sed -i "s|^export JAVA_HOME=.*|export JAVA_HOME=\"${JAVA_HOME}\"|" "${HADOOP_CONF_DIR}/hadoop-env.sh"
