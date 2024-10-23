## Deploying a cluster with Apache Hadoop 3.4.0

This is a script that deploys a cluster with Apache Hadoop in fully distributed mode using Docker as infrastructure.

### :rocket: How to build and run

⚠️ Before you begin: you MUST pre-download Apache Hadoop and Apache Spark by running `download.sh` script before invoking docker compose build.

By default, it creates three containers: one node-master and two worker nodes. The number of worker nodes can be changed by setting `$NODE_REPLICAS` to the desired value in `.env` file. 

⚠️ You should edit `.env` file in order to set several parameters for the cluster, like username and password, memory resources, and other definitions. Basically you just need to edit this file.

#### To build and run this option:
```
docker compose build && docker compose up 
```

### :bulb: Tips

#### To access node-master
```
ssh -p 2222 hadoop@localhost
```
or
```
docker exec -it node-master /bin/bash
```

### :page_facing_up: License

Copyright (c) 2022-2025 [CARLOS M. D. VIEGAS](https://github.com/cmdviegas).

This script is free and open-source software licensed under the [MIT License](https://github.com/cmdviegas/docker-hadoop-cluster/blob/master/LICENSE). 

`Apache Hadoop` is free and open-source software licensed under the [Apache License](https://github.com/cmdviegas/docker-hadoop-cluster/blob/master/LICENSE.apache).
