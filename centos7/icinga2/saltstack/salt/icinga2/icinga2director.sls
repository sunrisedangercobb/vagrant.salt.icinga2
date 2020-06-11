####################################################
# icinga2director
####################################################
# author: sunrise cobb 
# date: 2020-06

# guides:
# - https://icinga.com/docs/director/latest/doc/02-Installation/
# - https://icinga.com/docs/director/latest/doc/03-Automation/
# - https://icinga.com/docs/director/latest/doc/75-Background-Daemon/

# notes:
#
# still need to add the daemon and also there is a order of ops issue and the state need to run twice, so that needs to be fixed.
# https://icinga.com/docs/director/latest/doc/75-Background-Daemon/

# the rest of everything else
director.packages:
  pkg.installed:
    - pkgs:
      - rh-php73-php-process

# we need to make sure the directory exists and has the correct permissions
/usr/share/icingaweb2/modules/:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - unless: ls -d /usr/share/icingaweb2/modules

# explode the tarballs out there
extract_ipl:
  archive.extracted:
    - name: /usr/share/icingaweb2/modules/ipl
    - source: salt://icinga2/files/icinga2director/ipl-0.5.0.tar.gz
    - enforce_toplevel: False
    - options: --strip-components 1
    - user: root
    - group: root

extract_incubator:
  archive.extracted:
    - name: /usr/share/icingaweb2/modules/incubator
    - source: salt://icinga2/files/icinga2director/incubator-0.5.0.tar.gz
    - enforce_toplevel: False
    - options: --strip-components 1
    - user: root
    - group: root

extract_reactbundle:
  archive.extracted:
    - name: /usr/share/icingaweb2/modules/reactbundle
    - source: salt://icinga2/files/icinga2director/reactbundle-0.7.0.tar.gz
    - enforce_toplevel: False
    - options: --strip-components 1
    - user: root
    - group: root

extract_director:
  archive.extracted:
    - name: /usr/share/icingaweb2/modules/director
    - source: salt://icinga2/files/icinga2director/director-1.7.2.tar.gz
    - enforce_toplevel: False
    - options: --strip-components 1
    - user: root
    - group: root


# and now we need to enable all the modules
icingaweb2-enable-ipl:
  cmd.run:
    - name: "icingacli module enable ipl"
    - unless: icingacli module list | grep ipl

icingaweb2-enable-incubator:
  cmd.run:
    - name: "icingacli module enable incubator"
    - unless: icingacli module list | grep incubator

icingaweb2-enable-reactbundle:
  cmd.run:
    - name: "icingacli module enable reactbundle"
    - unless: icingacli module list | grep reactbundle

icingaweb2-enable-director:
  cmd.run:
    - name: "icingacli module enable director"
    - unless: icingacli module list | grep director


# make sure the config dirs and files exist
/etc/icingaweb2/modules/director/:
  file.directory:
    - user: root
    - group: icingaweb2
    - mode: 755
    - makedirs: True

/etc/icingaweb2/modules/director/config.ini:
  file.managed:
    - user: root
    - group: icingaweb2
    - name: /etc/icingaweb2/modules/director/config.ini
    - source: salt://icinga2/files/icingaweb2/modules/director/config.ini.jinja
    - mode: 640
    - template: jinja

# this will give us the bootstap info for our director setup
/etc/icingaweb2/modules/director/kickstart.ini:
  file.managed:
    - user: root
    - group: icingaweb2
    - name: /etc/icingaweb2/modules/director/kickstart.ini
    - source: salt://icinga2/files/icingaweb2/modules/director/kickstart.ini.jinja
    - mode: 640
    - template: jinja

# this guy will import all the configs from local disk (default checks n such)
run-director-migration:
  cmd.run:
    - name: icingacli director migration run --verbose;
    # - unless: ls /etc/icingaweb2

# this should create the director schema
run-director-kickstart:
  cmd.run:
    - name: icingacli director kickstart run

# setting up the icinga director daemon
# create user
icingadirector:
  user.present:
    - fullname: Icinga2 Director
    - shell: /bin/false
    - home: /var/lib/icingadirector
    - system: True
    - gid: icingaweb2

# get the homedir setup
icingadirector-homedir-setup:
  cmd.run:
    - name: install -d -o icingadirector -g icingaweb2 -m 0750 /var/lib/icingadirector
    # - unless: ls /var/lib/icingadirector

# install the daemon from the module installed
icingadirector-install-daemon:
  cmd.run:
    - name: MODULE_PATH=/usr/share/icingaweb2/modules/director; cp "${MODULE_PATH}/contrib/systemd/icinga-director.service" /etc/systemd/system/; systemctl daemon-reload
    - unless: ls /etc/systemd/system/icinga-director.service

# enable and start the service
icinga-director-service:
  service.running:
    - name: icinga-director
    - enable: True
    - full_restart: True

# reload all the services after we installed and enabled the new modules || this doesn't seem to be working...sigh
# icinga2-service:
#   service.running:
#     - name: icinga2
#     - full_restart: True

# httpd-service:
#   service.running:
#     - name: httpd
#     - full_restart: True

# rh-php71-php-fpm-service:
#   service.running:
#     - name: rh-php71-php-fpm
#     - full_restart: True


# crap to restart these cause the shit above doesn't seem to work 
restart-all-services-hacky:
  cmd.run:
    - name: systemctl restart icinga2; systemctl restart httpd; systemctl restart rh-php73-php-fpm; systemctl restart icinga-director

####################################################
# icinga2director
####################################################

# NOTES:
# take a look at the nodename in the constants.conf in /etc/icinga2/
# if it is the same name as you entered on the Icinga2 host make sure it is resolvable
