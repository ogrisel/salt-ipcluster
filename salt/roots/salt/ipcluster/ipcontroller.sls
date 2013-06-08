/etc/supervisor/conf.d/ipcontroller.conf:
    file:
        - managed
        - source: salt://ipcluster/etc/supervisor/conf.d/ipcontroller.conf
        - user: root
        - group: root
        - require:
            - pkg: supervisor
            - pkg: ipython
