ipcluster-user:
    user.present:
        - name: {{ pillar.get('ipcluster.username', 'ipuser') }}

# Common packages to install on each node of the cluster
ipcluster-packages:
    pkg:
        - installed
        - names:
            - ipython
            - supervisor
            - python-psutil

/etc/supervisor/supervisord.conf:
    file:
        - managed
        - source: salt://ipcluster/etc/supervisor/supervisord.conf
        - user: root
        - group: root
        - require:
            - pkg: supervisor