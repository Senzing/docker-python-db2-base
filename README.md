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
1. [Demonstrate](#demonstrate)
    1. [Build docker image](#build-docker-image)
    1. [Create SENZING_DIR](#create-senzing_dir)
    1. [Configuration](#configuration)
    1. [Run docker container](#run-docker-container)
1. [Develop](#develop)
    1. [Prerequisite software](#prerequisite-software)
    1. [Clone repository](#clone-repository)
    1. [Downloads](#downloads)
    1. [Build docker image for development](#build-docker-image-for-development)

## Expectations

### Space

This repository and demonstration require 6 GB free disk space.

### Time

Budget 40 minutes to get the demonstration up-and-running, depending on CPU and network speeds.

### Background knowledge

This repository assumes a working knowledge of:

1. [Docker](https://github.com/Senzing/knowledge-base/blob/master/WHATIS/docker.md)

## Demonstrate

### Build docker image

See [Develop](#develop).

### Create SENZING_DIR

1. If you do not already have an `/opt/senzing` directory on your local system, visit
   [HOWTO - Create SENZING_DIR](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/create-senzing-dir.md).

### Configuration

- **SENZING_DATABASE_URL** -
  Database URI in the form: `${DATABASE_PROTOCOL}://${DATABASE_USERNAME}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_DATABASE}`
- **SENZING_DEBUG** -
  Enable debug information. Values: 0=no debug; 1=debug. Default: 0.
- **SENZING_DIR** -
  Location of Senzing libraries. Default: "/opt/senzing".

### Run docker container

#### Variation 1

1. Run the docker container with internal SQLite database and external volume.  Example:

    ```console
    export SENZING_DIR=/opt/senzing

    sudo docker run \
      --interactive \
      --rm \
      --tty \
      --volume ${SENZING_DIR}:/opt/senzing \
      senzing/python-db2-base
    ```

#### Variation 2

1. Run the docker container with external database and volumes.  Example:

    ```console
    export DATABASE_PROTOCOL=db2
    export DATABASE_USERNAME=db2inst1
    export DATABASE_PASSWORD=db2inst1
    export DATABASE_HOST=name-of-db2-container
    export DATABASE_PORT=50000
    export DATABASE_DATABASE=G2

    export SENZING_DATABASE_URL="${DATABASE_PROTOCOL}://${DATABASE_USERNAME}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_DATABASE}"
    export SENZING_DIR=/opt/senzing

    sudo docker run \
      --env SENZING_DATABASE_URL="${SENZING_DATABASE_URL}" \
      --interactive \
      --rm \
      --tty \
      --volume ${SENZING_DIR}:/opt/senzing \
      senzing/python-db2-base
    ```

#### Variation 3

1. Run the docker container accessing an external database in a docker network. Example:

   Determine docker network. Example:

    ```console
    sudo docker network ls

    # Choose value from NAME column of docker network ls
    export SENZING_NETWORK=nameofthe_network
    ```

    Run docker container. Example:

    ```console
    export DATABASE_PROTOCOL=db2
    export DATABASE_USERNAME=db2inst1
    export DATABASE_PASSWORD=db2inst1
    export DATABASE_HOST=name-of-db2-container
    export DATABASE_PORT=50000
    export DATABASE_DATABASE=G2

    export SENZING_DATABASE_URL="${DATABASE_PROTOCOL}://${DATABASE_USERNAME}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_DATABASE}"
    export SENZING_DIR=/opt/senzing

    sudo docker run \
      --env SENZING_DATABASE_URL="${SENZING_DATABASE_URL}" \
      --interactive \
      --net ${SENZING_NETWORK} \
      --rm \
      --tty \
      --volume ${SENZING_DIR}:/opt/senzing \
      senzing/python-db2-base
    ```

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

### Clone repository

1. Set these environment variable values:

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
    1. Click "Continue" button.
    1. Choose download method and click "Download now" button.
    1. Download `ibm_data_server_driver_for_odbc_cli_linuxx64_v11.1.tar.gz` to ${GIT_REPOSITORY_DIR}/[downloads](./downloads) directory.

#### Download v11.1.4fp4a_jdbc_sqlj.tar.gz

1. Visit [DB2 JDBC Driver Versions and Downloads](http://www-01.ibm.com/support/docview.wss?uid=swg21363866)
    1. In DB2 Version 11.1 > JDBC 3.0 Driver version, click on "3.72.52" link.
    1. Click on "DSClients--jdbc_sqlj-11.1.4.4-FP004a" link.
    1. Click on "v11.1.4fp4a_jdbc_sqlj.tar.gz" link to download.
    1. Download `v11.1.4fp4a_jdbc_sqlj.tar.gz` to ${GIT_REPOSITORY_DIR}/[downloads](./downloads) directory.

### Build docker image for development

1. Variation #1 - Using `make` command.

    ```console
    cd ${GIT_REPOSITORY_DIR}
    sudo make docker-build
    ```

    Note: `sudo make docker-build-base` can be used to create cached docker layers.

1. Variation #2 - Using `docker` command.

    ```console
    export DOCKER_IMAGE_NAME=senzing/python-db2-base

    cd ${GIT_REPOSITORY_DIR}
    sudo docker build --tag ${DOCKER_IMAGE_NAME} .
    ```
