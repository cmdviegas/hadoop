## Hadoop Cluster Deployment

This script deploys a cluster with `Apache Hadoop 3.4.x` in fully distributed mode using `Docker` containers as the underlying infrastructure. This setup is primarily intended for teaching and experimentation, but it may also be suitable for scalable data processing workloads in controlled environments.

### 🗂️ Architecture

The cluster consists of **one master node** and a configurable number of **worker nodes**, deployed over a custom `Docker` network.

- **Master Node**: `hadoop-master` — responsible for coordinating the cluster, managing resources (via YARN), and serving as the Hadoop Master and HDFS NameNode.
- **Worker Nodes**: `hadoop-worker-<id>` — replicated containers acting as Workers, HDFS DataNodes, and YARN NodeManagers, where `<id>` denotes the worker instance ID.

### ⚙️ Resource Management and Services

The cluster uses **YARN** for resource scheduling and **HDFS** for distributed file storage. Here are the key services on each node:

#### Master Node (`hadoop-master`)

- **ResourceManager** (YARN)
- **NameNode** (HDFS)
- **Exposed Ports**:
  - `9870` – HDFS Web UI
  - `8088` – YARN ResourceManager UI

#### Worker Nodes (`hadoop-worker-<id>`)

- **DataNode** (HDFS)
- **NodeManager** (YARN)


### :rocket: How to build and run

⚠️ Note: All cluster parameters — such as the default user credentials, resource allocation (e.g., memory and CPU limits), number of worker nodes, and other deployment-specific settings — are configurable via the `.env` file. This file is the primary configuration source for the cluster setup.

⚠️ Optional (Recommended): Before starting, it is advised to pre-download Apache Hadoop and Apache Spark by running the `download.sh` script. This step will speed up the build process.

#### To build and run this option:
```
docker compose build && docker compose up 
```

⚠️ Note: It is advised to use `Docker Compose 1.18.0` or higher to ensure compatibility.

### :bulb: Tips

#### Accessing the Master Node

To access the master node, run the following command:
```
docker exec -it hadoop-master bash
```

### :memo: Changelog

#### 08/05/2025
- :wrench: Added `MapReduce Job History`;
- :wrench: Minor fixes and optimizations.
- :clipboard: Build Summary: hadoop:3.4.1 | jdk:11 | python:3.12 | ubuntu:24.04

#### 06/05/2025
- :package: Updated `Ubuntu` version to 24.04 LTS;
- :package: Updated `Python` version to 3.12;
- :wrench: Minor fixes and optimizations.
- :clipboard: Build Summary: hadoop:3.4.1 | jdk:11 | python:3.12 | ubuntu:24.04

#### 02/05/2025
- :package: Updated `Apache Hadoop` version to 3.4.1;
- :wrench: Minor fixes and optimizations.
- :clipboard: Build Summary: hadoop:3.4.1 | jdk:11 | python:3.11 | ubuntu:22.04


### :page_facing_up: License

Copyright (c) 2022-2025 [CARLOS M. D. VIEGAS](https://github.com/cmdviegas).

This script is licensed under the [MIT License](https://github.com/cmdviegas/docker-hadoop-cluster/blob/master/LICENSE) and is free, open-source software.

`Apache Hadoop` and `Apache Spark` are licensed under the [Apache License](https://github.com/cmdviegas/docker-hadoop-cluster/blob/master/LICENSE.apache) and are also free, open-source software.
