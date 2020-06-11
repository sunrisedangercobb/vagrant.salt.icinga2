

test1:
  cmd.run:
    - name: echo '{{ salt['pillar.get']('icinga2:user_web_admin:password') }}' > /tmp/password.txt

{% set password_hash = salt['cmd.run']('openssl passwd -1 -in /tmp/password.txt') %}
test2:
  cmd.run:
    - name: echo '{{ password_hash }}'

test3:
  cmd.run:
    - name: rm /tmp/password.txt