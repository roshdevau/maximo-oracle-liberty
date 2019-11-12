#!/bin/bash

################################################
#    Script : To build Maximo images           #
#    Author : roshdevau                        #
#    Usage  : ./buildMaximoImages.sh           #
#    Created: 29 June 2019                     #
################################################

checkAndExitIfPrevFailed () {

if [[ $1 -ne 0 ]];
then
        exit $1
fi
}

FILE_PATH=$(cd `dirname $0` && pwd)
echo $FILE_PATH/binaries

# Copy the Oracle Installer to the right folder
if [[ ! -f ./oracle/12.2.0.1/linuxx64_12201_database.zip ]];
then
	mv ./binaries/linuxx64_12201_database.zip oracle/12.2.0.1
	checkAndExitIfPrevFailed $?
fi

# Create a network build for transfer of installers
#docker network rm build
#docker network create build
#checkAndExitIfPrevFailed $?

# Create container to access installers over a web url
#docker run -d --name ibmbinaries -h ibmbinaries --network build -v $FILE_PATH/binaries:/usr/local/apache2/htdocs/ --restart always httpd:2.4
#checkAndExitIfPrevFailed $?

# Create an Oracle 12c Images
#oracle/buildDockerImage.sh -v 12.2.0.1 -e
#checkAndExitIfPrevFailed $?

# Create WebSphere Application Server image
docker build -t maximo/liberty:19.0.0.10-webProfile8 -t maximo/liberty:latest --network build liberty
checkAndExitIfPrevFailed $?

# Create a Maximo Image
docker build -t maximo/maximo:7.6.1.1 -t maximo/maximo:latest --network build maximo
checkAndExitIfPrevFailed $?

# Create a Maximo Image
docker build -t maximo/maxapps:7.6.1.1 -t maximo/maxapps:latest --network build --build-arg "maximoapp=maximo-ui" maxapps
checkAndExitIfPrevFailed $?
