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
# This is a bash script to automatically download hadoop 
#

read -p "Download Apache Hadoop 3.4.0? (y/N): " hadoop

if [[ "$hadoop" =~ ^([Yy]|[Yy][Ee][Ss])$ ]]; then
  wget -nc --no-check-certificate https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz
fi
