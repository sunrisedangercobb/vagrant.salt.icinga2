####################################################
# database
####################################################

# we really only want to do this if its a local test otherwise this stuff should be done
{% if salt['pillar.get']('icinga2:run_mode') == 'test' %}

database.packages:
  pkg.installed:
    - pkgs:
      - mariadb-server
      - mariadb

# start the service and enable it
mariadb:
  service.running:
    - enable: True
    - name: mariadb

# only required if your testing locally and with default setup as it comes with root/nopass
mysql-set-password:
  cmd.run:
    - name: mysql -uroot -hlocalhost -e 'SET PASSWORD FOR "root"@"localhost" = PASSWORD("root");'
    - onlyif: mysql -uroot -hlocalhost -e 'SHOW DATABASES;'

{% endif %}

# this is required on the target in order to run salt mysql
MySQL-python:
  pkg.installed

  
# add all the users, these are likely the same but we will write the code so they can be different
# add the icinga2 user
icinga2_create_db_user:
  mysql_user.present:
    - name: {{ salt['pillar.get']('icinga2:user_db_icinga2:name') }}
    - password: {{ salt['pillar.get']('icinga2:user_db_icinga2:password') }}
    - host: localhost
    - connection_user: {{ salt['pillar.get']('icinga2:user_db_admin:name') }}
    - connection_pass: {{ salt['pillar.get']('icinga2:user_db_admin:password') }}

# add the icingaweb2 user
icingaweb2_create_db_user:
  mysql_user.present:
    - name: {{ salt['pillar.get']('icinga2:user_db_icingaweb2:name') }}
    - password: {{ salt['pillar.get']('icinga2:user_db_icingaweb2:password') }}
    - host: localhost
    - connection_user: {{ salt['pillar.get']('icinga2:user_db_admin:name') }}
    - connection_pass: {{ salt['pillar.get']('icinga2:user_db_admin:password') }}

# add the icingaweb2 user
icinga2director_create_db_user:
  mysql_user.present:
    - name: {{ salt['pillar.get']('icinga2:user_db_icinga2director:name') }}
    - password: {{ salt['pillar.get']('icinga2:user_db_icinga2director:password') }}
    - host: localhost
    - connection_user: {{ salt['pillar.get']('icinga2:user_db_admin:name') }}
    - connection_pass: {{ salt['pillar.get']('icinga2:user_db_admin:password') }}


icinga2_create_db:

  # create the db
  mysql_database.present:
    - name: {{ salt['pillar.get']('icinga2:schemas:icinga2:name') }}
    - connection_user: {{ salt['pillar.get']('icinga2:user_db_admin:name') }}
    - connection_pass: {{ salt['pillar.get']('icinga2:user_db_admin:password') }}

  # grant it perms on the db
  mysql_grants.present:
    - grant: select, insert, update, delete, drop, create view, index, execute
    - database: {{ salt['pillar.get']('icinga2:schemas:icinga2:name') }}.*
    - user: {{ salt['pillar.get']('icinga2:user_db_icinga2:name') }}
    - password: {{ salt['pillar.get']('icinga2:user_db_icinga2:password') }}
    - host: localhost
    - connection_user: {{ salt['pillar.get']('icinga2:user_db_admin:name') }}
    - connection_pass: {{ salt['pillar.get']('icinga2:user_db_admin:password') }}

  # if you wanna do a new setup you add the default schema / otherwise import the icinga2-ido-mysql_ops.sql
  mysql_query.run_file:
    - database: {{ salt['pillar.get']('icinga2:schemas:icinga2:name') }}
    # - query_file: /usr/share/icinga2-ido-mysql/schema/mysql.sql
    - query_file: salt://icinga2/files/schemas/icinga2-ido-mysql.sql
    - connection_user: {{ salt['pillar.get']('icinga2:user_db_admin:name') }}
    - connection_pass: {{ salt['pillar.get']('icinga2:user_db_admin:password') }}

# create the icingaweb2 database
icingaweb2_create_db:

  # create the db
  mysql_database.present:
    - name: {{ salt['pillar.get']('icinga2:schemas:icingaweb2:name') }}
    - connection_user: {{ salt['pillar.get']('icinga2:user_db_admin:name') }}
    - connection_pass: {{ salt['pillar.get']('icinga2:user_db_admin:password') }}

  # grant it perms on the db
  mysql_grants.present:
    - grant: select, insert, update, delete, drop, create view, index, execute
    - database: {{ salt['pillar.get']('icinga2:schemas:icingaweb2:name') }}.*
    - user: {{ salt['pillar.get']('icinga2:user_db_icingaweb2:name') }}
    - password: {{ salt['pillar.get']('icinga2:user_db_icingaweb2:password') }}
    - host: localhost
    - connection_user: {{ salt['pillar.get']('icinga2:user_db_admin:name') }}
    - connection_pass: {{ salt['pillar.get']('icinga2:user_db_admin:password') }}

  # if you wanna do a new setup you add the default schema / otherwise import the icinga2-ido-mysql_ops.sql
  mysql_query.run_file:
    - database: {{ salt['pillar.get']('icinga2:schemas:icingaweb2:name') }}
    - query_file: salt://icinga2/files/schemas/icingaweb2.sql
    - connection_user: {{ salt['pillar.get']('icinga2:user_db_admin:name') }}
    - connection_pass: {{ salt['pillar.get']('icinga2:user_db_admin:password') }}

# create the icinga2director database
icinga2director_create_db:

  # create the db
  mysql_database.present:
    - name: {{ salt['pillar.get']('icinga2:schemas:icinga2director:name') }}
    - connection_user: {{ salt['pillar.get']('icinga2:user_db_admin:name') }}
    - connection_pass: {{ salt['pillar.get']('icinga2:user_db_admin:password') }}

  # grant it perms on the db
  mysql_grants.present:
    - grant: all privileges
    - database: {{ salt['pillar.get']('icinga2:schemas:icinga2director:name') }}.*
    - user: {{ salt['pillar.get']('icinga2:user_db_icinga2director:name') }}
    - password: {{ salt['pillar.get']('icinga2:user_db_icinga2director:password') }}
    - host: localhost
    - connection_user: {{ salt['pillar.get']('icinga2:user_db_admin:name') }}
    - connection_pass: {{ salt['pillar.get']('icinga2:user_db_admin:password') }}

mysql_delete_web_admin_user:
  mysql_query.run:
    - database: {{ salt['pillar.get']('icinga2:schemas:icingaweb2:name') }}
    - query: "DELETE FROM icingaweb_user WHERE name='{{ salt['pillar.get']('icinga2:user_web_admin:name') }}';"
    - connection_user: {{ salt['pillar.get']('icinga2:user_db_admin:name') }}
    - connection_pass: {{ salt['pillar.get']('icinga2:user_db_admin:password') }}
    - onlyif: mysql -u{{ salt['pillar.get']('icinga2:user_db_admin:name') }} -p{{ salt['pillar.get']('icinga2:user_db_admin:password') }} -h{{ salt['pillar.get']('icinga2:target_host_db:fqdn') }} -D{{ salt['pillar.get']('icinga2:schemas:icingaweb2:name') }} -e "SELECT * FROM icingaweb_user WHERE name='{{ salt['pillar.get']('icinga2:user_web_admin:name') }}';" | grep {{ salt['pillar.get']('icinga2:user_web_admin:name') }}

mysql_add_web_admin_user:
  mysql_query.run:
    - database: {{ salt['pillar.get']('icinga2:schemas:icingaweb2:name') }}
    - query: "INSERT INTO icingaweb_user (name, active, password_hash) VALUES ('{{ salt['pillar.get']('icinga2:user_web_admin:name') }}', 1, '{{ salt['pillar.get']('icinga2:user_web_admin:password_hash') }}');"
    - connection_user: {{ salt['pillar.get']('icinga2:user_db_admin:name') }}
    - connection_pass: {{ salt['pillar.get']('icinga2:user_db_admin:password') }}
    - unless: mysql -u{{ salt['pillar.get']('icinga2:user_db_admin:name') }} -p{{ salt['pillar.get']('icinga2:user_db_admin:password') }} -h{{ salt['pillar.get']('icinga2:target_host_db:fqdn') }} -D{{ salt['pillar.get']('icinga2:schemas:icingaweb2:name') }} -e "SELECT * FROM icingaweb_user WHERE name='{{ salt['pillar.get']('icinga2:user_web_admin:name') }}';" | grep {{ salt['pillar.get']('icinga2:user_web_admin:name') }}


####################################################
# database
####################################################


