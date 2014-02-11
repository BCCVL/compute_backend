Plone Requirements:
    pkg.installed:
      - pkgs:
        - gcc
        - gcc-c++
        - make
        - gdal
        - git
        - subversion
        - mercurial
        - zlib-devel
        - libjpeg-turbo-devel
        - freetype-devel
        - libtiff-devel
        - python27-devel
      - require:
        - pkgrepo: erpel

Compute Requirements:
  pkg.installed:
    - pkgs:
      - R-devel
      - gcc
      - make
      - gdal
      - gdal-devel
      - proj-devel
      - proj-epsg
      - proj-nad
    - require:
      - pkg: Install Elgis Repository

plone:
  user.present:
    - fullname: Plone
    - shell: /bin/bash
    - createhome: true
    - gid_from_name: true
  ssh_auth:
    - present
    - user: plone
    - names:
      - {{ pillar['sshkeys']['data_mover']['pubkey'] }}
      - {{ pillar['sshkeys']['plone']['pubkey'] }}
    - require:
      - user: plone
  ssh_known_hosts.present:
    - name: localhost
    - user: plone
    - require:
      - user: plone

/home/plone/.ssh:
  file.directory:
    - user: plone
    - group: plone
    - mode: 0700
    - require:
      - user: plone

/home/plone/.ssh/id_rsa:
  file.managed:
    - user: plone
    - group: plone
    - mode: 0600
    - contents_pillar: sshkeys:plone:privkey
    - require:
      - file: /home/plone/.ssh

/home/plone/.ssh/id_rsa.pub:
  file.managed:
    - user: plone
    - group: plone
    - mode: 0600
    - contents_pillar: sshkeys:plone:pubkey
    - require:
      - file: /home/plone/.ssh

BCCVL Buildout Clone:
  git.latest:
    - name: https://github.com/BCCVL/bccvl_buildout.git
    - target: /home/plone/bccvl_buildout
    - runas: plone
    - require:
      - user: plone
      - pkg: Plone Requirements

BCCVL Buildout Config:
  file.managed:
    - name: /home/plone/bccvl_buildout/buildout.cfg
    - source:
      - salt://bccvl/buildout.cfg
    - user: plone
    - group: plone
    - mode: 640
    - template: jinja
    - defaults:
      admin_user: {{ pillar['plone']['admin'] }}
      admin_password: {{ pillar['plone']['password'] }}
      site_hostname: {{ pillar['plone']['hostname'] }}
      mr_developer_always_checkout: {{ pillar['plone']['mr_developer_always_checkout'] }}
      site_replace: {{ pillar['plone']['site_replace'] }}
    - require:
      - git: BCCVL Buildout Clone

BCCVL Bootstrap Buildout:
  cmd.run:
    - cwd: /home/plone/bccvl_buildout
    - user: plone
    - group: plone
    - name: python2.7 bootstrap.py
    - unless: test -x /home/plone/bccvl_buildout/bin/buildout
    - require:
      - file: BCCVL Buildout Config
      - pkg: Plone Requirements
      - pkg: Compute Requirements

BCCVL Buildout:
  cmd.run:
    - cwd: /home/plone/bccvl_buildout
    - user: plone
    - group: plone
    - name: /home/plone/bccvl_buildout/bin/buildout
    - require:
      - cmd: BCCVL Bootstrap Buildout
      - service: 4store
      - git: BCCVL Buildout Clone

/mnt/work:
  file.directory:
    - user: plone
    - group: plone
    - dir_mode: 750
    - recurse:
      - user
    - require:
      - user: plone

/etc/supervisord.d/bccvl.ini:
  file.managed:
    - source: salt://bccvl/plone_supervisor.ini
    - user: root
    - group: root
    - mode: 640
    - template: jinja
    - require:
      - pkg: supervisor
    - watch:
      - cmd: BCCVL Buildout
    - watch_in:
      - service: supervisord

/etc/varnish/bccvl.vcl:
  file.managed:
    - source: salt://bccvl/bccvl.vcl
    - user: root
    - group: root
    - mode: 640
    - template: jinja
    - require:
      - pkg: varnish
    - watch_in:
      - service: varnish

/etc/sysconfig/varnish:
  file.managed:
    - source: salt://bccvl/varnish.sysconfig
    - user: root
    - group: root
    - mode: 640
    - template: jinja
    - require:
      - pkg: varnish
      - file: /etc/varnish/bccvl.vcl
    - watch_in:
      - service: varnish

/etc/haproxy/haproxy.cfg:
  file.managed:
    - source: salt://bccvl/haproxy.cfg
    - user: root
    - group: root
    - mode: 640
    - template: jinja
    - requires:
      - pkg: haproxy
    - watch_in:
      - service: haproxy
