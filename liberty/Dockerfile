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

LABEL maintainer="roshdevau@gmail.com"

# Install required packages
USER root
ARG url=http://ibmbinaries
ENV WLP_BINARY wlp-javaee8-19.0.0.10.zip
ENV WLP_LICENSE wlp-nd-license.jar
RUN apt-get update \
 && apt-get install -y --no-install-recommends wget unzip openjdk-8-jdk \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

RUN wget -q ${url}/$WLP_BINARY && wget -q ${url}/$WLP_LICENSE && unzip -q /tmp/$WLP_BINARY -d /opt/IBM && java -jar /tmp/wlp-nd-license.jar --acceptLicense /opt/IBM && rm /tmp/$WLP_BINARY && rm /tmp/$WLP_LICENSE
