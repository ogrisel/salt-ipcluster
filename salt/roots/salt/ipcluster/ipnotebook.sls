{% set ipython_user = pillar.get('ipcluster.username', 'ipuser') %}
{% set ipython_home = pillar.get('ipcluster.userhome', '/home/ipuser') %}

# Configure the supervisor service to manage the ipython notebook process

/etc/supervisor/conf.d/ipnotebook.conf:
    file.managed:
        - source: salt://ipcluster/etc/supervisor/conf.d/ipnotebook.conf
        - template: jinja
        - context:
            ipython: {{ ipython_home }}/venv/bin/ipython
            user: {{ ipython_user }}
            home: {{ ipython_home }}
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
