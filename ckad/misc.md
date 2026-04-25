# [Encrypting Secret Data at Rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/)

- check the stored secret in 'minikube'
    - install etcdctl
        - sudo apt update
        - sudo apt install etcd-client

        ```bash
        minikube ssh

        cd /etc/kubernetes/manifests/

        sudo apt-get install bsdmainutils

        sudo ETCDCTL_API=3 etcdctl --cacert=/var/lib/minikube/certs/etcd/ca.crt   --cert=/var/lib/minikube/certs/etcd/server.crt --key=/var/lib/minikube/certs/etcd/server.key  get /registry/secrets/default/my-secret | hexdump -C

