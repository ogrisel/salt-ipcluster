{% set ipython_user = pillar.get('ipcluster.username', 'ipuser') %}
{% set ipython_home = pillar.get('ipcluster.userhome', '/home/ipuser') %}
{% set venv = ipython_home + '/venv' %}

# User to own the ipython process and a virtual env for the user to be able to
# install custom packages with pip / distribute

ipcluster-user:
    user.present:
        - name: {{ ipython_user }}
        - group: {{ ipython_user }}
        - home: {{ ipython_home }}
        - shell: /bin/bash

# Common packages to install on each node of the cluster

ipcluster-system-packages:
    pkg:
        - installed
        - names:
            - build-essential
            - python-dev
            - python-psutil
            - python-pip
            - python-virtualenv
            - libzmq-dev
            - git

# Install ipython from pip in a dedicated venv

{{ ipython_home }}:
    file.directory:
        - makedirs: True
        - user: {{ ipython_user }}
        - require:
            - user: {{ ipython_user }}

{{ venv }}:
    virtualenv.managed:
        # Make it possible to reuse scipy from the OS packages as it is too
        # costly to build from source and requires many build dependencies as a
        # fortran compiler for instance
        - system_site_packages: True
        - ignore_installed: True
        - distribute: True
        - runas: {{ ipython_user }}
        - require:
            - file: {{ ipython_home }}
            - pkg: python-virtualenv

{{ ipython_home }}/.bashrc:
    file.append:
        # Convenience for debugging only: put the venv bin folder in the path
        - text:
            - export PATH={{ venv }}/bin:$PATH

ipcluster-venv-packages:
    pip.installed:
        - names:
{% if not pillar.get('ipcluster.venv.packages') %}
            - ipython
            - pyzmq
            - tornado
            - jinja2
            - msgpack-python
            - supervisor
{% endif %}
{% for pip_pkg in pillar.get('ipcluster.venv.packages', ()) %}
            - {{ pip_pkg }}
{% endfor %}
        - bin_env: {{ venv }}
        - user: {{ ipython_user }}
        - require:
            - pkg: build-essential
            - pkg: git
            - pkg: python-pip
            - pkg: libzmq-dev
            - pkg: python-dev
            - virtualenv: {{ venv }}


# Main configuration file for the supervisor daemon that will be used
# to manage the various ipython processes 


{{ ipython_home }}/supervisor:
    file.directory:
        - makedirs: True
        - user: {{ ipython_user }}
        - group: {{ ipython_user }}
        - require:
            - user: {{ ipython_user }}
            - file: {{ ipython_home }}

{{ ipython_home }}/supervisor/conf.d:
    file.directory:
        - user: {{ ipython_user }}
        - group: {{ ipython_user }}
        - require:
            - user: {{ ipython_user }}
            - file: {{ ipython_home }}/supervisor

{{ ipython_home }}/supervisor/supervisord.conf:
    file.managed:
        - source: salt://ipcluster/etc/supervisor/supervisord.conf
        - template: jinja
        - context:
            directory: {{ ipython_home }}/supervisor
        - user: {{ ipython_user }}
        - group: {{ ipython_user }}
        - require:
            - user: {{ ipython_user }}
            - file: {{ ipython_home }}/supervisor/conf.d

/etc/init.d/supervisor-ipcluster:
    file.managed:
        - source: salt://ipcluster/etc/init.d/supervisor-ipcluster
        - template: jinja
        - context:
            venv: {{ venv }}
            directory: {{ ipython_home }}/supervisor
            conf_file: {{ ipython_home }}/supervisor/supervisord.conf
        - user: root
        - group: root
        - mode: 755
        - require:
            - user: {{ ipython_user }}
            - file: {{ ipython_home }}
            - pip: ipcluster-venv-packages

supervisor-ipcluster:
    service.running:
        - reload: True
        - require:
            - file: /etc/init.d/supervisor-ipcluster
            - file: {{ ipython_home }}/supervisor/supervisord.conf
            - pip: ipcluster-venv-packages
        - watch:
            - file: {{ ipython_home }}/supervisor/conf.d/*
