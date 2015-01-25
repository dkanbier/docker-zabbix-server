Docker Zabbix Server
========================

## Container 

This container provides a zabbix_server instance. 

It's designed to be used in conjunction with other containers and data-only containers and provides only 1 process: zabbix_server.

The idea is to use this container with docker-zabbix-mysql and docker-zabbix-web to form a working Zabbix installation, following the Docker principle of only using 1 process per container.

The zabbix-server binary bundled with this Git repository is patched with https://support.zabbix.com/browse/ZBXNEXT-611 to enable the server process to run in the foreground.

## Usage

This is an example to create a working Zabbix 2.4 server using docker-zabbix-server.

Create a data-only container to hold the actual database data:

````
docker run -v /var/lib/mysql --name zabbix-data busybox true
`````

Pull and build docker-zabbix-server:

````
git clone git://github.com/dkanbier/docker-zabbix-server .
docker build -t dkanbier/zabbix-server docker-zabbix-server/
`````

Pull and build docker-zabbix-mysql:

````
git clone git://github.com/dkanbier/docker-zabbix-mysql .
docker build -t dkanbier/zabbix-db docker-zabbix-mysql/
````

Pull and build docker-zabbix-web:

````
git clone git://github.com/dkanbier/docker-zabbix-web .
docker build -t dkanbier/zabbix-web docker-zabbix-web/
````

Now we have every component of Zabbix in a separate container, ready to start:

Start the database:

````
docker run -d --name zabbix-db --volumes-from zabbix-data dkanbier/zabbix-db
````

Start the Zabbix server and link it to the database:

````
docker run -d --name zabbix-server --link zabbix-db:zabbix-db dkanbier/zabbix-server
````

Start the web server:

````
docker run -d --name zabbix-web -p 80:80 --link zabbix-db:zabbix-db --link zabbix-server:zabbix-server dkanbier/zabbix-web
````

Done. There should be 3 running containers now:

````
CONTAINER ID        IMAGE                           COMMAND                PORTS 
e835be9e5a85        dkanbier/zabbix-web:latest      apachectl -DFOREGROU   0.0.0.0:80->80/tcp
dc1b4fbd756f        dkanbier/zabbix-server:latest   /usr/sbin/zabbix_ser   10051/tcp, 10052/tcp
7b956c5cd7eb        dkanbier/zabbix-db:latest       /bin/bash /start.sh    3306/tcp
````

And the Zabbix GUI should be availabe on the exposed port 80.
