{% set ipython_user = pillar.get('ipcluster.username', 'ipuser') %}
{% set ipython_user_home = pillar.get('ipcluster.userhome', '/home/ipuser') %}

# Configure the supervisor service to manage the ipython notebook process

/etc/supervisor/conf.d/ipnotebook.conf:
    file.managed:
        - source: salt://ipcluster/etc/supervisor/conf.d/ipnotebook.conf
        - template: jinja
        - context:
            ipython: {{ ipython_user_home }}/venv/bin/ipython
            ipython_user: {{ ipython_user }}
            home: {{ ipython_user_home }}
        - user: root
        - group: root
        - require:
            - pkg: supervisor
            - pip: ipython

ipnotebook:
    supervisord:
        - running
        - require:
            - pkg: supervisor
            - user: {{ ipython_user }}
        - watch:
            - file: /etc/supervisor/supervisord.conf
            - file: /etc/supervisor/conf.d/ipnotebook.conf
