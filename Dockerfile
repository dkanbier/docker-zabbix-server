FROM centos:centos6
MAINTAINER Dennis Kanbier <dennis@kanbier.net>

# Update base images.
RUN yum distribution-synchronization -y

# Install EPEL, MySQL, Zabbix release packages.
RUN yum install -y epel-release 
RUN yum install -y http://repo.zabbix.com/zabbix/2.4/rhel/6/x86_64/zabbix-release-2.4-1.el6.noarch.rpm 
RUN yum makecache

# Installing SNMP Utils
RUN yum -y -q install net-snmp-devel net-snmp-libs net-snmp net-snmp-perl net-snmp-python net-snmp-utils

# Install zabbix server and php frontend
ADD ./zabbix/zabbix-server-mysql-2.4.3-1.el6.x86_64.rpm /tmp/zabbix-server-mysql-2.4.3-1.el6.x86_64.rpm
RUN yum -y -q localinstall --nogpgcheck /tmp/zabbix-server-mysql-2.4.3-1.el6.x86_64.rpm

# Cleaining up.
RUN yum clean all

# Zabbix Conf Files
ADD ./zabbix/zabbix_server.conf	/etc/zabbix/zabbix_server.conf
RUN chmod 640 /etc/zabbix/zabbix_server.conf
RUN chown root:zabbix /etc/zabbix/zabbix_server.conf

# Enable networking
RUN echo "NETWORKING=yes" > /etc/sysconfig/network

# Expose the Zabbix Server port 10051  
EXPOSE 10051 

# Start the custom zabbix_server binary in foreground mode ( -f )
CMD ["/usr/sbin/zabbix_server", "-f", " -c", "/etc/zabbix/zabbix_server.conf"]
