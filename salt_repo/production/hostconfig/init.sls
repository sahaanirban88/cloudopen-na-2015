/etc/sysconfig/network:
  file.managed:
    - source: salt://hostconfig/files/network
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      minion_id: {{ grains['id'] }}

hostname {{ grains['id'] }}:
  cmd.run

python-pip:
  pkg.installed

boto:
  pip.installed:
    - require:
      - pkg: python-pip
