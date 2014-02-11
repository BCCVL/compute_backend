{# TODO: could add my own grain to detect deployment env and decide for ext interface or try to discover real hostname #
         e.g. check ip range, ask Nectar data service, etc.. #}
{% if grains.get('productname', '') == 'VirtualBox' %}
{% set hostname = grains['ip_interfaces']['eth1'][0] %}
{% elif grains['os'] == 'CentOS' %}
{% set hostname = grains['ip_interfaces']['eth0'][0] %}
{% else %}
{% set hostname = grains['ipv4'][1] if grains['ipv4'][0] == '127.0.0.1' else grains['ipv4'][0] %}
{% endif %}
{# grains['virtual'] == 'VirtualBox', 'kvm' (Nectar), 'physical' (laptop) #}

httpd:
    # set external if correctly for environment
    # replace servername with real seprvername for final deployment
    servername: {{ hostname }}
    #servername: demo.bccvl.org.au
    serveradmin: eresearch@griffith.edu.au

    certfile: /etc/pki/tls/certs/demo.bccvl.org.au.crt
    keyfile: /etc/pki/tls/private/demo.bccvl.org.au.key

    shibboleth: true
