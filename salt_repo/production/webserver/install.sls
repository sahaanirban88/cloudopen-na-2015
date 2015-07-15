webserverpkgs:
  pkg.installed:
    - pkgs:
      - httpd
      - php
      - php-common
      - php-cli
      - php-devel

/etc/httpd/conf.d/mywebapp.conf:
  file.managed:
    - source: salt://webserver/files/mywebapp.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: webserverpkgs

httpd:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - pkg: webserverpkgs
      - file: /etc/httpd/conf.d/mywebapp.conf
