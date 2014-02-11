#!py

import os
import os.path
import subprocess


def getKeys(name, keydir):
    keyfile = os.path.join(keydir, name + ".key")
    crtfile = os.path.join(keydir, name + ".crt")
    if not os.path.exists(keyfile):
        # create selfsigned cert
        subprocess.check_call(["openssl", "req", "-new",
        	"-nodes", "-x509",
        	"-newkey", "rsa:4096",
        	"-days", "365",
        	"-subj", "/C=AU/ST=QLD/L=Brisbane/O=Griffith/CN=example.com",
        	"-keyout", keyfile,
        	"-out", crtfile])
    crt = open(crtfile, 'r').read()
    key = open(keyfile, 'r').read()
    return crt, key


def run():
    config = {'ssl': {}}
    keydir = os.path.join(__opts__['pillar_roots'][__env__][0],
                          __sls__.replace(':', os.path.pathsep))
    if not os.path.exists(keydir):
        os.mkdir(keydir, 0700)
    crt, key = getKeys('bccvl', keydir)
    config['ssl']['bccvl.crt'] = crt
    config['ssl']['bccvl.key'] = key
    return config
