# Beispiel starten

Die ist eine Schritt-für-Schritt-Anleitung zum Starten der Beispiele.
Informationen zu Maven und Docker finden sich im
[Cheatsheet-Projekt](https://github.com/ewolff/cheatsheets-DE).


## Installation Minikube

* Installiere
[minikube](https://github.com/kubernetes/minikube/releases). Minikube
bietet eine Kubernetes-Umgebung in einer virtuellen Maschine. Minikube
ist einfach zu benutzen und zu installieren. Es soll keine
Produktionsumgebung sein, sondern dient nur dazu, Kubernetes
auszuprobieren oder Entwicklermaschinen aufzubauen.


* Installiere eine Minikube-Instanz mit `minikube start --cpus=2
--memory=5000`. Die Instanz hat dann 5.000 MB RAM. Das sollte für das
Beispiel ausreichend sein. Die Anzahl der CPUs kann je nach genutzter
Hardware geändert werden. Lösche vor der Installation gegebenenfalls
bereits vorhandene Minikube-Instanzen mit `minikube delete`, da
Minikube anderenfalls die Einstellungen für Speicher und CPU nicht
beachtet.

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

* Installiere
  [kubectl](https://kubernetes.io/docs/tasks/kubectl/install/). Das
  ist das Kommandozeilenwerkzeug für den Umgang mit Kubernetes.

## Installation Google Cloud

* Registriere Dich bei der [Google Cloud](https://cloud.google.com/).

* Gehe zur [Kubernetes Engine Page](https://console.cloud.google.com/projectselector/kubernetes)

* Erzeuge ein Projekt oder wähle eines aus.

Hinweis: Die Installation und alle folgende Schritte kann man in der
[Google Cloud Shell](https://cloud.google.com/shell/docs/)
durchführen.  Die Google Cloud Shell bietet Zugriff auf ein
Linux-System. Daher ist es nicht notwendig, Software auf der lokalen
Maschine zu installieren. Ein Web Browser ist völlig ausreichend.

Sonst muss das [Google Cloud
 SDK](https://cloud.google.com/sdk/docs/quickstarts) und
 [kubectl](https://kubernetes.io/docs/tasks/kubectl/install/)
 installiert werden.

* Logge Dich mit `gcloud auth login <EMail-Adresse>` bei der Google
  Cloud ein.

* Wähle das Projekt aus der Kubernetes Engine Page mit `gcloud
  config set project <projekt name>` aus.

* Wähle ein Rechenzentrum, z.B. das in Frankfurt: `gcloud config set
  compute/zone europe-west3-a`
  
* Definiere die `PROJECT_ID` mit `export PROJECT_ID="$(gcloud config
  get-value project -q)"`
  
* Konfiguriere Docker `gcloud auth configure-docker`

* Erzeuge einen Cluster mit `gcloud container clusters create
  hello-cluster --num-nodes=3 --release-channel=rapid`
  
## Installation von linkerd

Dieser und die folgenden Schritte können entweder auf der
Kommandozeile (Minkube / Google Cloud) oder in der Google Cloud Shell
durchgeführt werden.

* [Installiere](https://linkerd.io/2/getting-started/) Linkerd
* Überprüfe die Linkerd-Installation: `linkerd check`

## Linkerd Proxies einfügen

Um Linkerd zu nutzen, muss der Netzwerk-Verkehr durch einen Proxy
geleitet werden. Diese Proxys werden automatisch in den
Netzwerk-Verkehr injiziert, wenn der Namespace entsprechend annotiert
ist. Nutze dieses Kommando:

```
kubectl annotate namespace default linkerd.io/inject=enabled
```

## Traefik Ingress Controller installieren

Um auf die Microservices zuzugreifen, musst Du einen Traefik Ingress
Controller installieren. Die [Traefik Installation
Guide](https://docs.traefik.io/getting-started/install-traefik/)
erläutert das im Detail. Die [Installation mit
Helm](https://docs.traefik.io/getting-started/install-traefik/#use-the-helm-chart)
ist vermutlich die beste Option.  Traefik horcht auf Port 80, außer
wenn der Port mit der Variablen `ports.web.exposedPort` folgendermaßen
modifiziert wird: `helm install --set ports.web.exposedPort=81
--namespace=traefik traefik traefik/traefik`

## Java-Code kompilieren

Dieser Schritt ist optional, wenn Minikube genutzt wird. Du kannst den
Schritt überspringen und direkt mit "Container starten" weitermachen.

* Die Beispiele sind in Java implementiert. Daher muss Java
  installiert werden. Die Anleitung findet sich unter
  https://www.java.com/en/download/help/download_options.xml . Da die
  Beispiele kompiliert werden müssen, muss ein JDK (Java Development
  Kit) installiert werden. Das JRE (Java Runtime Environment) reicht
  nicht aus. Nach der Installation sollte sowohl `java` und `javac` in
  der Eingabeaufforderung möglich sein.  Das Beispiel benötigt
  mindestens Java 11. In der Google Cloud Shell kann man Java 11 mit
  `sudo update-java-alternatives -s java-1.11.0-openjdk-amd64 &&
  export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64` auswählen.
  
* Die Beispiele laufen in Docker Containern. Dazu ist eine
  Installation von Docker Community Edition notwendig, siehe
  https://www.docker.com/community-edition/ . Docker kann mit
  `docker` aufgerufen werden. Das sollte nach der Installation ohne
  Fehler möglich sein.

Wechsel in das Verzeichnis `microservice-linkerd-demo` und starte
`./mvnw clean package` (macOS / Linux) bzw. `mvnw.cmd clean package`
(Windows). Das wird einige Zeit dauern:

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
[INFO] Finished at: 2020-08-08T09:36:32+02:00
[INFO] Final Memory: 56M/420M
[INFO] ------------------------------------------------------------------------
```
Weitere Information zu Maven gibt es im
[Maven Cheatsheet](https://github.com/ewolff/cheatsheets-DE/blob/master/MavenCheatSheet.md).

Falls es dabei zu Fehlern kommt:

* Stelle sicher, dass die Datei `settings.xml` im Verzeichnis  `.m2`
in deinem Heimatverzeichnis keine Konfiguration für ein spezielles
Maven Repository enthalten. Im Zweifelsfall kannst du die Datei
einfach löschen.

* Die Tests nutzen einige Ports auf dem Rechner. Stelle sicher, dass
  im Hintergrund keine Server laufen.

* Führe die Tests beim Build nicht aus: `./mvnw clean package
-Dmaven.test.skip=true` (macOS / Linux) bzw. `mvnw.cmd clean package
-Dmaven.test.skip=true` (Windows).

* In einigen selten Fällen kann es vorkommen, dass die Abhängigkeiten
  nicht korrekt heruntergeladen werden. Wenn du das Verzeichnis
  `repository` im Verzeichnis `.m2` löscht, werden alle Abhängigkeiten
  erneut heruntergeladen.

## Docker Images bauen

Der Java-Code ist nun kompiliert. Der nächste Schritt ist, die Docker
Images zu erstellen:

* Nur Minikube: Konfiguriere Docker so, dass es den Kubernetes Cluster nutzt. Nur so
  können die Docker Images in den Kubernetes Cluster übertragen
  werden: `minikube docker-env`(macOS / Linux) oder `minikube.exe
  docker-env`(Windows) beschreibt, wie man dafür vorgehen muss.

* Nur Minikube: Danach sollte `docker images` die Kubernetes Docker Images anzeigen:

```
[~/microservice-linkerd/microservice-linkerd]docker images
REPOSITORY                                TAG                 IMAGE ID            CREATED             SIZE
k8s.gcr.io/kubernetes-dashboard-amd64     v1.10.1             f9aed6605b81        3 weeks ago         122MB
k8s.gcr.io/kube-proxy                     v1.12.4             6d393e89739f        3 weeks ago         96.5MB
k8s.gcr.io/kube-apiserver                 v1.12.4             c04b373449d3        3 weeks ago         194MB
k8s.gcr.io/kube-controller-manager        v1.12.4             51b2a8e5ff78        3 weeks ago         164MB
k8s.gcr.io/kube-scheduler                 v1.12.4             c1b5e63c0b56        3 weeks ago         58.4MB
linkerd/sidecar_injector                    1.0.5               091fd902183a        4 weeks ago         52.9MB
linkerd/servicegraph                        1.0.5               cef5bb589599        4 weeks ago         16.5MB
linkerd/proxyv2                             1.0.5               e393f805ceac        4 weeks ago         380MB
linkerd/pilot                               1.0.5               68f5cc3a87ff        4 weeks ago         313MB
linkerd/mixer                               1.0.5               582d5c76010e        4 weeks ago         70MB
linkerd/galley                              1.0.5               e35efbcb45ed        4 weeks ago         73.1MB
linkerd/citadel                             1.0.5               3e6285f52cd0        4 weeks ago         56.1MB
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

* Starte `docker-build.sh` im Verzeichnis
`microservice-linkerd-demo`. Das Skript erzeugt die Docker
Images.

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

* Manchmal können die Images nicht heruntergeladen werden. Versuche
  dann, `docker logout` einzugeben und das Skript erneut zu starten.


* Die Images sollten nun verfügbar sein:

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
* Nur Google Cloud: Lade die Docker Images mit `docker-push-gcp.sh` in
  die Cloud hoch.

## Container starten

* Nur Google Cloud: Modifiziere die YAML-Dateien so, dass sie die
  Docker Images aus dem Google Docker Repository herunterladen mit
  `fix-microservices-gcp.sh` 

* Wenn du die Container nicht selbst gebaut hast, starte
  `fix-microservices-dockerhub.sh`, so dass die Container aus dem
  Docker Hub im Internet heruntergeladen werden.

* Deploye die Infrastruktur für die Microservices mit `kubectl` im
Verzeichnis `microservice-kubernetes-demo` .
Verwende `infrastructure-gcp.yaml` statt  `infrastructure.yaml`, wenn
das System in der Google Cloud läuft. Verwende
`infrastructure-dockerhub.yaml`, wenn du die Container nicht selbst
gebaut hast.


```
[~/microservice-linkerd/microservice-linkerd-demo]kubectl apply -f infrastructure.yaml
deployment.apps/apache created
deployment.apps/postgres created
service/apache created
service/postgres created
ingress.extensions/apache created
```


* Deploye die Microservices mit `kubectl`.
Verwende `microservices-gcp.yaml` statt `microservices.yaml`, wenn das
System in der Google Cloud läuft. Verwende
`microservices-dockerhub.yaml`, wenn du die Container nicht selbst
gebaut hast.


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

Das Skript erzeugt Pods mit den Docker Images, die zuvor gebaut worden
sind. Pods können einen oder mehrere Docker Container enthalten. In
diesem Fall enthält jeder Pod einen Docker Container mit dem
Microservice und einen weiteren mit der Linkerd-Infrastruktur.

Hinweis: Die Postgres-Installation ist sehr einfach, d.h. es ist nicht
garantiert, dass die Daten einen Neustart oder Änderungen im Cluster
überstehen. Für eine Demo-Umgebung ist das allerdings nicht notwendig
und so bleibt das Setup recht einfach.

Das Skript erzeugt auch Kubernetes-Services. Services haben eine im
Cluster eindeutige IP-Adresse und einen DNS-Eintrage. Ein Service kann
dann viele Pods umfassen, um Lastverteilung umzusetzen.

* Starte `kubectl get services`, um die Kubernetes-Services zu sehen:

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


* `kubectl describe service` gibt weitere Details über die Services
  aus.  Das funktioniert auch mit Pods (`kubectl describe pod`) und
  Deployments (`kubectl describe deployment`).

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

* Man kann sich auch eine Liste der Pods geben lassen:

```
[~/microservice-linkerd/microservice-linkerd-demo]kubectl get pods
NAME                        READY   STATUS    RESTARTS   AGE
apache-7f7f7f79c6-jbqx8      2/2     Running   0          8m51s
invoicing-77f69ff854-rpcbk   2/2     Running   0          8m43s
order-cc7f8866-9zbnf         2/2     Running   0          8m43s
postgres-5ddddbbf8f-xfng5    2/2     Running   0          8m51s
shipping-5d58798cdd-9jqj8    2/2     Running   0          8m43s
```

* ...und man kann sich die Logs eines Pods anschauen:

```
~/microservice-linkerd/microservice-linkerd-demo$ kubectl logs order-cc7f8866-9zbnf order 

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.3.3..RELEASE)

2019-01-17 16:56:30.909  INFO 6 --- [           main] com.ewolff.microservice.order.OrderApp   : Starting OrderApp v0.0.1-SNAPSHOT on order-cc7f8866-9zbnf with PID 6 (/microservice-linkerd-order-0.0.1-SNAPSHOT.jar started by root in /)
2019-01-17 16:56:30.918  INFO 6 --- [           main] com.ewolff.microservice.order.OrderApp   : No active profile set, falling back to default profiles: default
2019-01-17 16:56:31.200  INFO 6 --- [    es-writer-1] es-logger                                : {"index":{"_index":"logs-2019-01-17","_type":"tester"}}
{"@timestamp":"2019-01-17T16:56:30.909+0000","message":"Starting OrderApp v0.0.1-SNAPSHOT on order-cc7f8866-9zbnf with PID 6 (/microservice-linkerd-order-0.0.1-SNAPSHOT.jar started by root in /)","host":"order-cc7f8866-9zbnf","severity":"INFO","thread":"main","logger":"com.ewolff.microservice.order.OrderApp"}
{"index":{"_index":"logs-2019-01-17","_type":"tester"}}
{"@timestamp":"2019-01-17T16:56:30.918+0000","message":"No active profile set, falling back to default profiles: default","host":"order-cc7f8866-9zbnf","severity":"INFO","thread":"main","logger":"com.ewolff.microservice.order.OrderApp"}
...
```

* Außerdem kann man in einem Pod ein Kommando ausführen:

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

* Es ist sogar möglich, eine Shell in einem Container zu starten:

```
[~/microservice-linkerd/microservice-linkerd-demo]kubectl exec order-cc7f8866-9zbnf -it /bin/sh
Defaulting container name to order.
Use 'kubectl describe pod/order-cc7f8866-9zbnf -n default' to see all of the containers in this pod.
# ls
bin  boot  dev	docker-java-home  etc  home  lib  lib32  lib64	libx32	media  microservice-linkerd-order-0.0.1-SNAPSHOT.jar  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
#
```

## Demo verwenden

Die Funktionalitäten der Demo sind durch einen Ingress verfügbar, der
Zugriff auf alle Microservices anbietet.

* Überprüfe, ob das Ingress Gateway funktioniert:

```
[~/microservice-linkerd/microservice-linkerd-demo]kubectl get service traefik -n traefik
NAME      ...      EXTERNAL-IP   PORT(S)                      AGE

traefik   ...      localhost in     81:32720/TCP,443:32319/TCP   3h9m
```

* `ingress-url.sh`  gibt die Ingress-URL aus.

* Wenn Du nun die Ingress URL öffnest, dann wird
eine statische HTML-Seite angezeigt, die vom Apache-Webserver
angezeigt wird. Sie hat Links zu den andern Microservices.

* Sollte der Zugriff auf den Ingress nicht funktionieren oder die
  Skripte keine sinnvolle URL ausgegeben, dann kannst du mit
  dem Skript `ingress-forward.sh` einen Proxy zu dem Ingress auf dem
  lokalen Rechner erzeugen. Das Skript dann die URL des Proxys aus.

## Microservice hinzufügen

Im Verzeichnis `microservice-linkerd-bonus` gibt es einen weiteren
Microservice. 
Dieser Microservice zeigt, wie man das System mit einem Microservice
ergänzen kann, der sich nicht das Build-System mit den anderen
Microservices teilt. So kann der Microservice beispielsweise eine neue
Java-Version oder eine neue Spring-Boot-Version nutzen, ohne die
anderen Microservices zu beeinflussen.
Um auch diesen Microservice zu deployen, sind die
folgenden Schritte notwendig, wenn man den Microservice lokal bauen
will:

* Wechsel in das Verzeichnis`microservice-linkerd-bonus` und starte
`./mvnw clean package` (macOS / Linux) oder `mvnw.cmd clean package`
(Windows), um den Java Code zu kompilieren.

* Starte `docker-build.sh` im Verzeichnis
`microservice-linkerd-bonus`. Das Skript erzeugt das Docker Image und
lädt es in den Kubernetes Cluster.

* Nur Google Cloud: Lade die Docker Images mit `docker-push-gcp.sh` in
  die Cloud hoch.

* Deploye die Microservices mit `kubectl apply -f bonus.yaml`.

* Google Cloud: Nutze stattdessen `fix-bonus-gcp.sh` und deploye dann
  mit `kubectl apply -f bonus-gcp.yaml`.
  
Mit `fix-bonus-github.sh` und `kubectl apply -f
bonus-dockerhub.yaml` kann man die Images auch aus Dockerhub
herunterladen, so dass sie nicht lokal gebaut werden müssen.

Mit `kubectl delete -f bonus.yaml` kann man die Microservices wieder
löschen.

#### Den neuen Microservice nutzen

Der Bonus-Microservice ist nicht in der statischen Webseite enthalten,
die Links zu den Microservices enthält. Dennoch kann der Microservice
durch das Ingress Gateway erreicht werden. `ingress-url.sh` gibt die
URL des Ingress Gateways aus. Wenn die URL des Ingress
Gateways http://192.168.99.127:31380/ ist, dann kann auf den
Bonus-Microservice unter http://192.168.99.127:31380/bonus
zugegriffen werden.

Der Bonus-Microservice zeigt keinen Umsatz an. Das liegt daran, dass
der Microservices ein Feld  `revenue` in den Daten aus dem
Order-Microservice erwartet. Dieses Feld ist im Moment in der
Datenstruktur nicht enthalten. Das verdeutlicht, dass ein neuer
Microservice gegebenfalls Änderungen an den Datenstrukturen
erforderlich machen kann. Solche Änderungen können dann wiederum
andere Microservices beeinflussen.
Aber der Microservice funktioniert, obwohl die Daten nicht vorhanden
sind.

## Prometheus

Linkerd enthält eine Installation von
[Prometheus](https://prometheus.io/). 
Dieses Werkzeug sammelt Metriken von den Proxies ein, über welche die
Microservices miteinander kommunizieren. Es stellt daher die Basis für
das Monitoring dar. 

Mit `kubectl -n linkerd port-forward deployment/linkerd-prometheus
9090:9090` kann man einen Proxy erzeugen, um dann auf Prometheus unter
http://localhost:9090/ zuzugreifen. 
In der Google Cloud Shell kann man die [Web
+Preview](https://cloud.google.com/shell/docs/using-web-preview)
nutzen, um die Oberfläche im Browser anzuzeigen.

Das Skript `monitoring-prometheus.sh` enthält ebenfalls diesen Befehl.

Metriken sind nur sinnvoll, wenn das System unter Last ist. Das
Shell-Skript `load.sh` nutzt `curl`, um eine bestimmte URL 1.000
aufzurufen. Du kannst das eine oder mehrere Instanzen des Skripts
starten und dabei beispielsweise die URL der Home Page des Shipping
Microservice übergeben, um so Last auf diesem Service zu erzeugen.

## Linkerd

Linkerd hat ein eigenes Dashboard, das einige Informationen wie
z.B. die eingesetzten Ressourcen, Namensräume usw. liefert. Du kannst
`linkerd dashboard` verwenden, um einen Proxy für das Dashboard zu
erstellen und unter der angegebenen URL darauf
zuzugreifen. Insbesondere "Top", "Tap" und "Routes" könnten
interessant sein. Auch der "Workload" enthält einige Metriken und
Links zu Grafana.

Sie können die Daten auch über die Kommandozeile mit `linkerd stat`
abrufen. Zum Beispiel gibt `linkerd stat deploy` eine allgemeine
Metrik für alle Deployments an.

`linkerd routes` gibt spezifische Informationen über die Metrik für
eine bestimmte Route zwischen Deployments. Zum Beispiel zeigt `linkerd
routes deploy/shipping --to service/order` die Metriken für die
Kommunikation zwischen dem Shipping- und dem Order-Microservice zum
Pollen neuer Order.

`linkerd top deploy` zeigt, was derzeit im Kubernetes-Cluster
geschieht.

`linkerd tap deploy/order` zeigt an, welche Requests der
Order-Microservice im Moment bearbeitet.

## Grafana

Prometheus bietet nur sehr limitierte Dashboards an. Deswegen hat
Linkerd außerdem eine Installation von 
[Grafana](https://grafana.com/), das viel bessere Graphen und
Dashboards anbietet.

`linkerd dashboard` bietet auch Zugang zum Grafana-Dashboard. Sie
können also die vom Befehl angegebene URL verwenden, um auf Grafana
zuzugreifen.

Informationen über die Deployment finden Sie im "Linkerd Deployment
Dashboard". Sie können ein Deployment auswählen und dann auf den
entsprechenden Link zu Grafana klicken.

## Logging

Linkerd [unterstützt auch
Logging](https://linkerd.io/docs/tasks/observability/logs/access-log/).
Für das Beispiel ḱannst Du z.B. `linkerd tap deploy/order` verwenden,
um jeglichen Verkehr zum Order-Microservice zu protokollieren.

Aber Linkerd kann in den Logs nur die Informationen aus den HTTP
Request loggen. Diese Informationen sind zwar wertvoll, aber reichen
oft nicht aus, um Probleme in den Microservices zu untersuchen. Daher
müssen die Microservices selber einige Informationen loggen, die dann
beispielsweise über die Kubernetes-Infrastruktur zugreifbar sind.

## Security

Linkerd verschlüsselt die Kommunikation zwischen den Pods. Sie können
dies mit `linkerd edges deployment` verifizieren. Es sollte zeigen,
dass die gesamte Kommunikation gesichert ist. Sie können auch `linkerd
tap deploy` verwenden, um für jede Netzwerkkommunikation zu sehen, ob
sie mit TLS verschlüsselt ist oder nicht.

## Fault Injection

Linkerd bietet eine Funktion zur Aufteilung des Datenverkehrs zwischen
verschiedenen Backends. Dies kann dazu verwendet werden, Fehler in
eine Route zwischen zwei Services einzufügen. Damit lässt sich die
Ausfallsicherheit des Systems testen. `fault-injection.yaml` fügt dem
System eine nginx-Instanz hinzu, die immer mit einem
HTTP-500-Fehlercode antwortet. Es teilt auch den Verkehr zwischen dem
ursprünglichen Dienst und der nginx-Instanz auf. Auf diese Weise
treffen 50% aller Anfragen auf den nginx-Dienst und erhalten einen
Fehler. Du kannst die Konfiguration mit `kubectl apply -f
fault-injection.yaml` zum System hinzufügen.  Wenn Sie die den
Shipping- oder Invoicing-Microservice jetzt neue Informationen aus dem
Order-Microservice abfragen lassen, endet in 50% der Fälle mit einem
Fehler.

`linkerd stat deploy` zeigt, dass das Auftrags-Deployment immer noch
einwandfrei funktioniert. Allerdings wird `linkerd routes
deploy/shipping --to service/order` zeigen, dass einige Aufrufe an den
Dienst fehlschlagen.  Noch mehr Informationen erhälst Du mit `linkerd
routes deploy/shipping --to service/order -o wide` .

Um die Fehlerinjektion wieder zu entfernen, verwenden Sie einfach
`kubectl delete -f fault-injection.yaml`.

## Timeout

Linkerd fügt allen Services Timeouts hinzu. Der Standard-Timeout
beträgt jedoch 10 Sekunden, und normalerweise antworten die Services
viel schneller. Mit `kubectl apply -f timeout.yaml` wird ein Timeout
von 3 ms für GET-Operationen auf `/order/feed` für den
Order-Microservice gesetzt. Sie können jetzt mit `./load.sh"-X POST
http://localhost:80/shipping/poll"` Last erzeugen. Eine ganze Reihe
von Aufrufen wird jetzt fehlschlagen, da der Order-Microservice nicht
schnell genug reagiert. `linkerd routes deploy/shipping --to
service/order -o wide` bietet detailliertere Statistiken.

`kubectl delete -f timeout.yaml` löscht den Timeout wieder.

## Retry

Mit `kubectl apply -f failing-order-service.yaml` kann man eine
Version des Order-Microservices deployen, der 50% aller Requests mit
einen HTTP-500-Fehler beantwortet.  Verwende
`failing-order-service-gcp.yaml` statt `failing-order-service.yaml`,
wenn das System in der Google Cloud läuft. Verwende
`failing-order-service-dockerhub.yaml`, wenn du die Container nicht
selbst gebaut hast.

Wenn man nun die Web UI des Order Microservice nutzt bzw Invoicing
order Shipping dazu bringt, den Order-Microservices zu pollen, dann
gibt es vermutlich einen Fehler. `linkerd routes deploy/shipping --to
service/order` zeigt auch eine Statistik dazu.

Mit `kubectl apply -f retry.yaml` kann man Linkerd dazu bringen, jeden
Request an den Order-Microservice noch ein zweites Mal
auszuführen. Diese Wiederholungen fügt linkerd sowohl in die
Kommunikation zwischen den Microservices ein als auch bei der
Kommunikation mit dem Ingress Gateway. Also funktioniert sowohl das
Pollen als auch die Web UI wieder.

Linkerd verwendet ein Retry-Budget. Es erlaubt mindestens 10
Wiederholungsversuche pro Sekunde, aber maximal 20% zusätzliche
Belastung durch Retrys. Auf diese Weise wird das System durch Retrys
nicht überlastet. Außerdem sind Retrys auf HTTP-GET-Operationen
beschränkt. GET ist idempotent, so dass es sicher ist, sie erneut zu
versuchen. Bei POSTs ist das anders.

Mit `kubectl delete -f retry.yaml` kann man die Retrys aus dem System
wieder entfernen. Der Microservice kann mit `kubectl apply -f
microservices.yaml` zurückgesetzt werden.

## Aufräumen

* Um alle Microservices zu löschen, starte `kubectl delete -f
  microservices.yaml`:

```
[~/microservice-linkerd/microservice-linkerd-demo] kubectl delete -f microservices.yaml
deployment.apps "catalog" deleted
deployment.apps "customer" deleted
deployment.apps "order" deleted
service "catalog" deleted
service "customer" deleted
service "order" deleted
ingress.extensions "customer" deleted
ingress.extensions "catalog" deleted
ingress.extensions "order" deleted
```

* Lösche dann die Infrastruktur mit `kubectl  delete -f
  infrastructure.yaml`:

```
[~/microservice-linkerd/microservice-linkerd-demo] kubectl delete -f infrastructure.yaml
deployment.apps "apache" deleted
deployment.apps "postgres" deleted
service "apache" deleted
service "postgres" deleted
ingress.extensions "apache" deleted
```

* Nutze `helm uninstall --namespace=traefik traefik` , um den
  Traefik-Ingress zu löschen.
