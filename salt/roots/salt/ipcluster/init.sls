{% set ipython_user = pillar.get('ipcluster.username', 'ipuser') %}
{% set ipython_home = pillar.get('ipcluster.userhome', '/home/ipuser') %}

# User to own the ipython process and a virtual env for the user to be able to
# install custom packages with pip / distribute

ipcluster-user:
    user.present:
        - name: {{ ipython_user }}
        - group: {{ ipython_user }}
        - home: {{ ipython_home }}
        - shell: /bin/bash

# Common packages to install on each node of the cluster

ipcluster-packages:
    pkg:
        - installed
        - names:
            - build-essential
            - python-dev
            - supervisor
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

{{ ipython_home }}/venv:
    virtualenv.managed:
        # Make it possible to reuse scipy from the OS packages as it is too
        # costly to build from source and requires many build dependencies as a
        # fortran compiler for instance
        - no_site_packages: False
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
            - export PATH=$HOME/venv/bin:$PATH

ipython:
    pip:
        - installed
        - names:
{% if not pillar.get('ipcluster.venv.packages') %}
            - ipython
            - pyzmq
            - tornado
            - jinja2
            - msgpack-python
{% endif %}
{% for pip_pkg in pillar.get('ipcluster.venv.packages', ()) %}
            - {{ pip_pkg }}
{% endfor %}
        - bin_env: {{ ipython_home }}/venv
        - user: {{ ipython_user }}
        - require:
            - pkg: build-essential
            - pkg: git
            - pkg: python-pip
            - pkg: libzmq-dev
            - pkg: python-dev
            - virtualenv: {{ ipython_home }}/venv


# Main configuration file for the supervisor service that will be used
# to manage the various ipython processes 

# TODO: move this to a dedicated state file and make it possible to install
# supervisor from pip (maybe in a venv) to be able to get the latest version
# that supports the `stopasgroup` directive for stopping ipython cluster
# engine

/etc/supervisor/supervisord.conf:
    file:
        - managed
        - source: salt://ipcluster/etc/supervisor/supervisord.conf
        - user: root
        - group: root
        - require:
            - pkg: supervisor

# if supervisor has been upragraded it might not find debian config by default

/etc/supervisord.conf:
    file.symlink:
        - target: /etc/supervisor/supervisord.conf
        - require:
            - file: /etc/supervisor/supervisord.conf
            - pkg: supervisor

supervisor:
    service:
        - running
        - require:
            - file: /etc/supervisor/supervisord.conf
            - file: /etc/supervisord.conf
            - pkg: supervisor
