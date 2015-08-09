{% set app_version = salt['pillar.get']('appversion') %}

{% if grains['app_version'] != app_version %}
deregister:
  module.run:
    - name: boto_elb.deregister_instances
    - m_name: mywebapp
    - instances:
      - {{ grains['ec2']['instance_id'] }}

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
    - require:
      - module: deregister

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

register:
  module.run:
    - name: boto_elb.register_instances
    - m_name: mywebapp
    - instances:
      - {{ grains['ec2']['instance_id'] }}
    - require:
      - cmd: deploy_app
{% endif %}
