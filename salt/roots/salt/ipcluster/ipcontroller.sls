{% set ipython_user = pillar.get('ipcluster.username', 'ipuser') %}
{% set ipython_home = pillar.get('ipcluster.userhome', '/home/ipuser') %}
{% set working_dir = ipython_home + '/notebooks' %}
{% set working_dir = pillar.get('ipcluster.engine.directory', working_dir) %}
{% set venv = ipython_home + '/venv' %}

{{ ipython_home }}/supervisor/conf.d/ipcontroller.conf:
    file.managed:
        - source: salt://ipcluster/etc/supervisor/conf.d/ipcontroller.conf
        - template: jinja
        - context:
            ipcontroller: {{ venv }}/bin/ipcontroller
            ipcluster: {{ venv }}/bin/ipcluster
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
    supervisord.running:
        - bin_env: {{ venv }}
        - conf_file: {{ ipython_home }}/supervisor/supervisord.conf
        - names:
            - ipcontroller
            - ipengine
        - require:
            - pip: supervisor
            - user: {{ ipython_user }}
            - file: {{ working_dir }}
        - watch:
            - file: {{ ipython_home }}/supervisor/supervisord.conf
            - file: {{ ipython_home }}/supervisor/conf.d/ipcontroller.conf
