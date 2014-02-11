{{ pillar['httpd']['certfile'] }}:
    file.managed:
      - contents_pillar: ssl:bccvl.crt
      - user: root
      - group: root
      - mode: 444
      - watch_in:
        - service: httpd

{{ pillar['httpd']['keyfile'] }}:
    file.managed:
      - contents_pillar: ssl:bccvl.key
      - user: root
      - group: root
      - mode: 400
      - watch_in:
        - service: httpd
