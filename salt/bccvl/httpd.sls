include:
  - bccvl.iptables

httpd:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - watch:
      - pkg: httpd
      - pkg: mod_ssl

mod_ssl:
  pkg.installed

iptables 80:
  module.run:
    - name: iptables.insert
    - table: filter
    - chain: INPUT
    - position: 3
    - rule: -p tcp --dport 80 -j ACCEPT
    - require_in:
      - module: save iptables

iptables 443:
  module.run:
    - name: iptables.insert
    - table: filter
    - chain: INPUT
    - position: 3
    - rule: -p tcp --dport 443 -j ACCEPT
    - require_in:
      - module: save iptables

/etc/httpd/conf.d/bccvl.conf:
  file.managed:
    - source: 
      - salt://bccvl/bccvl_apache.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - watch_in:
        - service: httpd