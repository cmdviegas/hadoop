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
#### Hadoop and Spark properties
# Functions to update hadoop and spark properties dynamically according vars in .env file.
function update_xml_values() { 
    sed -i "/<name>$1<\/name>/{n;s/<value>.*<\/value>/<value>$2<\/value>/;}" "$3"
 }

# Update core-site.xml, yarn-site.xml, mapred-site.xml, hdfs-site.xml
update_xml_values "hadoop.http.staticuser.user" "${USERNAME}" "${HADOOP_CONF_DIR}/core-site.xml"
update_xml_values "yarn.nodemanager.resource.memory-mb" "${MEM_RM}" "${HADOOP_CONF_DIR}/yarn-site.xml"
update_xml_values "yarn.scheduler.maximum-allocation-mb" "${MEM_MAX}" "${HADOOP_CONF_DIR}/yarn-site.xml"
update_xml_values "yarn.scheduler.minimum-allocation-mb" "${MEM_MIN}" "${HADOOP_CONF_DIR}/yarn-site.xml"
update_xml_values "yarn.scheduler.capacity.maximum-am-resource-percent" "${MAX_SCHED}" "${HADOOP_CONF_DIR}/yarn-site.xml"
update_xml_values "yarn.app.mapreduce.am.resource.mb" "${MEM_AM}" "${HADOOP_CONF_DIR}/mapred-site.xml"
update_xml_values "mapreduce.map.memory.mb" "${MEM_MAP}" "${HADOOP_CONF_DIR}/mapred-site.xml"
update_xml_values "mapreduce.reduce.memory.mb" "${MEM_RED}" "${HADOOP_CONF_DIR}/mapred-site.xml"
update_xml_values "dfs.namenode.name.dir" "\/home\/${USERNAME}\/hdfs-data\/nameNode" "${HADOOP_CONF_DIR}/hdfs-site.xml"
update_xml_values "dfs.datanode.data.dir" "\/home\/${USERNAME}\/hdfs-data\/dataNode" "${HADOOP_CONF_DIR}/hdfs-site.xml"
[ "$NODE_REPLICAS" -ge 2 ] && update_xml_values "dfs.replication" "2" "${HADOOP_CONF_DIR}/hdfs-site.xml"

