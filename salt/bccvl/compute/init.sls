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
      - libpng-devel
      - java-1.7.0-openjdk-devel
      - java-1.7.0-openjdk
    - require:
      - pkg: Install Elgis Repository

R packages:
  cmd.run:
    - cwd: /var/tmp
    - user: root
    - group: root
    - name: /bin/sh /var/tmp/package_installer_R
    - require:
      - file: /var/tmp/package_installer_R
      - pkg: Compute Requirements

/var/tmp/package_installer_R:
  file:
    - managed
    - source: salt://utils/scripts/package_installer_R

include:
  - bccvl.tools
  - bccvl.base
  - bccvl.users
