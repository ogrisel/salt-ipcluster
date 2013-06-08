# Common packages to install on each node of the cluster
ipcluster-packages:
    pkg:
        - installed
        - names:
            - ipython
            - supervisor

/etc/supervisor/supervisor.conf:
    file:
        - managed
        - source: salt://ipcluster/etc/supervisor/supervisor.conf
        - user: root
        - group: root
        - require:
            - pkg: supervisor