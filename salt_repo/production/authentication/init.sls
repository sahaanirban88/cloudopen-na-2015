deploy:
  user.present:
    - fullname: App Deploy User
    - shell: /bin/bash
    - home: /home/deploy
    - gid_from_name: True

/home/deploy/.ssh:
  file.directory:
    - user: deploy
    - group: deploy
    - mode: 755
    - makedirs: True
    - require:
      - user: deploy

/home/deploy/.ssh/id_rsa:
  file.managed:
    - source: salt://authentication/files/id_rsa
    - user: deploy
    - group: deploy
    - mode: 600
    - require:
      - file: /home/deploy/.ssh

gitlab.com:
  ssh_known_hosts:
    - present
    - user: deploy
    - fingerprint: b6:03:0e:39:97:9e:d0:e7:24:ce:a3:77:3e:01:42:09
