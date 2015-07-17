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

basic_pkgs:
  pkg.installed:
    - pkgs:
      - python-pip

boto:
  pip.installed:
    - require:
      - pkg: basic_pkgs
