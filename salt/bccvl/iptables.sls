save iptables:
  module.run:
    - name: iptables.save
    - filename: /etc/sysconfig/iptables
