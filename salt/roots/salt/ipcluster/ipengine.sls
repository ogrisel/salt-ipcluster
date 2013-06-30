{% set ipython_user = pillar.get('ipcluster.username', 'ipuser') %}
{% set ipython_home = pillar.get('ipcluster.userhome', '/home/ipuser') %}
{% set working_dir = ipython_home + '/notebooks' %}
{% set working_dir = pillar.get('ipcluster.engine.directory', working_dir) %}
{% set venv = ipython_home + '/venv' %}

{{ ipython_home }}/supervisor/conf.d/ipengine.conf:
    file.managed:
        - source: salt://ipcluster/etc/supervisor/conf.d/ipengine.conf
        - template: jinja
        - context:
            ipcluster: {{ venv }}/bin/ipcluster
            user: {{ ipython_user }}
            home: {{ ipython_home }}
            directory: {{ working_dir }}
        - user: root
        - group: root
        - require:
            - pkg: python-psutil
            - pip: ipcluster-venv-packages

ipengine-working-dir:
    file.directory:
        - name: {{ working_dir }}
        - user: {{ ipython_user }}
        - group: {{ ipython_user }}
        - makedirs: True
        - require:
            - user: {{ ipython_user }}
