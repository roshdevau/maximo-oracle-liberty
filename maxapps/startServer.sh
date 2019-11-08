#!/bin/bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
maximoapp=$1

if [[ ! -d /shared/${maximoapp}-server ]]; then
	echo "/shared/${maximoapp}-server does not exist. Sleeping for 5 secs"
	sleep 5
fi

cd /opt/IBM/wlp

cp -r /shared/${maximoapp}-server/* /opt/IBM/wlp/usr/servers/${maximoapp}-server/
bin/installUtility install --acceptLicense ${maximoapp}-server

bin/server run ${maximoapp}-server

