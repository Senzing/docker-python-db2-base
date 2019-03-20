# -----------------------------------------------------------------------------
# Stage: builder
# -----------------------------------------------------------------------------

ARG BASE_IMAGE=debian:9
FROM ${BASE_IMAGE} as builder

ENV REFRESHED_AT=2019-03-19

LABEL Name="senzing/python-db2-base-builder" \
      Version="1.0.0"

RUN apt-get update \
 && apt-get -y install \
      unzip

# Copy the DB2 ODBC client code.
# The tar.gz files must be independently downloaded before the docker build.

ADD ./downloads/ibm_data_server_driver_for_odbc_cli_linuxx64_v11.1.tar.gz /opt/IBM/db2
ADD ./downloads/v11.1.4fp4a_jdbc_sqlj.tar.gz /tmp/db2-jdbc-sqlj

# Extract ZIP file.

RUN unzip -d /tmp/extracted-jdbc /tmp/db2-jdbc-sqlj/jdbc_sqlj/db2_db2driver_for_jdbc_sqlj.zip

# -----------------------------------------------------------------------------
# Final stage
# -----------------------------------------------------------------------------

ARG BASE_IMAGE=debian:9
FROM ${BASE_IMAGE}

ENV REFRESHED_AT=2019-03-19

LABEL Name="senzing/python-db2-base" \
      Version="1.0.0"

# Install packages via apt.

RUN apt-get update \
 && apt-get -y install \
      curl \
      gnupg \
      jq \
      lsb-core \
      lsb-release \
      python-dev \
      python-pip \
      python-pyodbc \
      sqlite \
      unixodbc \
      unixodbc-dev \
      wget \
 && rm -rf /var/lib/apt/lists/*

# Install packages via pip.

RUN pip install \
    psutil \
    pyodbc

# Copy files from "builder" stage.

COPY --from=builder [ \
    "/opt/IBM/db2/clidriver/adm/db2trc", \
    "/opt/IBM/db2/clidriver/adm/" \
    ]

COPY --from=builder [ \
    "/opt/IBM/db2/clidriver/bin/db2dsdcfgfill", \
    "/opt/IBM/db2/clidriver/bin/db2ldcfg", \
    "/opt/IBM/db2/clidriver/bin/db2lddrg", \
    "/opt/IBM/db2/clidriver/bin/db2level", \
    "/opt/IBM/db2/clidriver/bin/" \
    ]

COPY --from=builder [ \
    "/opt/IBM/db2/clidriver/cfg/db2cli.ini.sample", \
    "/opt/IBM/db2/clidriver/cfg/db2dsdriver.cfg.sample", \
    "/opt/IBM/db2/clidriver/cfg/db2dsdriver.xsd", \
    "/opt/IBM/db2/clidriver/cfg/" \
    ]

COPY --from=builder [ \
    "/opt/IBM/db2/clidriver/conv/alt/08501252.cnv", \
    "/opt/IBM/db2/clidriver/conv/alt/12520850.cnv", \
    "/opt/IBM/db2/clidriver/conv/alt/IBM00850.ucs", \
    "/opt/IBM/db2/clidriver/conv/alt/IBM01252.ucs", \
    "/opt/IBM/db2/clidriver/conv/alt/" \
    ]

COPY --from=builder [ \
    "/opt/IBM/db2/clidriver/include/sqlcli1.h", \
    "/opt/IBM/db2/clidriver/include/sqlsystm.h", \
    "/opt/IBM/db2/clidriver/include/sqlca.h", \
    "/opt/IBM/db2/clidriver/include/sqlcli.h", \
    "/opt/IBM/db2/clidriver/include/sql.h", \
    "/opt/IBM/db2/clidriver/include/" \
    ]

COPY --from=builder [ \
    "/opt/IBM/db2/clidriver/lib/libdb2.so.1", \
    "/opt/IBM/db2/clidriver/lib/libdb2o.so.1", \
    "/opt/IBM/db2/clidriver/lib/" \
    ]

COPY --from=builder [ \
    "/opt/IBM/db2/clidriver/msg/en_US.iso88591/db2admh.mo", \
    "/opt/IBM/db2/clidriver/msg/en_US.iso88591/db2adm.mo", \
    "/opt/IBM/db2/clidriver/msg/en_US.iso88591/db2clia1.lst", \
    "/opt/IBM/db2/clidriver/msg/en_US.iso88591/db2clias.lst", \
    "/opt/IBM/db2/clidriver/msg/en_US.iso88591/db2clih.mo", \
    "/opt/IBM/db2/clidriver/msg/en_US.iso88591/db2cli.mo", \
    "/opt/IBM/db2/clidriver/msg/en_US.iso88591/db2clit.mo", \
    "/opt/IBM/db2/clidriver/msg/en_US.iso88591/db2clp.mo", \
    "/opt/IBM/db2/clidriver/msg/en_US.iso88591/db2diag.mo", \
    "/opt/IBM/db2/clidriver/msg/en_US.iso88591/db2sqlh.mo", \
    "/opt/IBM/db2/clidriver/msg/en_US.iso88591/db2sql.mo", \
    "/opt/IBM/db2/clidriver/msg/en_US.iso88591/" \
    ]

COPY --from=builder [ \
    "/tmp/extracted-jdbc/db2jcc.jar", \
    "/tmp/extracted-jdbc/db2jcc4.jar", \
    "/tmp/extracted-jdbc/sqlj.zip", \
    "/tmp/extracted-jdbc/sqlj4.zip", \
    "/opt/IBM/db2/jdbc/" \
    ]

# FIXME: The following files have not yet been approved for distribution, but are necessary.

#COPY --from=builder [ \
#    "/opt/IBM/db2/clidriver/lib/icc/libgsk8cms_64.so", \
#    "/opt/IBM/db2/clidriver/lib/icc/libgsk8iccs_64.so", \
#    "/opt/IBM/db2/clidriver/lib/icc/libgsk8km_64.so", \
#    "/opt/IBM/db2/clidriver/lib/icc/libgsk8ssl_64.so", \
#    "/opt/IBM/db2/clidriver/lib/icc/libgsk8sys_64.so", \
#    "/opt/IBM/db2/clidriver/lib/icc/" \
#    ]

#COPY --from=builder [ \
#    "/opt/IBM/db2/clidriver/lib/icc/C/icc/icclib/ICCSIG.txt", \
#    "/opt/IBM/db2/clidriver/lib/icc/C/icc/icclib/libicclib084.so", \
#    "/opt/IBM/db2/clidriver/lib/icc/C/icc/icclib/" \
#    ]

# FIXME: For testing only.

# COPY --from=builder /opt/IBM/db2  /opt/IBM/db2

# Set environment variables.

ENV SENZING_ROOT=/opt/senzing
ENV PYTHONPATH=${SENZING_ROOT}/g2/python
ENV LD_LIBRARY_PATH=${SENZING_ROOT}/g2/lib:${SENZING_ROOT}/g2/lib/debian:/opt/IBM/db2/clidriver/lib
ENV DB2_CLI_DRIVER_INSTALL_PATH=/opt/IBM/db2/clidriver
ENV PATH=$PATH:/opt/IBM/db2/clidriver/adm:/opt/IBM/db2/clidriver/bin

# Copy files from repository.

COPY ./rootfs /

# Create files and links.

RUN touch /opt/IBM/db2/clidriver/bin/crypto_not_installed \
 && ln -s /opt/IBM/db2/clidriver/lib/libdb2.so.1  /opt/IBM/db2/clidriver/lib/libdb2.so \
 && ln -s /opt/IBM/db2/clidriver/lib/libdb2o.so.1 /opt/IBM/db2/clidriver/lib/libdb2o.so

# Runtime execution.

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["python"]
