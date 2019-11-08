# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:16.04

MAINTAINER Rosh <roshdevau@gmail.com>


ARG url=http://ibmbinaries
ARG httpport=80
ARG skin=iot18

ENV TEMP /tmp
WORKDIR /tmp

# Install required packages
RUN apt update && apt install -y netcat inetutils-ping unzip wget dos2unix xmlstarlet && rm -rf /var/lib/apt/lists/*

## Install Maximo middleware and installer
RUN mkdir /Launchpad
WORKDIR /Launchpad

ENV BYPASS_PRS=True

## Install Maximo V7.6.1
ENV MAM_IMAGE MAM_7.6.1.0_LINUX64.tar.gz
ENV RSP_FILE ResponseFile_MAM_Install_Unix.xml
ENV MAM_FP MAMMTFP7611IMRepo.zip

## Remove z from tar command because file is not gzipped despite having gz extension
RUN wget -q $url/$MAM_IMAGE && tar -xf $MAM_IMAGE && /Launchpad/Install/IM/installer.linux.x86_64/installc -log /tmp/IM_Install_Unix.xml -acceptLicense \
 && /opt/IBM/InstallationManager/eclipse/tools/imcl  -input /Launchpad/SilentResponseFiles/Unix/ResponseFile_MAM_Install_Unix.xml  -acceptLicense -log /tmp/MAM_Install_Unix.xml 


RUN wget -q $url/$MAM_FP && /opt/IBM/InstallationManager/eclipse/tools/imcl install com.ibm.tivoli.tpae.base.tpae.main -repositories /Launchpad/$MAM_FP -installationDirectory /opt/IBM/SMP -log /tmp/MAM_FP_Install_Unix.xml -acceptLicense \
 && /opt/IBM/InstallationManager/eclipse/tools/imcl install com.ibm.tivoli.tpae.base.mam.main -repositories /Launchpad/$MAM_FP -installationDirectory /opt/IBM/SMP -log /tmp/TPAEFP_Install_Unix.xml -acceptLicense \
 && rm -rf /Launchpad

RUN mkdir /work
WORKDIR /work

ENV MAXADMIN_PASSWORD maxadmin
ENV MAXREG_PASSWORD maxreg
ENV MXINTADM_PASSWORD mxintadm
ENV BASE_LANG en
ENV ADMIN_EMAIL_ADDRESS root@localhost
ENV SMTP_SERVER_HOST_NAME localhost
ENV MAXDB MAXDB761
ENV DB_HOST_NAME oracle
ENV DB_PORT 1521
ENV DB_MAXIMO_PASSWORD Fujitsu123#

RUN wget -q https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh \
    && mv wait-for-it.sh /usr/local/bin && chmod +x /usr/local/bin/wait-for-it.sh

ENV SKIN=${skin}

COPY buildwars.sh startinstall.sh /work/
RUN dos2unix /opt/IBM/SMP/maximo/deployment/was-liberty-default/*.sh

RUN chmod +x /work/*.sh 

RUN mkdir /opt/IBM/SMP/maximo/tools/maximo/en/liberty
COPY liberty.dbc /opt/IBM/SMP/maximo/tools/maximo/en/liberty/

ENTRYPOINT ["/work/startinstall.sh"]
