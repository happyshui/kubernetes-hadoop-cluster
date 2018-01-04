# kubernetes-hadoop-cluster

1. build docker image

`docker build -t hadoop:2.7.4 .`

2. create pv pvc

`kubectl create -f pv-hadoop-slave-0.yaml -f pv-hadoop-slave-1.yaml`

3. create hadoop master

`kubectl create -f hadoop-master.yaml`

4. create hadoop slave

```
kubectl create -f hadoop-slave.yaml
kubectl scale statefulset hadoop-slave --replicas=2
```

5. 在slave容器中添加master的主机信息（此处还未通过DNS识别）