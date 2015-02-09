wget_deb:
  cmd.run:
    - name: wget https://downloads-packages.s3.amazonaws.com/ubuntu-12.04/gitlab_7.7.0-omnibus.5.4.0.ci-1_amd64.deb
    - user: root
    - group: root
    - cwd: /tmp

postfix:
  pkg.installed: []
  service.running:
    - enable: True
    - require:
      - pkg: postfix
    - watch:
      - pkg: postfix

install_gitlab:
  cmd.run:
    - name: dpkg -i gitlab_7.7.0-omnibus.5.4.0.ci-1_amd64.deb
    - user: root
    - group: root 
    - cwd: /tmp

reconfigure:
  cmd.run:
    - name: gitlab-ctl reconfigure
    - user: root
    - group: root
    - cwd: /tmp

/etc/postfix/main.cf:
  file.replace:
    - name: /etc/postfix/main.cf
    - user: root
    - group: postfix
    - pattern: ^myhostname =.*
    - repl: myhostname = {{ salt['pillar.get']('gitlab:gitlab_hostname') }}
/etc/postfix/main.cf_1:
  file.replace:
    - name: /etc/postfix/main.cf
    - user: root
    - group: postfix
    - pattern: ^mydestination =.*
    - repl: mydestination = {{ salt['pillar.get']('gitlab:gitlab_hostname') }}

/etc/gitlab/gitlab.rb:
  file.replace:
    - name: /etc/gitlab/gitlab.rb
    - user: root
    - group: root
    - pattern: ^# gitlab_rails\[\'gitlab_email_from\'\].*
    - repl: gitlab_rails['gitlab_email_from'] = {{ salt['pillar.get']('gitlab:gitlab_from_email') }} 
    
reconfigure_2:
  cmd.run:
    - name: gitlab-ctl reconfigure
    - user: root
    - group: root
    - cwd: /tmp
