erpel:
  pkgrepo.managed:
    - humanname: CentOS-$releasever - Erpel
    - baseurl: http://mirror.griffith.edu.au/pub/erpel/CentOS/$releasever/erpel/
    - gpgcheck: 0
    - enabled: 1

security_shibboleth:
  pkgrepo.managed:
    - humanname: Shibboleth (CentOS_CentOS-6)
    - type: rpm-md
    - baseurl: http://download.opensuse.org/repositories/security:/shibboleth/CentOS_CentOS-6/
    - gpgcheck: 1
    - gpgkey: http://download.opensuse.org/repositories/security:/shibboleth/CentOS_CentOS-6/repodata/repomd.xml.key
    - enabled: 0

Install Epel Repository:
  pkg.installed:
    - sources:
      - epel-release: http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

Install Elgis Repository:
  pkg.installed:
    - sources:
      - elgis-release: http://elgis.argeo.org/repos/6/elgis-release-6-6_0.noarch.rpm

ElGIS Packages:
  pkg.installed:
    - pkgs:
      - postgis
      - postgis-client
      - proj-epsg
      - proj-nad
      - proj-devel
      - libgeotiff
      - libgeotiff-devel
    - require:
      - pkg: Install Elgis Repository
      - pkg: Install Epel Repository

EPEL Packages:
  pkg.installed:
    - pkgs:
      - geos
      - geos-devel
    - require:
      - pkg: Install Epel Repository

Shibboleth Packages:
  pkg.installed:
    - pkgs:
      - shibboleth
    - require:
      - pkgrepo: security_shibboleth
      - pkgrepo: erpel

python27:
  pkg.installed:
    - require:
      - pkgrepo: erpel

/etc/sudoers:
  file:
    - managed
    - source: salt://utils/etc/sudoers
    - user: root
    - mode: 400

iptables:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - require:
      - file: /etc/sysconfig/iptables

/etc/sysconfig/iptables:
  file:
    - managed
    - source: salt://utils/etc/sysconfig/iptables

