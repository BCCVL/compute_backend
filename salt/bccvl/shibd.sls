shibd:
  service:
    - running
    - enable: True
    - require:
      - pkg: Shibboleth Packages