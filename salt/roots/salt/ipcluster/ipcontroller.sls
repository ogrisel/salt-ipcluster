{% set ipython_user = pillar.get('ipcluster.username', 'ipuser') %}
{% set ipython_home = pillar.get('ipcluster.userhome', '/home/ipuser') %}
{% set working_dir = pillar.get('ipcluster.engine.directory', ipython_home) %}
{% set host_cpus = salt['ps.num_cpus']() %}

/etc/supervisor/conf.d/ipcontroller.conf:
    file.managed:
        - source: salt://ipcluster/etc/supervisor/conf.d/ipcontroller.conf
        - template: jinja
        - context:
            ipcontroller: {{ ipython_home }}/venv/bin/ipcontroller
            ipengine: {{ ipython_home }}/venv/bin/ipengine
            user: {{ ipython_user }}
            home: {{ ipython_home }}
            directory: {{ working_dir }}
            host_cpus: {{ host_cpus }}
        - user: root
        - group: root
        - require:
            - pkg: supervisor
            - pkg: python-psutil
            - pip: ipython

ipcontroller:
    supervisord:
        - running
        - name:
            - ipcontroller
            - ipengine
        - require:
            - pkg: supervisor
            - user: {{ ipython_user }}
        - watch:
            - file: /etc/supervisor/supervisord.conf
            - file: /etc/supervisor/conf.d/ipcontroller.conf
