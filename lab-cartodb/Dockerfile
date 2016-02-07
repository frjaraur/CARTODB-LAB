### CartoDB Dockerfile
#
#### CARTODB
#V1.0 - FRJARAUR
####

FROM ubuntu:precise

MAINTAINER FRJARAUR "frjaraur@gmail.com"

ENV DEBIAN_FRONTEND noninteractive 


WORKDIR /CARTODB

RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

ENV LANG en_US.UTF-8 
ENV LC_ALL en_US.UTF-8
ENV LANGUAGE = en_US


ENV CARTODB /CARTODB
ENV REDIS /REDIS
ENV SQLAPI $CARTODB/CartoDB-SQL-API
ENV MAPAPI $CARTODB/Windshaft-cartodb
ENV CARTODBMAIN $CARTODB/cartodb

ENV RAILS_ENV development


RUN apt-get update && \
    apt-get install -y software-properties-common \
    python-software-properties apt-utils wget

## Add Repositories
RUN add-apt-repository ppa:cartodb/redis && \
	add-apt-repository ppa:cartodb/postgresql-9.3 && \
	add-apt-repository ppa:cartodb/nodejs-010 && \
	add-apt-repository ppa:cartodb/pg-schema-trigger && \
	add-apt-repository ppa:cartodb/gis

# Set postgreSQL user/group IDs
RUN groupadd -r postgres --gid=999 && useradd -r -g postgres --uid=999 postgres

## Base Packages, I added some network tools for debugging purposes :P
RUN apt-get update && \
    apt-get install -y autoconf binutils-doc bison build-essential flex git \
    libpango1.0-dev libreadline6-dev openssl python-all-dev imagemagick unp zip wget curl \
    libjpeg-turbo8-dev redis-server libpq5 libpq-dev postgresql-client-9.3 \
    postgresql-client-common nodejs gdal-bin libgdal1-dev libgdal-dev libicu-dev \
    postgresql-9.3 postgresql-contrib-9.3 postgresql-server-dev-9.3 postgresql-plpython-9.3 \
    postgresql-9.3-pg-schema-triggers postgresql-9.3-plproxy proj proj-bin proj-data libproj-dev \
    postgresql-server-dev-all libjson0 libjson0-dev python-simplejson libgeos-c1v5 libgeos-dev \
    ogr2ogr2-static-bin libxml2-dev liblwgeom-2.1.8 postgresql-9.3-postgis-scripts zip wget ca-certificates \
    net-tools iputils-ping ldap-utils vim  

#Update npm
RUN curl -L https://www.npmjs.com/install.sh | sh


#postgis postgresql-9.3-postgis-2.2
##Postgis madness

RUN wget http://download.osgeo.org/postgis/source/postgis-2.2.1.tar.gz && tar xzf postgis-2.2.1.tar.gz && \
	cd postgis-2.2.1 && ./configure --with-raster --with-topology && make && make install && ldconfig


# Use gosu por step-down to postgres user
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu 


### PostgreSQL install

ENV PG_VERSION=9.3 \
    PG_USER=postgres \
    PG_HOME=/var/lib/postgresql \
    PG_RUNDIR=/var/run/postgresql \
    PG_LOGDIR=/var/log/postgresql \
    PG_CERTDIR=/etc/postgresql/certs

ENV PG_BINDIR=/usr/lib/postgresql/${PG_VERSION}/bin

ENV PATH $PATH:$PG_BINDIR

ENV PGDATA /DATA

RUN mkdir -p /DATA && chown -R postgres:postgres $PGDATA

RUN gosu postgres initdb

RUN chmod g+s $PG_RUNDIR && \
	chown -R postgres $PG_RUNDIR && echo "local all all trust" > ${PGDATA}/pg_hba.conf && \
	echo "host all all 127.0.0.1/32 trust" >> ${PGDATA}/pg_hba.conf &&\	
	echo "host all all 0.0.0.0/0 trust" >>${PGDATA}/pg_hba.conf && \
	echo "host all all ::1/128 trust"  >>${PGDATA}/pg_hba.conf && \  
	echo "shared_preload_libraries = 'schema_triggers.so'" >> ${PGDATA}/postgresql.conf && \
	grep -v "^listen_address"  ${PGDATA}/postgresql.conf|grep -v "^#" >${PGDATA}/postgresql.conf. && \
	echo "listen_addresses = '*'" >>${PGDATA}/postgresql.conf. && \
	echo "port = 5432" >>${PGDATA}/postgresql.conf. && \
	mv ${PGDATA}/postgresql.conf. ${PGDATA}/postgresql.conf && chown -R postgres "${PGDATA}"


# CartoDB PostgreSQL Extension
# This is the first approach, we could use a simplest and update entrypoint with a script that uses git description and get from there the lastest version
#ENV CARTODB_PG_LATEST 0.11.5-g2ab0594
ENV CARTODB_PG_LATEST 0.13.1

RUN git clone https://github.com/CartoDB/cartodb-postgresql.git && cd cartodb-postgresql &&  \
	git checkout $CARTODB_PG_LATEST && make all install && ldconfig

## SQL API Install
RUN git clone git://github.com/CartoDB/CartoDB-SQL-API.git && cd $CARTODB/CartoDB-SQL-API && \
	git checkout master && 	npm install

   
## MAP API Install
RUN git clone git://github.com/CartoDB/Windshaft-cartodb.git && cd $CARTODB/Windshaft-cartodb && \
	git checkout master && npm install

## PIP Install
RUN wget -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py && python /tmp/get-pip.py


## RUBY And Some Gems Install
RUN wget -O /tmp/ruby-install-0.5.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz && \
	cd /tmp && tar -xzvf ruby-install-0.5.0.tar.gz && cd ruby-install-0.5.0 && make install
	
RUN ruby-install ruby 2.2.4
ENV PATH $PATH:/opt/rubies/ruby-2.2.4/bin
RUN gem install bundler &&  gem install compass

## EDITOR Install
	
ENV CPLUS_INCLUDE_PATH /usr/include/gdal
ENV C_INCLUDE_PATH /usr/include/gdal
ENV PATH $PATH:/usr/include/gdal

ENV PATH $PATH:$CARTODBMAIN/node_modules/grunt-cli/bin
RUN echo UPDATE
RUN git clone --recursive https://github.com/CartoDB/cartodb.git 
#COPY configs/ldap.rb $CARTODBMAIN/spec/factories/ldap.rb
RUN cd $CARTODBMAIN && git checkout master && RAILS_ENV=development bundle install && npm install && \
	CPLUS_INCLUDE_PATH=/usr/include/gdal C_INCLUDE_PATH=/usr/include/gdal PATH=$PATH:/usr/include/gdal \
	pip install --no-use-wheel -r python_requirements.txt && PATH=$PATH:$PWD/node_modules/grunt-cli/bin \
	bundle install && bundle exec node_modules/grunt-cli/bin/grunt --environment development

RUN cd $CARTODB && git clone https://github.com/CartoDB/geocoder-api.git && cd $CARTODB/geocoder-api && \
	cd ./server/extension/ && make all install && cd ../../client && make all install


RUN	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


## Put Some Config Files for Applications
#I did this for managing my own development configurations, but they are not needed any more because everything is in this container
#COPY configs/mapapi_development.js $MAPAPI/config/environments/development.js
#COPY configs/sqlapi_development.js $SQLAPI/config/environments/development.js
#COPY configs/main_app_config.yml $CARTODBMAIN/config/app_config.yml
#COPY configs/main_database.yml $CARTODBMAIN/config/database.yml  
COPY configs/redis.conf ${REDIS}/redis.conf
RUN cp $SQLAPI/config/environments/development.js.example $SQLAPI/config/environments/development.js && \
    cp $MAPAPI/config/environments/development.js.example $MAPAPI/config/environments/development.js && \
    cp $CARTODBMAIN/config/app_config.yml.sample $CARTODBMAIN/config/app_config.yml && \
    cp $CARTODBMAIN/config/database.yml.sample $CARTODBMAIN/config/database.yml

#LDAP Environment
#ldap is the name of linked host in this case
ENV HOST ldap
#ENV ORGANIZATION_ID 309AF39093AFBBDCF902093015672309
ENV ORGANIZATION_NAME cartodb
ENV PORT 389
ENV CONNECTION_USER ldap_conn_user
ENV CONNECTION_PASSWORD changeme
ENV USER_ID_FIELD user_id
ENV USERNAME_FIELD user_name
ENV EMAIL_FIELD email
ENV DOMAIN_BASES cartodb.com
ENV USER_OBJECT_CLASS organizationalUnit
ENV GROUP_OBJECT_CLASS organizationalUnit



WORKDIR /

## Volumes to store
VOLUME ["${CARTODB}","${REDIS}","${PG_RUNDIR}","${PGDATA}"]

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3000 6379 8080 8181 5432

CMD [ "start_all" , "" ,"bash"]
