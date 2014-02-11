
Data Mover Requirements:
    pkg.installed:
      - pkgs:
        - git
        - readline-devel
        - patch
        - zlib-devel
        - bzip2-devel
        - openssl-devel
        - ncurses-devel
        - tk-devel
        - python27-devel
        - wget
        - sqlite
        - sqlite-devel
        - gcc # required by pysqlite
      - require:
        - pkgrepo: erpel

# Create data_mover user
data_mover:
  user.present:
    - fullname: Data Mover
    - shell: /bin/bash
    - createhome: true
    - gid_from_name: true
  ssh_known_hosts.present:
    - name: localhost
    - user: data_mover
    - require:
      - user: data_mover

/home/data_mover/.ssh:
  file.directory:
    - user: data_mover
    - group: data_mover
    - mode: 0700
    - require:
      - user: data_mover

/home/data_mover/.ssh/id_rsa:
  file.managed:
    - user: data_mover
    - group: data_mover
    - mode: 0600
    - contents_pillar: sshkeys:data_mover:privkey
    - require:
      - file: /home/data_mover/.ssh

/home/data_mover/.ssh/id_rsa.pub:
  file.managed:
    - user: data_mover
    - group: data_mover
    - mode: 0600
    - contents_pillar: sshkeys:data_mover:pubkey
    - require:
      - file: /home/data_mover/.ssh

/home/data_mover/tmp:
  file.directory:
    - user: data_mover
    - group: data_mover
    - makedirs: True

# Clone Data Mover repo
Data Mover Clone:
  git.latest:
    - name: https://github.com/BCCVL/bccvl_data_mover.git
    - target: /home/data_mover/bccvl_data_mover
    - runas: data_mover
    - require:
      - user: data_mover
      - pkg: Data Mover Requirements

/home/data_mover/bccvl_data_mover/data_mover/data_mover/destination_config.json:
  file.managed:
    - source:
      - salt://bccvl/datamover_destination_config.json
    - template: jinja
    - user: data_mover
    - group: data_mover
    - mode: 644

Data Mover Get Virtual Env:
  cmd.run:
    - name: wget https://pypi.python.org/packages/source/v/virtualenv/virtualenv-{{ pillar['virtualenv']['version'] }}.tar.gz {{ pillar['python']['wget_flags'] }}
    - user: data_mover
    - group: data_mover
    - cwd: /home/data_mover/tmp/
    - require:
      - user: data_mover
      - pkg: Data Mover Requirements
      - file: /home/data_mover/tmp
    - unless: test -d /home/data_mover/bccvl_data_mover/data_mover/env

Data Mover Extract Virtual Env:
  cmd.wait:
    - name: tar xvfz virtualenv-{{ pillar['virtualenv']['version'] }}.tar.gz
    - cwd: /home/data_mover/tmp/
    - user: data_mover
    - group: data_mover
    - watch:
      - cmd: Data Mover Get Virtual Env

Install Data Mover Virtual Env:
  cmd.wait:
    - name: python2.7 /home/data_mover/tmp/virtualenv-{{ pillar['virtualenv']['version'] }}/virtualenv.py env
    - cwd: /home/data_mover/bccvl_data_mover/data_mover/
    - user: data_mover
    - group: data_mover
    - require:
      - git: Data Mover Clone
    - watch:
      - cmd: Data Mover Extract Virtual Env

Data Mover Bootstrap Buildout:
  cmd.run:
    - cwd: /home/data_mover/bccvl_data_mover/data_mover/
    - user: data_mover
    - group: data_mover
    - name: ./env/bin/python bootstrap.py
    - require:
      - cmd: Data Mover Extract Virtual Env
      - cmd: Install Data Mover Virtual Env
    - watch:
      - git: Data Mover Clone

Data Mover Buildout:
  cmd.run:
    - cwd: /home/data_mover/bccvl_data_mover/data_mover/
    - user: data_mover
    - group: data_mover
    - name: ./bin/buildout
    - require:
      - cmd: Data Mover Bootstrap Buildout
      - git: Data Mover Clone

Data Mover Init DB:
  cmd.wait:
    - cwd: /home/data_mover/bccvl_data_mover/data_mover/
    - user: data_mover
    - group: data_mover
    - name: ./bin/initialize_data_mover_db {{ pillar['data_mover']['deploy_ini'] }}
    - watch:
      - cmd: Data Mover Bootstrap Buildout

/etc/supervisord.d/data_mover.ini:
  file.symlink:
    - target: /home/data_mover/bccvl_data_mover/data_mover/etc/supervisor.conf
    - require:
      - pkg: supervisor
    - watch:
      - cmd: Data Mover Buildout
    - watch_in:
      - service: supervisord

/home/data_mover/bccvl_data_mover/data_mover/var/log:
  file.directory:
    - user: data_mover
    - group: data_mover
    - makedirs: True
    - require:
      - user: data_mover
      - cmd: Data Mover Buildout
    - require_in:
      - service: supervisord

# Only link up the apache conf if we are building JUST the data_mover
{% if grains['id'] == 'data-mover' %}

/etc/httpd/conf.d/bccvl_data_mover.conf:
  file.symlink:
    - target: /home/data_mover/bccvl_data_mover/data_mover/etc/apache.conf
    - require:
      - pkg: httpd
    - watch:
      - cmd: Data Mover Buildout
    - watch_in:
      - service: httpd

{% else %}
# Else, ensure the symlink is missing

/etc/httpd/conf.d/bccvl_data_mover.conf:
  file.absent

{% endif %}

include:
  - bccvl.tools
  - bccvl.users
  - bccvl.base
  - bccvl.iptables
  - bccvl.supervisord
  - bccvl.httpd
