supervisor:
  pkg.installed:
    - require:
      - pkg: Install Epel Repository

supervisord:
  service:
    - running
    - enable: True
    - require:
      - pkg: supervisor
