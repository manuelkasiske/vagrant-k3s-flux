# Get The Environment Up And Running
```sh
vagrant up --provision
```

# Login To Follow Flux Installation
```sh
vagrant ssh k3s1.devel
```

# Install flux


## Adding CRD Description

```sh
helm repo add fluxcd https://fluxcd.github.io/flux
kubectl apply -f https://raw.githubusercontent.com/fluxcd/flux/master/deploy-helm/flux-helm-release-crd.yaml
```

## Adding A Repository Controlled By Flux
```sh
cat << EOF > flux-get-started.sh
helm upgrade -i flux \
--set helmOperator.create=true \
--set helmOperator.createCRD=false \
--set git.url=git@github.com:manuelkasiske/flux-example-project \
--namespace flux \
fluxcd/flux
EOF
chmod +x flux-get-started.sh
```

### Watch Flux Pods
```sh
kubectl -n flux get pods
```

# install fluxctl
```sh
curl -SsL -o /usr/local/bin/fluxctl https://github.com/fluxcd/flux/releases/download/1.13.2/fluxctl_linux_amd64
chmod +x /usr/local/bin/fluxctl
echo "export FLUX_FORWARD_NAMESPACE=flux" >> /root/.bashrc
source /root/.bashrc
```

## List The Workloads
```sh
fluxctl list-workloads --all-namespaces
```

# Create Access To Example Git Repository By Creating An Access Key
```sh
fluxctl identity --k8s-fwd-ns flux
```
Apply this key as git access key for example repository!


Wait a few minute to get it synched automatically - or just type 

```sh
fluxctl sync
```

To find out which workloads are managed by flux run:

```sh
fluxctl list-workloads -a
```

To find out which images are available for podinfo run:

```sh
fluxctl list-images -w demo:deployment/podinfo
```

To upgrade the version of podinfo to 1.4 type 
```sh
fluxctl policy -w demo:deployment/podinfo --tag-all='1.4.*'
```

At this point flux will upgrade the version in the deployment yaml file and will 
automatically run the deployment.

If a release doesn't work, we can lock it by:
```sh
fluxctl lock -w demo:deployment/podinfo -m "1.4.2 does not work for us"
```

After that we can rollback to an older version by:
```sh
fluxctl release --force --workload demo:deployment/podinfo -i stefanprodan/podinfo:1.4.1
```

To see, what flux is doing just type:
```sh
kubectl logs -n default deploy/flux -f
```

# Sources

[https://github.com/fluxcd/flux-get-started]
[https://github.com/fluxcd/flux]
[https://github.com/fluxcd/flux/releases/tag/1.13.2]
[https://github.com/fluxcd/flux/blob/master/site/fluxctl.md#linux]
[https://github.com/fluxcd/flux/blob/master/site/annotations-tutorial.md]
[https://github.com/fluxcd/flux/blob/master/site/helm-get-started.md]

