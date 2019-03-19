# docker-python-db2-base

## Overview

The `senzing/python-db2-base` docker image is a Senzing-ready, python 2.7 image with a DB2 database.
The image can be used in a Dockerfile `FROM senzing/python-db2-base` statement to simplify
building apps with Senzing.

To see how to use the `senzing/python-db2-base` docker image, see
[github.com/senzing/docker-python-db2-demo](https://github.com/senzing/docker-python-db2-demo).
To see a demonstration of senzing, python, and db2, see
[github.com/senzing/docker-compose-db2-demo](https://github.com/senzing/docker-compose-db2-demo).

### Contents

1. [Expectations](#expectations)
    1. [Space](#space)
    1. [Time](#time)
    1. [Background knowledge](#background-knowledge)
1. [Build](#build)
    1. [Prerequisite software](#prerequisite-software)
    1. [Set environment variables for development](#set-environment-variables-for-development)
    1. [Clone repository](#clone-repository)
    1. [Download ibm_data_server_driver_for_odbc_cli_linuxx64_v11.1.tar.gz](#download-ibm_data_server_driver_for_odbc_cli_linuxx64_v111targz)
    1. [Build docker image](#build-docker-image)  
1. [Demonstrate](#demonstrate)
    1. [Create SENZING_DIR](#create-senzing_dir)
    1. [Set environment variables for demonstration](#set-environment-variables-for-demonstration)
    1. [Run docker container](#run-docker-container)

## Expectations

### Space

This repository and demonstration require 20 GB free disk space.

### Time

Budget 1 hour to get the demonstration up-and-running, depending on CPU and network speeds.

### Background knowledge

This repository assumes a working knowledge of:

1. [Docker](https://github.com/Senzing/knowledge-base/blob/master/WHATIS/docker.md)

## Develop

### Prerequisite software

The following software programs need to be installed.

#### git

1. [Install Git](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/install-git.md)
1. Test

    ```console
    git --version
    ```

#### make

1. [Install make](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/install-make.md)
1. Test

    ```console
    make --version
    ```

#### docker

1. [Install docker](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/install-docker.md)
1. Test

    ```console
    sudo docker --version
    sudo docker run hello-world
    ```

### Set environment variables for development

1. These variables may be modified, but do not need to be modified.
   The variables are used throughout the installation procedure.

    ```console
    export DOCKER_IMAGE_TAG=senzing/python-db2-base
    ```

### Clone repository

1. Using these environment variable values:

    ```console
    export GIT_ACCOUNT=senzing
    export GIT_REPOSITORY=docker-python-db2-base    
    ```

   Then follow steps in [clone-repository](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/clone-repository.md).

1. After the repository has been cloned, be sure the following are set:

    ```console
    export GIT_ACCOUNT_DIR=~/${GIT_ACCOUNT}.git
    export GIT_REPOSITORY_DIR="${GIT_ACCOUNT_DIR}/${GIT_REPOSITORY}"
    ```

### Downloads

#### Download ibm_data_server_driver_for_odbc_cli_linuxx64_v11.1.tar.gz

1. Visit [Download initial Version 11.1 clients and drivers](http://www-01.ibm.com/support/docview.wss?uid=swg21385217)
    1. Click on "[IBM Data Server Driver for ODBC and CLI (CLI Driver)](http://www.ibm.com/services/forms/preLogin.do?source=swg-idsoc97)" link.
    1. Select :radio_button:  "IBM Data Server Driver for ODBC and CLI (Linux AMD64 and Intel EM64T)"
    1. Choose download method and click "Download now" button.
    1. Download `ibm_data_server_driver_for_odbc_cli_linuxx64_v11.1.tar.gz` to ${GIT_REPOSITORY_DIR}/[downloads](./downloads) directory. 

#### Download v11.1.4fp4a_jdbc_sqlj.tar.gz

1. Visit [DB2 JDBC Driver Versions and Downloads](http://www-01.ibm.com/support/docview.wss?uid=swg21363866)
    1. In DB2 Version 11.1 > JDBC 3.0 Driver version, click on "3.72.52" link.
    1. Click on "DSClients--jdbc_sqlj-11.1.4.4-FP004a" link.
    1. Click on "v11.1.4fp4a_jdbc_sqlj.tar.gz" link to download.
    1. Download `v11.1.4fp4a_jdbc_sqlj.tar.gz` to ${GIT_REPOSITORY_DIR}/[downloads](./downloads) directory. 

### Build docker image

1. Option #1 - Using make command

    ```console
    cd ${GIT_REPOSITORY_DIR}
    make docker-build
    ```

1. Option #2 - Using docker command

    ```console
    cd ${GIT_REPOSITORY_DIR}
    docker build --tag ${DOCKER_IMAGE_TAG} .
    ```

## Demonstrate

### Create SENZING_DIR

1. If you do not already have an `/opt/senzing` directory on your local system, visit
   [HOWTO - Create SENZING_DIR](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/create-senzing-dir.md).

### Set environment variables for demonstration

1. Identify the Senzing directory.
   Example:

    ```console
    export SENZING_DIR=/opt/senzing
    ```

1. Identify the database username and password.
   Example:

    ```console
    export DB2_USERNAME=db2inst1
    export DB2_PASSWORD=db2inst1
    ```

1. Identify the database that is the target of the SQL statements.
   Example:

    ```console
    export DB2_DATABASE=G2
    ```

1. Identify the host and port running DB2 server.
   Example:

    ```console
    docker ps

    # Choose value from NAMES column of docker ps
    export DB2_HOST=docker-container-name
    ```

    ```console
    export DB2_PORT=50000
    ```

### Run docker container

1. **Option #1** - Run the docker container without database or volumes.

    ```console
    docker run -it \
      senzing/python-db2-base
    ```

1. **Option #2** - Run the docker container with database and volumes.

    ```console
    docker run -it  \
      --volume ${SENZING_DIR}:/opt/senzing \
      --env SENZING_DATABASE_URL="db2://${DB2_USERNAME}:${DB2_PASSWORD}@${DB2_HOST}:${DB2_PORT}/${DB2_DATABASE}" \
      senzing/python-db2-base
    ```

1. **Option #3** - Run the docker container accessing a database in a docker network.

    Identify the Docker network of the DB2 database.
    Example:

    ```console
    docker network ls

    # Choose value from NAME column of docker network ls
    export DB2_NETWORK=nameofthe_network
    ```

    Run docker container.

    ```console
    docker run -it  \
      --volume ${SENZING_DIR}:/opt/senzing \
      --net ${DB2_NETWORK} \
      --env SENZING_DATABASE_URL="db2://${DB2_USERNAME}:${DB2_PASSWORD}@${DB2_HOST}:{DB2_PORT}/${DB2_DATABASE}" \
      senzing/python-db2-base
    ```
