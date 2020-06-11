####################################################
# icinga engine
####################################################
# author: sunrise cobb 
# date: 2020-06-xx

# guides:
# - https://icinga.com/docs/icinga2/latest/doc/02-installation/
# - https://icinga.com/docs/director/latest/doc/03-Automation/
# - https://icinga.com/docs/director/latest/doc/75-Background-Daemon/

# notes:
#


# we need to grab the release || NOTE (sunrise): can't seem to get this to run clean
icinga-release:
  pkg.installed:
    - sources:
      - icinga-release: salt://icinga2/files/icinga2/icinga-rpm-release-7-latest.noarch.rpm
    - unless: rpm -q icinga-rpm-release-7-4.el7.icinga.noarch
    - refresh: true

epel.packages:
  pkg.installed:
    - pkgs:
      - epel-release
    - refresh: true

# rest of the packages as the epel and icinga needed to be refreshed for these to work
icinga.packages:
  pkg.installed:
    - pkgs:
      - icinga2
      - nagios-plugins-all
      - icinga2-selinux
      - icinga2-ido-mysql


# files
configure-mysql-ido-file:
  file.managed:
    - user: icinga
    - group: icinga
    - name: /etc/icinga2/features-available/ido-mysql.conf
    - source: salt://icinga2/files/icinga2/ido-mysql.conf.jinja
    - mode: 640
    - template: jinja


# enable the ido-mysql version  
icinga2-enable-ido:
  cmd.run:
    - name: "icinga2 feature enable ido-mysql"
    - unless: icinga2 feature list | grep Enabled | grep ido-mysql

# enable / start / reload the service (in case we run this multiple times)
icinga2-service:
  service.running:
    - name: icinga2
    - enable: True
    - full_restart: True

# cause the above doesn't really wanna work...sigh...
restart-all-services-hacky:
  cmd.run:
    - name: systemctl restart icinga2;

####################################################
# icinga engine
####################################################


