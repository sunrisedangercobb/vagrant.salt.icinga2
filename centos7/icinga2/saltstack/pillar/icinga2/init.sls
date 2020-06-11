icinga2:

  # you can do local testing by setting this to test, this will then install maria and do the setup for the service
  run_mode: test


  # all the user accounts that will get created
  user_api:
    name: <username0>
    password: <password0>


  user_db_icinga2:
    name: <username1>
    password: <password1>


  user_db_icingaweb2:
    name: <username2>
    password: <password2>


  user_db_icinga2director:
    name: <username3>
    password: <password3>


  # if you change this password you will need to update the password hash by running the below command
  # openssl passwd -1 <password>
  user_web_admin:
    name: <username4>
    password: <password4>
    password_hash: $1$wvC5AltM$0W8TOK76D5EOewFNnTyNR1


  # this is your connection user
  user_db_admin:
    name: root
    password: root


  # this will be required for the db state to work properly
  target_host_db:
    fqdn: localhost


  # all your schema names
  schemas:
    icinga2:
      name: icinga2
    icingaweb2:
      name: icinga2web
    icinga2director:
      name: icinga2director