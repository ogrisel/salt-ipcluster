ipython-notebook:
    pkg:
        - installed

/etc/supervisor/conf.d/ipnotebook.conf:
    file.managed:
        - source: salt://ipcluster/etc/supervisor/conf.d/ipnotebook.conf
        - template: jinja
        - user: root
        - group: root
        - require:
            - pkg: supervisor
            - pkg: ipython-notebook


ipython-notebook-process:
    service:
        - names:
            - supervisor
        - running
        - require:
            - pkg: supervisor
            - user: {{ pillar.get('ipcluster.username', 'ipuser') }}
        - watch:
            - file: /etc/supervisor/supervisor.conf
            - file: /etc/supervisor/conf.d/ipnotebook.conf