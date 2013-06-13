scipy-stack-packages:
    pkg:
        - installed
        - names:
            - python-numpy
            - python-scipy
            - python-matplotlib
            - python-opencv


machine-learning-package:
    pip:
        - installed
        - names:
            - scikit-learn
            - pyrallel
        - require:
            - pkg: python-numpy