{% set app_version = salt['pillar.get']('appversion') %}

{% if grains['app_version'] != app_version %}
deregister:
  module.run:
    - name: boto_elb.deregister_instances
    - m_name: mywebapp
    - instances:
      - {{ grains['ec2']['instance_id'] }}

fetch_app_archive:
  module.run:
    - name: s3.get
    - bucket: mywebapp-us
    - path: mywebapp-{{ app_version }}.zip
    - local_file: /tmp/mywebapp-{{ app_version }}.zip
    - require:
      - module: deregister

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

remove_old_app_dir:
  file.absent:
    - name: /opt/web/mywebapp-{{ grains['app_version'] }}

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

register:
  module.run:
    - name: boto_elb.register_instances
    - m_name: mywebapp
    - instances:
      - {{ grains['ec2']['instance_id'] }}
    - require:
      - grains: app_version
{% endif %}
