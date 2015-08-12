{% set app_version = salt['cmd.run']('runuser -l deploy -c "~/getlatestappversion.sh git@gitlab.com:asaha/mywebapp.git"') %}

/opt/web/mywebapp:
  file.directory:
    - user: deploy
    - group: deploy
    - mode: 755
    - makedirs: True

fetch_app_archive:
  module.run:
    - name: s3.get
    - bucket: mywebapp-us
    - path: mywebapp-{{ app_version }}.tar
    - local_file: /tmp/mywebapp-{{ app_version }}.tar

backup_app:
  cmd.wait:
    - name: 'rm -rf /opt/web/mywebapp.old; cp -r /opt/web/mywebapp /opt/web/mywebapp.old; rm -rf /opt/web/mywebapp/*'
    - user: deploy
    - require:
      - module: fetch_app_archive
      - file: /opt/web/mywebapp
    - watch:
      - module: fetch_app_archive

deploy_app:
  cmd.wait:
    - name: 'tar -xf /tmp/mywebapp-{{ app_version }}.tar -C /opt/web/mywebapp'
    - user: deploy
    - require:
      - file: /opt/web/mywebapp
      - cmd: backup_app
    - watch:
      - cmd: backup_app

remove_app_archive:
  cmd.wait:
    - name: 'rm -rf /tmp/mywebapp-{{ app_version }}.tar'
    - require:
      - module: fetch_app_archive
    - watch:
      - cmd: deploy_app

app_version:
  grains.present:
    - value: {{ app_version }}
    - require:
      - cmd: deploy_app
