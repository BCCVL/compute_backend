#!py

import os
import os.path
import subprocess

def getKeys(user, keydir):
    privfile = os.path.join(keydir, user + '_id_rsa')
    pubfile = os.path.join(keydir, user + '_id_rsa.pub')
    if not os.path.exists(privfile):
        subprocess.check_call(["ssh-keygen", "-t", "rsa", "-N", "", "-f", privfile])
    privkey = open(privfile, 'r').read()
    pubkey = open(pubfile, 'r').read()
    return privkey, pubkey

def debug_env():
    f = open('/tmp/output', 'w')
    f.write(__name__)
    f.write('=========== __salt__ \n')
    pprint(__salt__, f)
    f.write('=========== __grains__ \n')
    pprint(__grains__, f)
    f.write('=========== __pillar__ \n')
    pprint(__pillar__, f)
    f.write('=========== __opts__ \n')
    pprint(__opts__, f)
    f.write('=========== __env__ \n')
    pprint(__env__, f)
    f.write('=========== __sls__ \n')
    pprint(__sls__, f)
    f.close()

def run():
    config = {'sshkeys': {}}
    keydir = os.path.join(__opts__['pillar_roots'][__env__][0], __sls__.replace(':',os.path.pathsep))
    if not os.path.exists(keydir):
        os.mkdir(keydir, 0700)
    for user in ('data_mover', 'visualiser', 'plone'):
        privkey, pubkey = getKeys(user, keydir)
        config['sshkeys'][user] = {
            'privkey': privkey,
            'pubkey': pubkey }
    return config
