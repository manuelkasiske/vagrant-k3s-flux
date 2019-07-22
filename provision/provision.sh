#!/usr/bin/env bash

#apt update && apt install -y netselect-apt
#netselect-apt $(lsb_release -cs)
#mv sources.list /etc/apt/
#apt update

# install k3s
apt update && apt -y upgrade
apt install -y vim
curl -sfL https://get.k3s.io | sh -
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> /home/root/.bashrc

# install docker
apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable"
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
apt update
apt install -y docker-ce

# install helm

curl -LO https://git.io/get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
cat << EOF > rbac-config.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF
kubectl apply -f rbac-config.yaml
helm init --service-account tiller

# delete default traefik
cd /var/lib/rancher/k3s/server/manifests/
kubectl delete -f traefik.yaml

kubectl get all --all-namespaces
