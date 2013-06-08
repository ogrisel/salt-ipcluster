scipy-stack-packages:
    pkg:
        - installed
        - names:
            - python-numpy
            - python-scipy
            - python-matplotlib

/etc/supervisor/conf.d/ipengine.conf:
    file:
        - managed
        - source: salt://ipcluster/etc/supervisor/conf.d/ipengine.conf
        - user: root
        - group: root
        - require:
            - pkg: supervisor
            - pkg: ipython