FROM maximo/maximo:latest as base
FROM maximo/liberty:latest

ARG maximoapp="maximo-ui"
USER root
COPY --from=base /opt/IBM/SMP/maximo/deployment/was-liberty-default/deployment/${maximoapp}/${maximoapp}-server/ /opt/IBM/wlp/usr/servers/maximoserver/
RUN /opt/IBM/wlp/bin/installUtility install --acceptLicense maximoserver
WORKDIR /tmp
COPY startServer.sh .
RUN chmod +x /tmp/*.sh
CMD ["/tmp/startServer.sh"]

