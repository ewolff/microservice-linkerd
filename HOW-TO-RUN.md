# How to Run

This is a step-by-step guide how to run the example:

## Installation Minikube

* Install
[minikube](https://github.com/kubernetes/minikube/releases). Minikube
is a Kubernetes environment in a virtual machine that is easy to use
and install. It is not meant for production but to test Kubernetes or
for developer environments.

* Create a Minikube instance with `minikube start --cpus=2 --memory=5000`. This
  will set the memory of the Kubernetes VM to 6.000 MB - which should
  be enough for most experiments. You might want to adjust the number of CPUs
  depending on your local machine. Please make sure that you deleted any pre-existing 
  minikube instance using `minikube delete` as the memory and cpu values would otherwise have no effect. 

```
[~/microservice-linkerd]minikube start --cpus=2 --memory=5000
Starting local Kubernetes v1.12.4 cluster...
Starting VM...
Getting VM IP address...
Moving files into cluster...
Setting up certs...
Connecting to cluster...
Setting up kubeconfig...
Starting cluster components...
Kubectl is now configured to use the cluster.
```

* Install [kubectl](https://kubernetes.io/docs/tasks/kubectl/install/). This
  is the command line interface for Kubernetes.

## Installation Google Cloud

* Go to the [Kubernetes Engine Page](https://console.cloud.google.com/projectselector/kubernetes?_ga=2.66966445.-2058400183.1547494992)

* Create or select a project for this demo.

Note: You can do the installation and all other steps in the [Google
Cloud Shell](https://cloud.google.com/shell/docs/). The Google Cloud
Shell provides access to a Linux system. That way there is no need to
install any software on the local machine, just a modern web browser
is enough.

Otherwise you need to install the [Google Cloud
SDK](https://cloud.google.com/sdk/docs/quickstarts) and
[kubectl](https://kubernetes.io/docs/tasks/kubectl/install/).

* Select the project from the Kubernetes Engine Page with `gcloud
  config set project <project name>`

* Choose a data center e.g. in Frankfurt `gcloud config set
  compute/zone europe-west3-a`
  
* Define the `PROJECT_ID` by doing `export PROJECT_ID="$(gcloud config
  get-value project -q)"`
  
* Configure Docker `gcloud auth configure-docker`

* Create a cluster with `gcloud container clusters create
  hello-cluster --num-nodes=3`
  
* Assign the rights needed for the installation of linkerd to yourself:
  `kubectl create clusterrolebinding cluster-admin-binding
  --clusterrole=cluster-admin --user=$(gcloud config get-value
  core/account)`
  
## Install Traefik Ingress Controller (optional)

To access the services more easily, you can install an Traefik Ingress
Controller.  The [Traefik Installation
Guide](https://docs.traefik.io/getting-started/install-traefik/)
explains this in detail. For Kubernetes the [installation using
Helm](https://docs.traefik.io/getting-started/install-traefik/#use-the-helm-chart)
might be the best option.  Traefik will listen on port 80 unless you
changed the port by modifying the value for `ports.web.exposedPort`.

## Install Linkerd

This and all following steps are either done in the command line
(Minikube / Google Cloud) or the Google Cloud Shell.

* [Install](https://linkerd.io/2/getting-started/) Linkerd. 
* Check that the Linkerd install was successful: `linkerd check`

## Add Linkerd Proxies

To use Linkerd, all network traffic must go through a proxy. These
proxies are injected if the namespace is annotated accordingly. Use
this command:

```
kubectl annotate namespace default linkerd.io/inject=enabled
```


## Build the Docker images

This step is optional. You can skip this part and
proceed to "Run the Containers".

* The example is implemented in Java. See
   https://www.java.com/en/download/help/download_options.xml about how
   to download Java. The
   examples need to be compiled so you need to install a JDK (Java
   Development Kit). A JRE (Java Runtime Environment) is not
   sufficient. After the installation you should be able to execute
   `java` and `javac` on the command line.
   You need at least Java 10. In the Google Cloud Shell, use `sudo
   update-java-alternatives -s java-1.11.0-openjdk-amd64 && export
   JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64` to select Java 11.

* The example run in Docker Containers. You need to install Docker
  Community Edition, see https://www.docker.com/community-edition/
  . You should be able to run `docker` after the installation.

Change to the directory `microservice-linkerd-demo` and run `./mvnw clean
package` (macOS / Linux) or `mvnw.cmd clean package` (Windows). This will take a while:

```
[~/microservice-linkerd/microservice-linkerd-demo]./mvnw clean package
....
[INFO] 
[INFO] --- maven-jar-plugin:2.6:jar (default-jar) @ microservice-linkerd-order ---
[INFO] Building jar: /Users/wolff/microservice-linkerd/microservice-linkerd/microservice-linkerd-order/target/microservice-linkerd-order-0.0.1-SNAPSHOT.jar
[INFO] 
[INFO] --- spring-boot-maven-plugin:1.4.5.RELEASE:repackage (default) @ microservice-linkerd-order ---
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary:
[INFO] 
[INFO] microservice-linkerd ....................... SUCCESS [  0.986 s]
[INFO] microservice-linkerd-invoicing .............. SUCCESS [ 16.953 s]
[INFO] microservice-linkerd-shipping ............... SUCCESS [ 18.016 s]
[INFO] microservice-linkerd-order ................. SUCCESS [ 18.512 s]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 57.633 s
[INFO] Finished at: 2017-09-08T09:36:32+02:00
[INFO] Final Memory: 56M/420M
[INFO] ------------------------------------------------------------------------
```

If this does not work:

* Ensure that `settings.xml` in the directory `.m2` in your home
directory contains no configuration for a specific Maven repo. If in
doubt: delete the file.

* The tests use some ports on the local machine. Make sure that no
server runs in the background.

* Skip the tests: `./mvnw clean package -Dmaven.test.skip=true` or
  `mvnw.cmd clean package -Dmaven.test.skip=true` (Windows).

* In rare cases dependencies might not be downloaded correctly. In
  that case: Remove the directory `repository` in the directory `.m2`
  in your home directory. Note that this means all dependencies will
  be downloaded again.

Now the Java code has been compiled. The next step is to create Docker
images:

* Minkube only: Configure Docker so that it uses the Kubernetes cluster. This is
required to install the
Docker images: `minikube docker-env`(macOS / Linux) or `minikube.exe docker-env`(Windows) tells you how to do that. 

* Minikube only: Afterwards you should see the Docker images of Kubernetes if you do `docker images`:

```
[~/microservice-linkerd/microservice-linkerd]docker images
REPOSITORY                                TAG                 IMAGE ID            CREATED             SIZE
k8s.gcr.io/kubernetes-dashboard-amd64     v1.10.1             f9aed6605b81        3 weeks ago         122MB
k8s.gcr.io/kube-proxy                     v1.12.4             6d393e89739f        3 weeks ago         96.5MB
k8s.gcr.io/kube-apiserver                 v1.12.4             c04b373449d3        3 weeks ago         194MB
k8s.gcr.io/kube-controller-manager        v1.12.4             51b2a8e5ff78        3 weeks ago         164MB
k8s.gcr.io/kube-scheduler                 v1.12.4             c1b5e63c0b56        3 weeks ago         58.4MB
k8s.gcr.io/etcd                           3.2.24              3cab8e1b9802        3 months ago        220MB
k8s.gcr.io/coredns                        1.2.2               367cdc8433a4        4 months ago        39.2MB
grafana/grafana                           5.2.3               17a5ba3b1216        4 months ago        245MB
prom/prometheus                           v2.3.1              b82ef1f3aa07        6 months ago        119MB
jaegertracing/all-in-one                  1.5                 93f16463fee4        7 months ago        48.4MB
k8s.gcr.io/kube-addon-manager             v8.6                9c16409588eb        10 months ago       78.4MB
k8s.gcr.io/pause                          3.1                 da86e6ba6ca1        12 months ago       742kB
gcr.io/k8s-minikube/storage-provisioner   v1.8.1              4689081edb10        14 months ago       80.8MB
quay.io/coreos/hyperkube                  v1.7.6_coreos.0     2faf6f7a322f        15 months ago       699MB
```

* Run `docker-build.sh` in the directory
`microservice-linkerd-demo`. It builds the Docker images.

```
[~/microservice-linkerd/microservice-linkerd-demo]./docker-build.sh 
...
Successfully tagged microservice-linkerd-invoicing:latest
Sending build context to Docker daemon  47.88MB
Step 1/4 : FROM openjdk:11.0.2-jre-slim
 ---> 4bd06752ac4a
Step 2/4 : COPY target/microservice-linkerd-order-0.0.1-SNAPSHOT.jar .
 ---> 31d666e6ecab
Step 3/4 : CMD /usr/bin/java -Xmx400m -Xms400m -jar microservice-linkerd-order-0.0.1-SNAPSHOT.jar
 ---> Running in 6a3aafef3449
Removing intermediate container 6a3aafef3449
 ---> a83eb4e8a9fe
Step 4/4 : EXPOSE 8080
 ---> Running in 5054a949c575
Removing intermediate container 5054a949c575
 ---> b60004d121e5
Successfully built b60004d121e5
Successfully tagged microservice-linkerd-order:latest
```

* Sometime pulling the images does not work. Try `docker logout` then
  and rerun the script.

* The images should now be available:

```
[~/microservice-linkerd/microservice-linkerd-demo]docker images
REPOSITORY                                TAG                 IMAGE ID            CREATED              SIZE
microservice-linkerd-order             latest              b60004d121e5        About a minute ago   342MB
microservice-linkerd-invoicing          latest              287e662e8111        About a minute ago   342MB
microservice-linkerd-shipping           latest              3af9dd80a8ee        About a minute ago   342MB
microservice-linkerd-apache            latest              eff5fd508880        About a minute ago   240MB
microservice-linkerd-postgres          latest              deadbeef8880        About a minute ago   42MB
...
```

* Google Cloud only: Upload the images to the Google Cloud with `./docker-push-gcp.sh`


## Run the Containers

* If you have build the Docker images yourself and use Google Cloud: 
  Modify the YAML files to load the Docker images
from the Google Docker repo with `fix-microservices-gcp.sh`
* If you haven't built the Docker container yourself, run
  `fix-microservices-dockerhub.sh`. The Docker images will be
  downloaded from the Docker Hub in the Internet then.
* Deploy the infrastructure for the microservices using `kubectl` in
  the directory
  `microservice-kubernetes-demo`.
  Use `infrastructure-gcp.yaml` instead of `infrastructure.yaml` if you
  if you built and uploaded the images to Google Cloud. 
  Use `infrastructure-dockerhub.yaml` if you haven't
  built the Docker container yourself:

```
[~/microservice-linkerd/microservice-linkerd-demo]kubectl apply -f infrastructure.yaml
deployment.apps/apache created
deployment.apps/postgres created
service/apache created
service/postgres created
gateway.networking.linkerd.io/microservice-gateway created
virtualservice.networking.linkerd.io/apache created
```


* Deploy the microservices using `kubectl`.
  Use `microservices-gcp.yaml` instead of `microservices.yaml` if you
  if you built and uploaded the images to Google Cloud. 
  Use `microservices-dockerhub.yaml` if you haven't
  built the Docker container yourself:

```
[~/microservice-linkerd/microservice-linkerd-demo]kubectl apply -f microservices.yaml
deployment.apps/invoicing created
deployment.apps/shipping created
deployment.apps/order created
service/invoicing created
service/shipping created
service/order created
virtualservice.networking.linkerd.io/shipping created
virtualservice.networking.linkerd.io/invoicing created
virtualservice.networking.linkerd.io/order created
```

The script creates Pods based on the Docker images created
before. Pods might
contain one or
many Docker containers. In this case, each Pod contains one
Docker container with the microservice and another one with linkerd
infrastructure is created automatically.

Note: The Postgres installation is very limited i.e. it is not ensured
that data survives restarts or changes in the cluster. However, for a demo
this should be enough and it simplifies the setup.

Also Kubernetes services are created. Services have a clusterwide unique IP
address and a DNS entry. Service can use many Pods to do load
balancing. To actually view the services:

* Run `kubectl get services` to see all services:

```
[~/microservice-linkerd/microservice-linkerd-demo]kubectl get services
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
apache       NodePort    10.31.244.219   <none>        80:30798/TCP     29m
invoicing    NodePort    10.31.249.73    <none>        80:32105/TCP     2m34s
kubernetes   ClusterIP   10.31.240.1     <none>        443/TCP          80m
order        NodePort    10.31.241.103   <none>        80:30426/TCP     2m33s
postgres     NodePort    10.31.252.0     <none>        5432:31520/TCP   29m
shipping     NodePort    10.31.251.213   <none>        80:31754/TCP     2m34s
```


* Run `kubectl describe service` for more
  details. This also works for pods (`kubectl describe pod`) and
  deployments (`kubectl describe deployment`).

```
[~/microservice-linkerd/microservice-linkerd-demo]kubectl describe service order
Name:                     order
Namespace:                default
Labels:                   run=order
                          visualize=true
Annotations:              kubectl.kubernetes.io/last-applied-configuration:
                            {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"creationTimestamp":null,"labels":{"run":"order","visualize":"true"},"nam...
Selector:                 run=order,serving=true
Type:                     NodePort
IP:                       10.109.230.95
Port:                     http  8080/TCP
TargetPort:               8080/TCP
NodePort:                 http  32182/TCP
Endpoints:                172.17.0.20:8080
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>kubectl describe services
```

* You can also get a list of the pods:

```
[~/microservice-linkerd/microservice-linkerd-demo]kubectl get pods
NAME                        READY   STATUS    RESTARTS   AGE
apache-7f7f7f79c6-jbqx8      1/1     Running   0          8m51s
invoicing-77f69ff854-rpcbk   1/1     Running   0          8m43s
order-cc7f8866-9zbnf         1/1     Running   0          8m43s
postgres-5ddddbbf8f-xfng5    1/1     Running   0          8m51s
shipping-5d58798cdd-9jqj8    1/1     Running   0          8m43s
```

* ...and you can see the logs of a pod:

```
~/microservice-linkerd/microservice-linkerd-demo$ kubectl logs order-cc7f8866-9zbnf order 

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.0.6.RELEASE)

2019-01-17 16:56:30.909  INFO 6 --- [           main] com.ewolff.microservice.order.OrderApp   : Starting OrderApp v0.0.1-SNAPSHOT on order-cc7f8866-9zbnf with PID 6 (/microservice-linkerd-order-0.0.1-SNAPSHOT.jar started by root in /)
2019-01-17 16:56:30.918  INFO 6 --- [           main] com.ewolff.microservice.order.OrderApp   : No active profile set, falling back to default profiles: default
2019-01-17 16:56:31.200  INFO 6 --- [    es-writer-1] es-logger                                : {"index":{"_index":"logs-2019-01-17","_type":"tester"}}
{"@timestamp":"2019-01-17T16:56:30.909+0000","message":"Starting OrderApp v0.0.1-SNAPSHOT on order-cc7f8866-9zbnf with PID 6 (/microservice-linkerd-order-0.0.1-SNAPSHOT.jar started by root in /)","host":"order-cc7f8866-9zbnf","severity":"INFO","thread":"main","logger":"com.ewolff.microservice.order.OrderApp"}
{"index":{"_index":"logs-2019-01-17","_type":"tester"}}
{"@timestamp":"2019-01-17T16:56:30.918+0000","message":"No active profile set, falling back to default profiles: default","host":"order-cc7f8866-9zbnf","severity":"INFO","thread":"main","logger":"com.ewolff.microservice.order.OrderApp"}
...
```

* You can also run commands in a pod:

```
[~/microservice-linkerd/microservice-linkerd-demo]kubectl exec order-cc7f8866-9zbnf /bin/ls
Defaulting container name to order.
Use 'kubectl describe pod/order-cc7f8866-9zbnf -n default' to see all of the containers in this pod.
bin
boot
dev
docker-java-home
etc
home
lib
lib32
lib64
libx32
media
microservice-linkerd-order-0.0.1-SNAPSHOT.jar
mnt
opt
proc
root
run
sbin
srv
sys
tmp
usr
var
```

* You can even open a shell in a pod:

```
[~/microservice-linkerd/microservice-linkerd-demo]kubectl exec order-cc7f8866-9zbnf -it /bin/sh
Defaulting container name to order.
Use 'kubectl describe pod/order-cc7f8866-9zbnf -n default' to see all of the containers in this pod.
# ls
bin  boot  dev	docker-java-home  etc  home  lib  lib32  lib64	libx32	media  microservice-linkerd-order-0.0.1-SNAPSHOT.jar  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
#
```

## Use the Demo

The demo is available via an Traefik Ingress that provides access to all the
services.

* Make sure the Ingress gateway works:

```
[~/microservice-linkerd/microservice-linkerd-demo] kubectl get service traefik
NAME      ...      EXTERNAL-IP   PORT(S)                      AGE

traefik   ...      localhost in     81:32720/TCP,443:32319/TCP   3h9m
```

* 

`ingress-url.sh` outputs the URL for the Ingress
  gateway.

* If you open
the Ingress URL, a static HTML page is shown which is served by the apache service.
This page has links to all other services.

* If it is not possible to access the Ingress or if the scripts show
  no valid URL, you can still use the script `ingress-forward.sh`. It
  creates a proxy to the Ingress on the local machine. The script
  prints out the URL for the proxy.

* You can execute `linkerd -n default check --proxy` to see whether
the Linkerd proxies actually work.


## Adding another Microservice

There is another microservice in the sub directory
`microservice-linkerd-bonus`. To add the microservice to your system you
can do the following:

* Change to the directory `microservice-linkerd-bonus` and run `./mvnw clean
package` (macOS / Linux) or `mvnw.cmd clean package` (Windows) to
compile the Java 
code.

* Run `docker-build.sh` in the directory
`microservice-linkerd-bonus`. It builds the Docker images and uploads them into
the Kubernetes cluster.

* Deploy the microservice with `kubectl apply -f bonus.yaml`.

* You can remove the microservice again with `kubectl delete -f bonus.yaml`.

#### Using the additonal microservice

The bonus microservice is not included in the static web page that
contains links to the other microservices. However, it can be accessed
via the Ingress gateway. If the Ingress gateway's URL is
http://192.168.99.127:31380/, you can access the bonus microservice
at http://192.168.99.127:31380/bonus.

Note that the bonus microservice does not show any revenue for the
orders. This is because it requires a field `revenue` in the data the
order microservice provides. That field is currently not included in
the data structure. This shows that adding a new microservice might
require changes to a common data structure. Such changes might also
impact the other microservices.

## Prometheus

Linkerd comes with an installation of
[Prometheus](https://prometheus.io/). It collects metrics from the
proxies of the services. This is the foundation for monitoring.

Enter `kubectl -n linkerd port-forward deployment/linkerd-prometheus
9090:9090` to create a proxy for the Prometheus service.

You can access Prometheus at http://localhost:9090/ then.
In the Google Cloud Shell you can use [Web
Preview](https://cloud.google.com/shell/docs/using-web-preview) to
open the URL from the shell in your local browser.

You can also use the shell script `monitoring-prometheus.sh`.

Metrics only make sense if there is load on the system. The shell
script `load.sh` uses the tool `curl` to request a certain URL 1,000
times. You can start one or multiple instances of this script with the
URL of the home page of the shipping microservice to create some
load on that service.

## Linkerd

Linkerd has its own dashboard that provides some information such as
the deployed resources, namespaces etc. You can use `linkerd
dashboard` to create a proxy to the dashboard and access it under the
provided URL. In particular "Top", "Tap", and "Routes" might be
interesting. Also the Workload includes some metrics and links to
Grafana.

You can get the data also via the command line with `linkerd
stat`. For example, `linkerd stat deploy` gives general metric for all
deployments. 

`linkerd routes`gives specific information about the metric for a
specific route between some deployments. For example, `linkerd routes
deploy/shipping --to service/order` shows the metrics for the
communication between the shipping and the order microservice for
polling new orders.

## Grafana

Prometheus has only very limited dashboards. Therefore linkerd comes
with an installation of [Grafana](https://grafana.com/) that provides
much better graphs and dashboards.

`linkerd dashboard` also provides access to the Grafana dashboard. So
you can use the URL provided by the command to access Grafana.

You can find information about the deployments in the Linkerd
Deployment dashboard. 

## Logging

Linkerd support logging of web traffic with its [tap
feature](https://linkerd.io/2/reference/cli/tap/). For the example,
you can use e.g. `linkerd tap deploy/order` to log any traffic to the
order microservice.

## Security

Linkerd encrpyts the communication between the pods. You can verify
this with `linkerd edges deployment`. It should show that all
communication is secured. You can also use `linkerd tap deploy` to see
for each network communication whether it is encrypted with TLS or not.

## Fault Injection

Linkerd provides feature to split traffic between different
backends. That can be used to inject faults into a route between two
services. That makes it possible to test the system's resilience.
`fault-injection.yaml` adds an nginx instance to the system that will
always respond with an HTTP 500 error code. It also splits the traffic
between the original service and the nginx instance. That way, 50% of
all requests hit the nginx service and receive an error.  You can add
the configuration to the system with `kubectl apply -f
fault-injection.yaml` . If you make the shipping or invoicing
microservices poll new information from the order microservice now,
ends in an error in 50% of the cases.

`linkerd stat deploy` will say that the order deployment still works
flawlessly. However, `linkerd routes deploy/shipping --to
service/order` will show that some calls to the service fail. However,
`linkerd routes deploy/shipping --to service/order -o wide` provides
even more information.

To remove the fault injection again, just use `kubectl delete -f
fault-injection.yaml`.

## Timeout

Linkerd adds timeouts to all services. However, the default timeout is
10 seconds and usually services will answer much quicker. If you use
`kuberctl apply -f timeout.yaml` a timeout of 3ms will be set for GET
operations to `/order/feed` on the order microservice. You can now
create some load with `./load.sh "-X POST
http://localhost:80/shipping/poll"` . Quite a few of the calls will
fail now as the order microservice does not respond fast
enough. `linkerd routes deploy/shipping --to service/order -o wide`
provides more detailed statistics.



## Retries

Use `kubectl apply -f failing-order-service.yaml` to deploy a version
of the order microservice that answers 50% of all requests with an
http status code of 500.  Use `failing-order-service-gcp.yaml` instead
of `failing-order-service.yaml` if you build and uploaded images to
Google Cloud. Use `failing-order-service-dockerhub.yaml` if you
haven't built the Docker container yourself.

If you access the order microservice's web UI or if you make shipping
and invoicing poll the order microservice, you will likely receive an
error.

With `kubectl apply -f retry.yaml` you can make linkerd retry requests
to the order service. The configuration adds retries to the
communication between the microservices as well as the access through
the Ingress gateway. So polling and the web UI will both work again.

Linkerd uses a retry budget. It allows for at least 10 retures per
second but at max 20% additional load due to retries. That way retries
won't overload the system. Also retries are limit to HTTP GET
operations. GET is ensured to be idempotent so it is safe to retry
them. That is different for POSTs.

You can remove the retries with `kubectl delete -f retry.yaml`. The
failing microservice can be set to normal with `kubectl apply -f
microservices.yaml`.

## Clean Up

* To remove all services and deployments run `kubectl  delete -f microservices.yaml`:

```
[~/microservice-linkerd/microservice-linkerd-demo] kubectl delete -f microservices.yaml
deployment.apps "catalog" deleted
deployment.apps "customer" deleted
deployment.apps "order" deleted
service "catalog" deleted
service "customer" deleted
service "order" deleted
virtualservice.networking.linkerd.io "customer" deleted
virtualservice.networking.linkerd.io "catalog" deleted
virtualservice.networking.linkerd.io "order" deleted
```

* Then remove the infrastructure - run `kubectl  delete -f
  infrastructure.yaml`:

```
[~/microservice-linkerd/microservice-linkerd-demo]kubectl  delete -f infrastructure.yaml
deployment.apps "apache" deleted
service "apache" deleted
gateway.networking.linkerd.io "microservice-gateway" deleted
virtualservice.networking.linkerd.io "apache" deleted
```
