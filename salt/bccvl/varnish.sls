varnish:
  pkg.installed:
    - require:
      - pkg: Install Epel Repository
  service:
    - running
    - enable: True
    - require:
      - pkg: varnish
