
{% for user, args in pillar.get('users', {}).iteritems() %}


{{ user }}:
  user.present:
    - name: {{ args['name'] }}
    - shell: {{ args['shell'] }}
    - home: /home/{{ args['name'] }}

{% endfor %}