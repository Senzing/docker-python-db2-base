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

## Build

### Prerequisite software

The following software programs need to be installed.

#### git

```console
git --version
```

#### make

Optional.

```console
make --version
```

#### docker

```console
docker --version
docker run hello-world
```

### Set environment variables for development

1. These variables may be modified, but do not need to be modified.
   The variables are used throughout the installation procedure.

    ```console
    export GIT_ACCOUNT=senzing
    export GIT_REPOSITORY=docker-python-db2-base
    export DOCKER_IMAGE_TAG=senzing/python-db2-base
    ```

1. Synthesize environment variables.

    ```console
    export GIT_ACCOUNT_DIR=~/${GIT_ACCOUNT}.git
    export GIT_REPOSITORY_DIR="${GIT_ACCOUNT_DIR}/${GIT_REPOSITORY}"
    export GIT_REPOSITORY_URL="git@github.com:${GIT_ACCOUNT}/${GIT_REPOSITORY}.git"
    ```

### Clone repository

1. Get repository.

    ```console
    mkdir --parents ${GIT_ACCOUNT_DIR}
    cd  ${GIT_ACCOUNT_DIR}
    git clone ${GIT_REPOSITORY_URL}
    ```

### Download ibm_data_server_driver_for_odbc_cli_linuxx64_v11.1.tar.gz

1. Visit [Download initial Version 11.1 clients and drivers](http://www-01.ibm.com/support/docview.wss?uid=swg21385217)
    1. Click on "[IBM Data Server Driver for ODBC and CLI (CLI Driver)](http://www.ibm.com/services/forms/preLogin.do?source=swg-idsoc97)" link.
    1. Select :radio_button:  "IBM Data Server Driver for ODBC and CLI (Linux AMD64 and Intel EM64T)"
    1. Choose download method and click "Download now" button.
1. Download `ibm_data_server_driver_for_odbc_cli_linuxx64_v11.1.tar.gz` to ${GIT_REPOSITORY_DIR}/[downloads](./downloads) directory.  

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

If you do not already have an `/opt/senzing` directory on your local system, here's how to install the code.

1. Set environment variable

    ```console
    export SENZING_DIR=/opt/senzing
    ```

1. Download [Senzing_API.tgz](https://s3.amazonaws.com/public-read-access/SenzingComDownloads/Senzing_API.tgz)

    ```console
    curl -X GET \
      --output /tmp/Senzing_API.tgz \
      https://s3.amazonaws.com/public-read-access/SenzingComDownloads/Senzing_API.tgz
    ```

1. Extract [Senzing_API.tgz](https://s3.amazonaws.com/public-read-access/SenzingComDownloads/Senzing_API.tgz)
   to `${SENZING_DIR}`.

    1. Linux

        ```console
        sudo mkdir -p ${SENZING_DIR}

        sudo tar \
          --extract \
          --owner=root \
          --group=root \
          --no-same-owner \
          --no-same-permissions \
          --directory=${SENZING_DIR} \
          --file=/tmp/Senzing_API.tgz
        ```

    1. macOS
        ```console
        sudo mkdir -p ${SENZING_DIR}

        sudo tar \
          --extract \
          --no-same-owner \
          --no-same-permissions \
          --directory=${SENZING_DIR} \
          --file=/tmp/Senzing_API.tgz
        ```

### Set environment variables for demonstration

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
