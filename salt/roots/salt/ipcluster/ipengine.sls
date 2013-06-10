/etc/supervisor/conf.d/ipengine.conf:
    file.managed:
        - source: salt://ipcluster/etc/supervisor/conf.d/ipengine.conf
        - template: jinja
        - user: root
        - group: root
        - require:
            - pkg: supervisor
            - pkg: ipython
            - pkg: python-psutil

ipengine-process:
    service:
        - names:
            - supervisor
        - running
        - require:
            - pkg: supervisor
            - user: {{ pillar.get('ipcluster.username', 'ipuser') }}
        - watch:
            - file: /etc/supervisor/conf.d/ipengine.conf