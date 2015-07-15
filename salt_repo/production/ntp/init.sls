ntp:
  pkg.installed

ntpd:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - pkg: ntp
