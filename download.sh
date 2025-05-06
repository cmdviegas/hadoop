#!/bin/sh
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
# This is a bash script to automatically download Hadoop (if needed)
# 

if [ -f "${PWD}/.env" ]; then
  HADOOP_VERSION=$(grep '^HADOOP_VERSION=' "${PWD}/.env" | cut -d '=' -f2)
else
  echo "Error: .env file not found."
  exit 1
fi

if [ -z "$HADOOP_VERSION" ]; then
  echo "Error: HADOOP_VERSION must be defined in .env file."
  exit 1
fi

echo "Downloading Apache Hadoop $HADOOP_VERSION ..."

wget -nc --inet4-only --no-check-certificate "https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz"
