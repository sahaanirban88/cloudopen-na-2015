{% set app_version = salt['cmd.run']('runuser -l deploy -c "~/getlatestappversion.sh git@gitlab.com:asaha/mywebapp.git"') %}

fetch_app_archive:
  module.run:
    - name: s3.get
    - bucket: mywebapp-us
    - path: mywebapp-{{ app_version }}.zip
    - local_file: /tmp/mywebapp-{{ app_version }}.zip

create_new_app_dir:
  file.directory:
    - name: /opt/web/mywebapp-{{ app_version }}
    - user: deploy
    - group: deploy
    - mode: 755
    - makedirs: True
    - require:
      - module: fetch_app_archive

deploy_app:
  module.run:
    - name: archive.unzip
    - zip_file: /tmp/mywebapp-{{ app_version }}.zip
    - dest: /opt/web/mywebapp-{{ app_version }}
    - runas: deploy
    - require:
      - module: fetch_app_archive
      - file: create_new_app_dir

create_app_symlink:
  file.symlink:
    - name: /opt/web/mywebapp
    - target: /opt/web/mywebapp-{{ app_version }}
    - require:
      - module: deploy_app

remove_app_archive:
  file.absent:
    - name: /tmp/mywebapp-{{ app_version }}.zip
    - require:
      - file: create_app_symlink

app_version:
  grains.present:
    - value: {{ app_version }}
    - require:
      - file: create_app_symlink
