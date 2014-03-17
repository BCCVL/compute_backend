base:
  'compute':
    - bccvl.users
  'plone':
    - bccvl.httpd
    - bccvl.ssl
    - bccvl.supervisord
    - bccvl.plone
    - bccvl.users
    - bccvl.sshkeys
    # include all pillars as they are needed for httpd config
    - bccvl.visualiser
    - bccvl.data_mover
  'visualiser':
    - bccvl.visualiser
    - bccvl.virtualenv
    - bccvl.python
    - bccvl.sshkeys
  'data-mover':
    - bccvl.data_mover
    - bccvl.virtualenv
    - bccvl.python
    - bccvl.sshkeys
  'combined':
    - bccvl.supervisord
    - bccvl.httpd
    - bccvl.ssl
    - bccvl.plone
    - bccvl.visualiser
    - bccvl.users
    - bccvl.virtualenv
    - bccvl.python
    - bccvl.data_mover
    - bccvl.sshkeys
  'bccvl-combined-qa':
    - bccvl.supervisord
    - bccvl.httpd
    - bccvl.ssl
    - bccvl.plone
    - bccvl.visualiser
    - bccvl.users
    - bccvl.virtualenv
    - bccvl.python
    - bccvl.data_mover
    - bccvl.sshkeys
  'bccvl-qa-combined':
    - bccvl.supervisord
    - bccvl.httpd
    - bccvl.ssl
    - bccvl.plone
    - bccvl.visualiser
    - bccvl.users
    - bccvl.virtualenv
    - bccvl.python
    - bccvl.data_mover
    - bccvl.sshkeys
  'bccvl-test-combined':
    - bccvl.supervisord
    - bccvl.httpd
    - bccvl.ssl
    - bccvl.plone
    - bccvl.visualiser
    - bccvl.users
    - bccvl.virtualenv
    - bccvl.python
    - bccvl.data_mover
    - bccvl.sshkeys
