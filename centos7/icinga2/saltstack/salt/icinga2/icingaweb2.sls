####################################################
# icingaweb2
####################################################
# author: sunrise cobb 
# date: 2020-06-xx

# guides:
# - https://icinga.com/docs/icingaweb2/latest/doc/02-Installation/
# - https://icinga.com/docs/icingaweb2/latest/doc/20-Advanced-Topics/#web-setup-automation

# notes:
#login: 
#http://192.168.10.11/icingaweb2/authentication/login

# api test:
#curl -k -s -u username:password 'https://localhost:5665/v1'

# you might have firewall / selinux issues, just turn em off
# if they update php you will need to update the version of php-fpm that runs


####################################################



# this guy has all the new php packages we need...which are a TON.
centos-release.packages:
  pkg.installed:
    - pkgs:
      - centos-release-scl-rh
    - refresh: true

# the rest of everything else
web.packages:
  pkg.installed:
    - pkgs:
      - icingaweb2
      - icingacli
      - httpd


# just incase selinux is running turn it off
turn-off-selinux:
  cmd.run:
    - name: sudo setenforce 0
    - unless: getenforce | grep Permissive

# use the icingacli to create a setup token...
# create-icinga-token:
#   cmd.run:
#     - name: icingacli setup token create;
#     - unless: ls /etc/icingaweb2/setup.token

# make sure we have the correct perms on our config dir
create-icinga-directory:
  cmd.run:
    - name: icingacli setup config directory --group icingaweb2;
    - unless: ls /etc/icingaweb2


# enable the api in the icinga2 service
icinga2-enable-api:
  cmd.run:
    - name: "icinga2 feature enable api"
    - unless: icinga2 feature list | grep Enabled | grep api

# generate out the api requirements (keys / users / etc)
icinga2-generate-api:
  cmd.run:
    - name: "icinga2 api setup"
    - unless: ls /var/lib/icinga2/ca/ca.key

# turn on the monitoring module
icingaweb2-enable-monitoring:
  cmd.run:
    - name: "icingacli module enable monitoring"
    - unless: icingacli module list | grep monitoring


# push out our users / perms
/etc/icinga2/conf.d/api-users.conf:
  file.managed:
    - name: /etc/icinga2/conf.d/api-users.conf
    - source: salt://icinga2/files/icingaweb2/api-users.conf.jinja
    - mode: 644
    - template: jinja


# file set required to make this a standup service with no web wizard
/etc/icingaweb2/resources.ini:
  file.managed:
    - user: root
    - group: icingaweb2
    - name: /etc/icingaweb2/resources.ini
    - source: salt://icinga2/files/icingaweb2/resources.ini.jinja
    - mode: 640
    - template: jinja

/etc/icingaweb2/config.ini:
  file.managed:
    - user: root
    - group: icingaweb2
    - name: /etc/icingaweb2/config.ini
    - source: salt://icinga2/files/icingaweb2/config.ini.jinja
    - mode: 640
    - template: jinja

/etc/icingaweb2/authentication.ini:
  file.managed:
    - user: root
    - group: icingaweb2
    - name: /etc/icingaweb2/authentication.ini
    - source: salt://icinga2/files/icingaweb2/authentication.ini.jinja
    - mode: 640
    - template: jinja

/etc/icingaweb2/roles.ini:
  file.managed:
    - user: root
    - group: icingaweb2
    - name: /etc/icingaweb2/roles.ini
    - source: salt://icinga2/files/icingaweb2/roles.ini.jinja
    - mode: 640
    - template: jinja

/etc/icingaweb2/modules/monitoring/:
  file.directory:
    - user: root
    - group: icingaweb2
    - mode: 755
    - makedirs: True

/etc/icingaweb2/modules/monitoring/config.ini:
  file.managed:
    - user: root
    - group: icingaweb2
    - name: /etc/icingaweb2/modules/monitoring/config.ini
    - source: salt://icinga2/files/icingaweb2/modules/monitoring/config.ini.jinja
    - mode: 640
    - template: jinja

/etc/icingaweb2/modules/monitoring/backends.ini:
  file.managed:
    - user: root
    - group: icingaweb2
    - name: /etc/icingaweb2/modules/monitoring/backends.ini
    - source: salt://icinga2/files/icingaweb2/modules/monitoring/backends.ini.jinja
    - mode: 640
    - template: jinja

/etc/icingaweb2/modules/monitoring/commandtransports.ini:
  file.managed:
    - user: root
    - group: icingaweb2
    - name: /etc/icingaweb2/modules/monitoring/commandtransports.ini
    - source: salt://icinga2/files/icingaweb2/modules/monitoring/commandtransports.ini.jinja
    - mode: 640
    - template: jinja


# this needs to be restarted after the API was enabled
icinga2-service:
  service.running:
    - name: icinga2
    - enable: True
    - full_restart: True

# start / enable the rest of the required services
httpd-service:
  service.running:
    - enable: True
    - name: httpd
    - full_restart: True

rh-php71-php-fpm-service:
  service.running:
    - enable: True
    - name: rh-php73-php-fpm
    - full_restart: True

# cause the above doesn't really wanna work...sigh...
restart-all-services-hacky:
  cmd.run:
    - name: systemctl restart icinga2; systemctl restart httpd; systemctl restart rh-php73-php-fpm

####################################################
# icingaweb2
####################################################




