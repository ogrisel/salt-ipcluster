{% set ipython_user = pillar.get('ipcluster.username', 'ipuser') %}
{% set ipython_home = pillar.get('ipcluster.userhome', '/home/ipuser') %}
{% set working_dir = ipython_home + '/notebooks' %}
{% set working_dir = pillar.get('ipcluster.engine.directory', working_dir) %}

/etc/supervisor/conf.d/ipcontroller.conf:
    file.managed:
        - source: salt://ipcluster/etc/supervisor/conf.d/ipcontroller.conf
        - template: jinja
        - context:
            ipcontroller: {{ ipython_home }}/venv/bin/ipcontroller
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

ipcontroller-working-dir:
    file.directory:
        - name: {{ working_dir }}
        - user: {{ ipython_user }}
        - mode: 755
        - makedirs: True

ipcontroller:
    supervisord:
        - running
        - names:
            - ipcontroller
            - ipengine
        - require:
            - pkg: supervisor
            - user: {{ ipython_user }}
            - file: {{ working_dir }}
        - watch:
            - file: /etc/supervisor/supervisord.conf
            - file: /etc/supervisor/conf.d/ipcontroller.conf
