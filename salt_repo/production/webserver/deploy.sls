git:
  pkg.installed

/opt/web/mywebapp:
  file.directory:
    - user: deploy
    - group: deploy
    - mode: 755
    - makedirs: True

fetch_app_archive:
  cmd.run:
    - name: 'git archive --format=tar --remote=git@gitlab.com:asaha/mywebapp.git {{ salt['pillar.get']('mywebapp_version') }} > /tmp/mywebapp-{{ salt['pillar.get']('mywebapp_version') }}.tar'
    - user: deploy
    - require:
      - pkg: git

backup_app:
  cmd.wait:
    - name: 'rm -rf /opt/web/mywebapp.old; cp -r /opt/web/mywebapp /opt/web/mywebapp.old; rm -rf /opt/web/mywebapp/*'
    - user: deploy
    - watch:
        - cmd: fetch_app_archive

deploy_app:
  cmd.wait:
    - name: 'tar -xf /tmp/mywebapp-{{ salt['pillar.get']('mywebapp_version') }}.tar -C /opt/web/mywebapp'
    - user: deploy
    - watch:
        - cmd: fetch_app_archive
