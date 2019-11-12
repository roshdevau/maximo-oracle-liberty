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

# Clear old deployment files first
SMP="/opt/IBM/SMP"


# Watch and wait the database
wait-for-it.sh $DB_HOST_NAME:$DB_PORT -t 0 -q -- echo "Database is up"

DEMO_DATA="-deployDemoData"

DB_FQDN=`ping $DB_HOST_NAME -c 1 | head -n 2 | tail -n 1 | cut -f 4 -d ' ' | tr -d ':'`

CONFIG_FILE=/opt/maximo-config.properties
if [ -f $CONFIG_FILE ]
then
  echo "Maximo has already configured."
else
cat > $CONFIG_FILE <<EOF
MW.Operation=Configure
# Maximo Configuration Parameters
mxe.adminuserloginid=maxadmin
mxe.adminPasswd=maxadmin
mxe.system.reguser=maxreg
mxe.system.regpassword=maxreg
mxe.int.dfltuser=mxintadm
maximo.int.dfltuserpassword=mxintadm
MADT.NewBaseLang=en
MADT.NewAddLangs=
mxe.adminEmail=root@localhost
mail.smtp.host=localhost
mxe.db.user=maximo
mxe.db.password=$ORACLE_PWD
mxe.db.schemaowner=maximo
mxe.useAppServerSecurity=0
mxe.rmi.enabled=0

# Database Configuration Parameters
Database.Vendor=Oracle
Database.Oracle.InstanceName=MAXDB761
Database.Oracle.ServiceName=MAXDB761
Database.Oracle.DataTablespaceName=MAXDATA
Database.Oracle.IndexTablespaceName=MAXINDEX
Database.Oracle.ServerHostName=$DB_FQDN
Database.Oracle.ServerPort=$DB_PORT

# WebSphere Configuration Parameters
ApplicationServer.Vendor=WebSphere
WAS.ND.AutomateConfig=false
IHS.AutomateConfig=false
WAS.ClusterAutomatedConfig=false
WAS.DeploymentManagerRemoteConfig=false
EOF
  # Run Configuration Tool
$SMP/ConfigTool/scripts/reconfigurePae.sh -action deployConfiguration -bypassJ2eeValidation -inputfile $CONFIG_FILE $DEMO_DATA
fi

INSTALL_PROPERTIES=$SMP/etc/install.properties
sed -ie "s/^ApplicationServer.Vendor=.*/ApplicationServer.Vendor=WebSphereLiberty/" "$INSTALL_PROPERTIES"

$SMP/ConfigTool/scripts/reconfigurePae.sh -action updateApplicationDBLite -updatedb -enableSkin "$SKIN" -enableEnhancedNavigation

# Deploy WAS.UserName and WAS.Password properties
# cd $SMP/maximo/tools/maximo/internal && ./runscriptfile.sh -cliberty -fliberty

# Bring in xml-apis.jar to maximouiweb.war/webmodule/WEB-INF/lib
cp /opt/IBM/SMP/maximo/applications/maximo/maximouiweb/webmodule/WEB-INF/classes/com/ibm/tivoli/maximo/report/control/svgtools/xml-apis.jar /opt/IBM/SMP/maximo/applications/maximo/maximouiweb/webmodule/WEB-INF/lib
# Build Wars
/work/buildwars.sh

# If /shared folder exists. If it does not do nothing
if [[ -d "/shared" ]]; then
        rm -rf /shared/*
	cp -r /opt/IBM/SMP/maximo/deployment/was-liberty-default/deployment/maximo-ui/maximo-ui-server /shared
	cp -r /opt/IBM/SMP/maximo/deployment/was-liberty-default/deployment/maximo-cron/maximo-cron-server /shared
	cp -r /opt/IBM/SMP/maximo/deployment/was-liberty-default/deployment/maximo-api/maximo-api-server /shared
	cp -r /opt/IBM/SMP/maximo/deployment/was-liberty-default/deployment/maximo-report/maximo-report-server /shared
	cp -r /opt/IBM/SMP/maximo/deployment/was-liberty-default/deployment/maximo-mea/maximo-mea-server /shared
	cp -r /opt/IBM/SMP/maximo/deployment/was-liberty-default/deployment/maximo-jmsconsumer/maximo-jmsconsumer-server /shared

fi

if [ "${KEEP_RUNNING}" = "yes" ]
then
  sleep inf &
  child=$!
  wait $child
fi
