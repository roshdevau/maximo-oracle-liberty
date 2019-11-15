# Maximo on Oracle with WebSphere Liberty
This example only creates maximo-ui as an example. jmsserver is not created as part of this example. jmsserver example can be found at https://github.com/nishi2go/maximo-liberty-docker

However if you intend to use Maximo as an API provider there is no real need to use jmsserver. My personal preferrence is to use the OSLC framework as opposed to defining Publish Channels, Enterprise Services and WebServices in Maxim to integrate Maximo with external systems

## Clone Repository
Clone this repository in your working folder

## Pre-Requisites
Ensure following installers/binaries are downloaded and placed in then maximo-oracle-liberty/binaries folder:

* ibm-java-x86_64-sdk-8.0-5.41.bin  - IBM JAVA 8. Make sure you have IBMs Java as opposed to Oracle Java
* installIBMJDK.rsp  - IBM JAVA 8 silent installation response file
* linuxx64_12201_database.zip  - Oracle DB 12.2.0.1 installer
* MAM_7.6.1.0_LINUX64.tar.gz  - Maximo 7.6.1.0 binary. This binary also contains the Installation Manager.
* MAMMTFP7611IMRepo.zip  - Maximo 7.6.1.1 fixpack
* maximo.properties   - Template Maximo.properties file. The values in here is replaced for the environment being installed
* wlp-javaee8-19.0.0.10.zip - WebSphere Liberty installer
* wlp-nd-license.jar - WebSphere Liberty License jar

Please alter docker-stack.yml to your needs.

## Get the images created
```
Note: The Host node in use was Ubuntu 16.04
```
Run the below script to create all the images required for the installation
./buildMaximoImages.sh

Four images are created:
* Liberty - This image contains WebSphere Liberty installed along with the IBM Java
* Oracle - This image has the Oracle 12c installed
* Maximo - This image contains the SMP folder and also creates all the Maximo Wars
* Maxapps - This image is uses the Liberty image created earlier and installs Maximo when coming up

## Bring up the Containers in a Swarm

The docker containers can be brought up in a swarm as below:

docker stack deploy --compose-file docker-stack.yml maximoFE

When the oracle container comes up it creates the MAXIMO database. This takes close to 8 minutes depdending on your system.
If you bring up all the services in a swarm then Maximo-ui would fail as it does not wait for Oracle DB to be created. 
#### This is an issue needs to be fixed :-)

If that is the case, bring up a new replica and it should all work:
docker service scale maximoFE_maximo-ui=**2**

If this is pain then:
* Update docker-stack.yml to remove maximo-ui service 
* Bring up the service by itself as below:
* docker service create  --name maximo-ui  --network maximoFE_maxnet  --detach=true  --publish 80:9080 --replicas=1  maximo/maximo-ui


## Existing issues
When bringing up the docker swarm,if more than one replica exists, then the sessions persistence is a pain. This needs to be fixed.




