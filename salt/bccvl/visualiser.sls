include:
  - bccvl.tools
  - bccvl.users
  - bccvl.base
  - bccvl.iptables
  - bccvl.supervisord
  - bccvl.httpd

Visualiser Requirements:
    pkg.installed:
      - pkgs:
        - git
        - readline-devel
        - libpng-devel
        - gd-devel
        - giflib-devel
        - patch
        - zlib-devel
        - bzip2-devel
        - openssl-devel
        - ncurses-devel
        - tk-devel
        - libjpeg-turbo-devel
        - lapack-devel
        - python27-devel
        - wget
        - java-1.7.0-openjdk-devel
        - libxml2-devel
        - geos-devel
        - gdal-devel
        - gdal
        - proj
        - proj-devel
        - proj-epsg
        - proj-nad
        - python-virtualenv
        - atlas-sse3-devel
        - atlas-devel
        - blas-devel
        - lapack-devel
        - subversion
        - gcc-c++
        - make
      - require:
        - pkgrepo: erpel
        - pkg: Install Elgis Repository

visualiser:
  user.present:
    - fullname: Visualiser
    - shell: /bin/bash
    - createhome: true
    - gid_from_name: true
  ssh_auth:
    - present
    - user: visualiser
    - names:
      - {{ pillar['sshkeys']['data_mover']['pubkey'] }}

/home/visualiser/.ssh:
  file.directory:
    - user: visualiser
    - group: visualiser
    - mode: 0700
    - require:
      - user: visualiser

/home/visualiser/.ssh/id_rsa:
  file.managed:
    - user: visualiser
    - group: visualiser
    - mode: 0600
    - contents_pillar: sshkeys:visualiser:privkey
    - require:
      - file: /home/visualiser/.ssh

/home/visualiser/.ssh/id_rsa.pub:
  file.managed:
    - user: visualiser
    - group: visualiser
    - mode: 0600
    - contents_pillar: sshkeys:visualiser:pubkey
    - require:
      - file: /home/visualiser/.ssh

Visualiser Clone:
  git.latest:
    - name: https://github.com/BCCVL/BCCVL_Visualiser.git
    - target: /home/visualiser/BCCVL_Visualiser
    - runas: visualiser
    - require:
      - user: visualiser
      - pkg: Visualiser Requirements

# TODO: move Requirements one up
Visualiser Virtualenv:
   virtualenv.managed:
    - name: /home/visualiser/BCCVL_Visualiser/env
    - python: /usr/bin/python2.7
    - user: visualiser
    - runas: visualiser
    - cwd: /home/visualiser/BCCVL_Visualiser/BCCVL_Visualiser/
    - require:
      - git: Visualiser Clone

Visualiser Virtualenv Numpy:
  cmd.run:
    - name: /home/visualiser/BCCVL_Visualiser/env/bin/pip install numpy
    - unless: /home/visualiser/BCCVL_Visualiser/env/bin/pip show numpy | grep -q 'Version:'
    - user: visualiser
    - group: visualiser
    - require:
      - virtualenv: Visualiser Virtualenv

Visualiser Virtualenv Matplotlib:
  cmd.run:
    - name: /home/visualiser/BCCVL_Visualiser/env/bin/pip install matplotlib
    - unless: /home/visualiser/BCCVL_Visualiser/env/bin/pip show matplotlib | grep -q 'Version:'
    - user: visualiser
    - group: visualiser
    - require:
      - cmd: Visualiser Virtualenv Numpy

Visualiser Buildout Config:
  file.managed:
    - name: /home/visualiser/BCCVL_Visualiser/BCCVL_Visualiser/buildout.cfg
    - source:
      - salt://bccvl/buildout_visualiser.cfg
    - user: visualiser
    - group: visualiser
    - mode: 640
    - template: jinja
    - defaults:
      site_hostname: {{ pillar['visualiser']['hostname'] }}
    - require:
      - git: Visualiser Clone

Visualiser Bootstrap Buildout:
  cmd.run:
    - cwd: /home/visualiser/BCCVL_Visualiser/BCCVL_Visualiser
    - user: visualiser
    - group: visualiser
    - name: ../env/bin/python bootstrap.py
    - unless: test -x /home/visualiser/BCCVL_Visualiser/BCCVL_Visualiser/bin/buildout
    - require:
      - cmd: Visualiser Virtualenv Matplotlib
      - file: Visualiser Buildout Config

Visualiser Buildout:
  cmd.run:
    - cwd: /home/visualiser/BCCVL_Visualiser/BCCVL_Visualiser
    - user: visualiser
    - group: visualiser
    - name: ./bin/buildout
    - require:
      - cmd: Visualiser Bootstrap Buildout

/etc/supervisord.d/visualiser.ini:
  file.symlink:
    - target: /home/visualiser/BCCVL_Visualiser/BCCVL_Visualiser/etc/supervisor.conf
    - require:
      - pkg: supervisor
    - watch:
      - cmd: Visualiser Buildout
    - watch_in:
      - service: supervisord

/home/visualiser/BCCVL_Visualiser/BCCVL_Visualiser/var/log:
# run  this only if requirements are fine otherwise a subsequent git
# clone will fail because of directory exists
  file.directory:
    - user: visualiser
    - group: visualiser
    - makedirs: True
    - require:
      - git: Visualiser Clone
    - require_in: 
      - service: supervisord


# Only link up the apache conf if we are building JUST the visualiser
# TODO: this works only if hostname is visualiser
{% if grains['id'] == 'visualiser' %}

/etc/httpd/conf.d/bccvl_visualiser.conf:
  file.symlink:
    - target: /home/visualiser/BCCVL_Visualiser/BCCVL_Visualiser/etc/apache.conf
    - require:
      - pkg: httpd
    - watch:
      - cmd: Visualiser Buildout
    - watch_in:
      - service: httpd

{% else %}
# Else, ensure the symlink is missing

/etc/httpd/conf.d/bccvl_visualiser.conf:
  file.absent

{% endif %}
