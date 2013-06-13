{% set ipython_user = pillar.get('ipcluster.username', 'ipuser') %}
{% set ipython_home = pillar.get('ipcluster.userhome', '/home/ipuser') %}
{% set working_dir = ipython_home + '/notebooks' %}
{% set working_dir = pillar.get('ipcluster.notebook.directory', working_dir) %}
{% set notebook_port = pillar.get('ipcluster.notebook.port', '8888') %}
{% set venv = ipython_home + '/venv' %}

# Configure the supervisor service to manage the ipython notebook process

{{ ipython_home }}/supervisor/conf.d/ipnotebook.conf:
    file.managed:
        - source: salt://ipcluster/etc/supervisor/conf.d/ipnotebook.conf
        - template: jinja
        - context:
            ipython: {{ venv }}/bin/ipython
            user: {{ ipython_user }}
            home: {{ ipython_home }}
            port: {{ notebook_port }}
            directory: {{ working_dir }}
        - user: root
        - group: root
        - require:
            - pkg: supervisor
            - pip: ipython

notebook-working-dir:
    file.directory:
        - name: {{ working_dir }}
        - user: {{ ipython_user }}
        - mode: 755
        - makedirs: True

ipnotebook:
    supervisord.running:
        - bin_env: {{ venv }}
        - conf_file: {{ ipython_home }}/supervisor/supervisord.conf
        - require:
            - pip: supervisor
            - user: {{ ipython_user }}
            - file: {{ working_dir }}
        - watch:
            - file: {{ ipython_home }}/supervisor/supervisord.conf
            - file: {{ ipython_home }}/supervisor/conf.d/ipcontroller.conf

