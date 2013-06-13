# Example pillar configuration to customize the behavior of the ipcluster
# states

# Customize name of the unix user and the filesystem location
#
#ipcluster.username: ipcluster
#ipcluster.userhome: /opt/ipcluster

# Working directories for the main IPython processes
#
#ipcluster.notebook.directory: /opt/ipcluster/notebooks
#ipcluster.engine.directory: /opt/ipcluster/notebooks

# The following makes it possible to change the list of the default python
# packages installed the ipython cluster user virtualenv. In particular
# This demonstrates how to use the master branch of the IPython project
# instead of the latest stable release.
# It is also possible to use @deadbeafcafebabe instead of @master to get a
# fixed specific revision from a git repo.
#
#ipcluster.venv.packages:
#    - git+https://github.com/ipython/ipython.git@master
#    - pyzmq
#    - tornado
#    - jinja2
#    - msgpack-python
#    - supervisor

# Note: to install additional packages it is recommended to create a new
# custom salt state file and reference it from your own top.sls state.
