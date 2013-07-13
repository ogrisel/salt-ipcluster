salt-ipcluster
==============

[SaltStack](http://docs.saltstack.com) states to setup an IPython cluster.

Status: single machine provisioning can start IPython notebook,
        controller and engines

TODO:

- cluster mode with pre-allocated minion keys for the workers
- setup SSH-FS or NFS shared folder between master and workers
- debugging and documentation
- salt-cloud integration for testing on EC2, Rackspace, Google Compute Engine
  and soon Microsoft Azure.
