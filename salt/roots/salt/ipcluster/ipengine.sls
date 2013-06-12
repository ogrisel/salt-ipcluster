{% set ipython_user = pillar.get('ipcluster.username', 'ipuser') %}
{% set ipython_home = pillar.get('ipcluster.userhome', '/home/ipuser') %}
{% set working_dir = pillar.get('ipcluster.engine.directory', ipython_home) %}

/etc/supervisor/conf.d/ipengine.conf:
    file.managed:
        - source: salt://ipcluster/etc/supervisor/conf.d/ipengine.conf
        - template: jinja
        - context:
            ipcluster: {{ ipython_home }}/venv/bin/ipcluster
            user: {{ ipython_user }}
            home: {{ ipython_home }}
            directory: {{ working_dir }}
        - user: root
        - group: root
        - require:
            - pkg: supervisor
            - pkg: python-psutil
            - pip: ipython

ipengine:
    supervisord:
        - running
        - require:
            - pkg: supervisor
            - user: {{ ipython_user }}
        - watch:
            - file: /etc/supervisor/supervisord.conf
            - file: /etc/supervisor/conf.d/ipengine.conf