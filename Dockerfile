FROM python:3.7-slim-stretch

RUN apt-get update -y && apt-get install -y libzbar-dev bash gcc git \
    libc-dev libssl-dev libffi-dev libsasl2-dev libldap2-dev curl wget \
    vim sudo build-essential default-libmysqlclient-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Superset setup options
ENV SUPERSET_VERSION 0.38.0
ENV SUPERSET_HOME /superset
ENV SUP_ROW_LIMIT 5000
ENV SUP_WEBSERVER_THREADS 8
ENV SUP_WEBSERVER_WORKERS 10
ENV SUP_WEBSERVER_PORT 8088
ENV SUP_WEBSERVER_TIMEOUT 60
ENV SUP_SECRET_KEY 'thisismysecretkey'
ENV SUP_META_DB_URI "sqlite:///${SUPERSET_HOME}/superset.db"
ENV SUP_CSRF_ENABLED True
ENV SUP_CSRF_EXEMPT_LIST []
ENV MAPBOX_API_KEY ''
ENV PYTHONPATH $SUPERSET_HOME:$PYTHONPATH

# admin auth details
ENV ADMIN_USERNAME admin
ENV ADMIN_FIRST_NAME admin
ENV ADMIN_LAST_NAME admin
ENV ADMIN_EMAIL admin@admin.com
ENV ADMIN_PWD admin

COPY requirements/ ./
RUN pip install --upgrade pip \
    && pip install --no-cache-dir apache-superset==$SUPERSET_VERSION \
    && pip install --no-cache-dir -r prod.txt

RUN mkdir $SUPERSET_HOME
COPY superset-init.sh /superset-init.sh
RUN chmod +x /superset-init.sh

VOLUME $SUPERSET_HOME
EXPOSE 8088

# since this can be used as a base image adding the file /docker-entrypoint.sh
# is all you need to do and it will be run *before* Superset is set up
ENTRYPOINT [ "/superset-init.sh" ]