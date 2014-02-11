{# TODO: could add my own grain to detect deployment env and decide for ext interface or try to discover real hostname #}
{% if grains.get('productname', '') == 'VirtualBox' %}
{% set hostname = grains['ip_interfaces']['eth1'][0] %}
{% elif grains['os'] == 'CentOS' %}
{% set hostname = grains['ip_interfaces']['eth0'][0] %}
{% else %}
{% set hostname = grains['ipv4'][1] if grains['ipv4'][0] == '127.0.0.1' else grains['ipv4'][0] %}
{% endif %}

plone:
    # set external if correctly for environment
    # replace servername with real seprvername for final deployment
    hostname: {{ hostname }}
    # hostname: 118.138.241.217 # daniel B's nectar VM

    admin: admin
    password: admin

    # mr_developer_always_checkout
    #
    # Affects how submodules in src are updated.
    #
    # 'true' for development (updates unless repo is dirty) - project default
    # 'false' for production (only checks out once - never updates)
    # 'force' for testing (always updates, even if repo is dirty)
    #
    mr_developer_always_checkout: true

    # site_replace
    #
    # Affects whether a site with same id is replaced, or remains
    # untouched.
    #
    # 'false' to NOT replace an existing site, if one is found - project default
    # 'true' to replace the existing site, if one is found
    site_replace: false

    siteid: bccvl

    compute_host: 127.0.0.1
    compute_user: plone

    # TODO: buildout template needs to support  parts
    instances:
        instance1:
            host: 127.0.0.1
            port: 8401
        instance2:
            host: 127.0.0.1
            port: 8402
        instance3:
            host: 127.0.0.1
            port: 8403
        instance4:
            host: 127.0.0.1
            port: 8404
        instance-debug:
            host: 127.0.0.1
            port: 8499
            debug: true

    workers:
        worker-debug:
            host: 127.0.0.1
            port: 8699
            debug: true
        worker1:
            host: 127.0.0.1
            port: 8601
        worker2:
            host: 127.0.0.1
            port: 8602
#        worker3:
#            host: 127.0.0.1
#            port: 8603
#        worker4:
#            host: 127.0.0.1
#            port: 8604

# TODO: not yet used
    zeomonitor:
        host: 127.0.0.1
        port: 8502

    cache:
        host: 127.0.0.1
        port: 8101

    moai:
        host: 127.0.0.1
        port: 8180

    balancer:
        host: 127.0.0.1
        port: 8201
