## Deploying a cluster with Apache Hadoop 3.4.1

This script deploys an Apache Hadoop cluster in fully distributed mode using Docker as the underlying infrastructure.

### :rocket: How to build and run

⚠️ Optional (Recommended): Before starting, it is advised to pre-download Apache Hadoop by running the `download.sh` script. This step will speed up the build process.

By default, the script creates three containers: one master node and two worker nodes. You can adjust the number of worker nodes by setting `$REPLICAS` to the desired value in the `.env` file.

⚠️ Note: Edit the `.env` file to configure cluster parameters such as username, password, memory resources, and other settings. This file is the primary configuration source for your cluster setup.

#### To build and run this option:
```
docker compose build && docker compose up 
```

### :bulb: Tips

#### Accessing the Master Node

Use one of the following commands to access the master node:

```
ssh -p 2222 hadoop@localhost
```
or
```
docker exec -it hadoop-master /bin/bash
```

### :page_facing_up: License

Copyright (c) 2022-2025 [CARLOS M. D. VIEGAS](https://github.com/cmdviegas).

This script is licensed under the [MIT License](https://github.com/cmdviegas/docker-hadoop-cluster/blob/master/LICENSE) and is free, open-source software.

`Apache Hadoop` is licensed under the [Apache License](https://github.com/cmdviegas/docker-hadoop-cluster/blob/master/LICENSE.apache) and is also free, open-source software.
