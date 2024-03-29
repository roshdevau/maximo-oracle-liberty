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

function jvm_config {
  cp "$1.orig" "$1.tmp"

  # Remove default options
#  for feat in "Xms" "Xmx"
#  do
#    sed -i -e "/$feat/d" "$1.tmp"
#  done

  echo "-XX:+DisableExplicitGC" >> "$1.tmp"
  echo "-Xcompressedrefs" >> "$1.tmp"
  echo "-XX:+UseContainerSupport" >> "$1.tmp"
#  echo "-Xgc:concurrentScavenge" >> "$1.tmp"

  cp "$1.tmp" "$1"
  rm "$1.tmp"
}

function edit_server_xml {
  cp "$1.orig" "$1.tmp"

  # Remove Java EE 7 features
  for feat in "jdbc-4.1" "webProfile-7.0" "javaMail-1.5"
  do
    sed -i -e "/$feat/d" "$1.tmp"
  done

  # Remove comment out
  sed -i 's/[ \t]\+$//' "$1.tmp"
  sed -i -e '/<!--$/d' "$1.tmp"
  sed -i -e '/^-->$/d' "$1.tmp"

  # Add quicksecuriy
  xmlstarlet ed \
    -s "/server" -t elem -n "quickStartSecurity" -v "" \
    -a "/server/quickStartSecurity" -t attr -n "userName" -v '${env.ADMIN_USER_NAME}' \
    -a "/server/quickStartSecurity" -t attr -n "userPassword" -v '${env.ADMIN_PASSWORD}' \
    -s "/server/featureManager" -t elem -n "feature" -v "localConnector-1.0" \
     "$1.tmp" > "$1.tmp_1"
  cp "$1.tmp_1" "$1.tmp"
  rm "$1.tmp_1"

  if [ "${JMS_ENABLED}" = "no" ]
  then
    xmlstarlet ed -d "//jmsQueue" \
      -d "//jmsQueueConnectionFactory" \
      -d "//connectionManager" "$1.tmp" > "$1.tmp_1"
    cp "$1.tmp_1" "$1.tmp"
    rm "$1.tmp_1"
  else
    xmlstarlet ed -u "//properties.wasJms/@remoteServerAddress" \
     -v '${env.JMS_SERVER_HOST}:${env.JMS_SERVER_PORT}:BootstrapBasicMessaging' "$1.tmp" > "$1.tmp_1"
    cp "$1.tmp_1" "$1.tmp"
    rm "$1.tmp_1"
  fi

  xmlstarlet fo "$1.tmp" > "$1"

  rm "$1.tmp"

  #debug
  cat "$1"
}

JMS_ENABLED=$enablejms
url=http://ibmbinaries
SMP="/opt/IBM/SMP"

# Run updatedblitepreprocessor
wget -q $url/maximo.properties -P $SMP/maximo/applications/maximo/properties/
sed -i 's/$DB_MAXIMO_PASSWORD/'"$DB_MAXIMO_PASSWORD"'/g;s/$MAXDB/'"$MAXDB"'/g;s/$DB_HOST_NAME/'"$DB_HOST_NAME"'/g;s/$DB_PORT/'"$DB_PORT"'/g' $SMP/maximo/applications/maximo/properties/maximo.properties
cd $SMP/maximo/tools/maximo
cp $SMP/maximo/applications/maximo/maximouiweb/webmodule/WEB-INF/classes/com/ibm/tivoli/maximo/report/control/svgtools/xml-apis.jar $SMP/maximo/applications/maximo/maximouiweb/webmodule/WEB-INF/lib
./updatedblitepreprocessor.sh || exit 1

LIBERTY_DEF_DIR="$SMP/maximo/deployment/was-liberty-default"
cd $LIBERTY_DEF_DIR

# Transform java ee 7 config to java ee 8 config in server.xml
for dir in "maximo-api" "maximo-cron" "maximo-jmsconsumer" "maximo-mea" "maximo-report" "maximo-ui"
do
  SERVER_XML="$LIBERTY_DEF_DIR/config-servers/$dir/$dir-server/server.xml"
  if [ ! -f "$SERVER_XML.orig" ]
  then
    cp "$SERVER_XML" "$SERVER_XML.orig"
  fi

  edit_server_xml "$SERVER_XML"

  JVM_OPTIONS="$LIBERTY_DEF_DIR/config-servers/$dir/$dir-server/jvm.options"
  if [ ! -f "$JVM_OPTIONS.orig" ]
  then
    cp "$JVM_OPTIONS" "$JVM_OPTIONS.orig"
  fi

  jvm_config "$JVM_OPTIONS"
done

if [ "${JMS_ENABLED}" = "yes" ]
then
  EJB_XMI="$LIBERTY_DEF_DIR/config-deployment-descriptors/maximo-jmsconsumer/mboejb/ejbmodule/META-INF/ibm-ejb-jar-bnd.xmi"
  sed -i -e '/^-->$/d' $EJB_XMI
  sed -i -e 's/^<!--/& -->/g' $EJB_XMI
fi

cd $LIBERTY_DEF_DIR

# Compile war files
for type in "-xwar" "api-war" "cron-war" "jmsconsumer-ear" "mea-ear" "report-war" "ui-war"
do
  echo "Run buildmaximo$type.sh ..."
  ## Change the mxe.server name in maximo.properties and encrypt
  sed -i 's/mxe.name=MXServer/mxe.name=maximo$type/g' $SMP/maximo/applications/maximo/properties/maximo.properties
  ## Note: Can encrypt Properties file if needed
  bash buildmaximo$type.sh
done
