{% set ipython_user = pillar.get('ipcluster.username', 'ipuser') %}
{% set ipython_home = pillar.get('ipcluster.userhome', '/home/ipuser') %}

# User to own the ipython process and a virtual env for the user to be able to
# install custom packages with pip / distribute

ipcluster-user:
    user.present:
        - name: {{ ipython_user }}
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
            - ipython
            - pyzmq
            - tornado
        - bin_env: {{ ipython_home }}/venv
        - user: {{ ipython_user }}
        - require:
            - pkg: build-essential
            - pkg: python-pip
            - pkg: libzmq-dev
            - pkg: python-dev
            - virtualenv: {{ ipython_home }}/venv

# TODO: if pillar has a requirement file, add it here


# Main configuration file for the supervisor service that will be used
# to manage the various ipython processes 

/etc/supervisor/supervisord.conf:
    file:
        - managed
        - source: salt://ipcluster/etc/supervisor/supervisord.conf
        - user: root
        - group: root
        - require:
            - pkg: supervisor

supervisor:
    service:
        - running
        - require:
            - file: /etc/supervisor/supervisord.conf
            - pkg: supervisor
