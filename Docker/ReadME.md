<center> <h1>Discovering Docker</h1> </center>

## 1. A Quick Introduction to Docker

*Note 1: To install Docker on your machine, you could use the following procedure: https://docs.docker.com/engine/install/ubuntu/.* 
*Note 2; Alternatively you could also use the procedure in this 'install.sh' script, but it is not guaranteed that it will work as expected...*
*Note 3: You could have to use 'sudo' to use the different docker commands used in this practical exercise*

**Q1. What is Docker? What are the benefits of such an approach?**

To answer this question, you could use the folliwing link: https://www.knowledgehut.com/blog/devops/why-use-docker

To check that Docker is correctly installed on your machine, you could use the following command:

```console
$ docker run hello-world
```

In  this command line:
  1. 'docker' tells your operating system you are using the docker program
  2. 'run' is one on the different subcommands offered by docker to create an run a docker container
  3. 'hello-world' is used to indicated to docker that you are using a specific image that will be loaded in the container

### Basic Commands

Different simple command line are enabled using 'docker', you should try some of them:
  - To look for docker images in the Docker Hub, an example for ubuntu keyword: 'docker search ubuntu' 
  - To download a pre-build image (debian stretch image here): 'docker pull debian:stretch'
  - To see the list of available images: docker images
  - To run an interactive shell within a given container: 'docker run -i -t debian:stretch /bin/bash'. In this command line, '-i' indicates that we want to start an interactive container, '-t' creates a pseudo-TTY that attaches stdin and stdout. 'exit' should be used to quit a running docker container.
  - To list all containers: 'docker ps -a'; to list running containers 'docker ps'
  - To indicate the name of a container (basically launched with an autogenerated name and ID): 'docker run --name XXX -i -t  /bin/bash'
  - To directly run commands within a container: docker run -d debian:stretch /bin/sh -c "while true;\ do echo Hi; sleep 1; done"
  - To kill a container 'docker kill XXX'
  - To run and stop a container: '$ JOB=$(docker run...) ; $ docker logs $JOB ; docker kill $JOB'
  - To remove a container: 'docker stop XXX' + 'docker rm XXX'
  - To start/restart a container: 'docker (re)start XXX' 
  - To pass variables from your host to your image: 'docker run -ti -e FOO=BAR debian:stretch' => Running 'echo $FOO' within your container you should be able to see the expected result
  - To commit a new image: 'docker commit containerName newImageName' (could be especially useful after installing some new packages within a basic docker image)
  - To locally save an image: 'docker save Image Name tarFileName'
  - To load an image from a tarFile: 'docker lad -i tarFileName'
  - Indicate the memory that can be used by a container: 'docker run -it -m 2GB...'
  - To dee diffications betweeb docker image and docker container: 'docker diff dockerName'
  - To see running processes in a container: 'docker top dockerName'
  - To map ports: 'docer run -d -p machinePort:containerPort --name containerName used Image potentialCOMMAND'


### Basic Docker Containers Management

Inside of a container created with Docker, applications and commands can be used in an isolated environment. For example, you can check that, 1) the environment variables existing in the running docker container are isolated and specifically designed for this environment and 2) a file created in a Docker container will only exist in this container.

#### Bridges

Docker installed a Linux bridge docker0 in your system. This bridge can be analysed using the following command: 'docker network inspect bridge'

In a default configuration, all docker containers launched on a machine are attached to this bridge.

Launch two containers with the 'debian:stretch' image.

**Q2. Can containers ping each other: 1) using IP adresses? 2) using their hostname?**

(Note: containers hostname can be displayed within containers using 'echo $HOSTNAME')

Now, stop and delete container2 and restart it with the following command (*using correct naming for containers!)*:
```console
$ docker run -ti --name XXX2 --link XXX1 debian:stretch
```

*Note: You can also create custom bridged networks: https://docs.docker.com/network/bridge/*

**Q3. Can containers ping each other using their hostname now?**

#### Ports Exposure

The idea, in this small example will be to access a web server runnin within a container. To enable that, it will be required to make the containers ports public (expose them).

To do so, you will have to install the 'netcat-openbsd' package.

For example, what should do the following command line? ('while true;do echo ok |nc -l 8080; done;')

**Q4. If you launch the three different command lines what will be the different between the outputs of a docker ps? How container could be reachable?**

  1. 'docker run --name test1 -d debian:stretch /bin/bash -c 'while true;\ do echo ok |nc -l 8080; done;'
  2. 'docker run -p 8080 --name test1 -d debian:stretch /bin/bash -c \ 'while true; do echo ok |nc -l 8080; done;'
  3. docker run -p 8080:8080 --name test1 -d debian:stretch /bin/bash -c \ 'while true; do echo ok |nc -l 8080; done;'

#### Own Docker Image Using Docker File

Creating a new docker image is possible using the following procedure:
  1. Create a new directory and do within this directory
  2. Within this directory, create a new file called 'Dockerfile'
  3. Add the following content to this file:
```console
FROM debian:stretch
RUN apt-get -y update && apt-get install -y iperf netcat-openbsd iputils-ping
CMD iperf -s
```
**Q5. What does the program seem to do?**
  4. Within your folder, you can new build your Docker image using the following command line: 'docker build -t iperf-serv .' You can verify that your image has been generated using the following command: 'docker images'
  5. To run this image you can simply use: 'docker run -ti iperf-serv' 

#### Persistent data storage

Persistent data storage can be managed using two approaches: 1) images commit (cf. first subsection of section 1) 2) using volumes.

For example, if you 1) launch a docker container using a pre-build image ('docker run... debian:stretch...'), 2) create a new file within this docker container and add content to this file, 3) exit the docker container and remote it ('docker rm') and 4) run it again (back to the first step of this procedure).

**Q6. Is the file that you created earlier still existing?**

Volumes are directories in the host that are mapped to directories in containers. 

Using the '--mount' flag, mount the host directory 'allData' in the container directory '/mydata'


## 2. Implementing a new application

### Basic Web Serverimage deployment

*Note: DockerFile can potentially used there but it is not required*

For this part, using the previous sections, follow the different steps:
  1. Download the Debian (stretch) image
  2. Run this container with an interactive shell naming it "serverV0"
  3. Update packages within this container (apt-get update && apt-get upgrade)
  4. Update date within this container: 'dpkg-reconfigure tzdata'
  5. Install apache2 within this container
  6. Commit a new image based on this evolved container naming it my/debian:stretch-apache2
  
Then, you should be able to launch container using this new image:

```console
docker run -d -p 127.0.0.1:8001:80 --name contX my/debian:stretch-apache2 /usr/sbin/apache2ctl -DFOREGROUND
```

That happens of you go on a browser (on your own client) and connect to the following URL: 'http://127.0.0.1:8001'?

**Q7. What is Apache? What can it be used for? What are the main elements of the above command line?**

