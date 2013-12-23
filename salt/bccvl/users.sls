
{% for user, args in pillar.get('users', {}).items() %}
{{ user }}:
  user.present:
    - uid: {{ args['uid'] }}
    - createhome: true
    - shell: /bin/bash
    {% if args.get('groups', False) %}
    - groups: {{ args.get('groups', False) }}
    {% endif %}

  {% if args.get('key.pub', False) == True %}
  ssh_auth:
    - present
    - user: {{ user }}
    - source: salt://users/{{ user }}.pub
    - require:
      - user: {{ user }}
  {% endif %}
{% endfor %}
