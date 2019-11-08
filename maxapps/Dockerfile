FROM maximo/liberty:latest

WORKDIR /opt/IBM/wlp
ARG maximoapp="maximo-ui"
RUN echo ${maximoapp}
RUN bin/server create ${maximoapp}-server

WORKDIR /tmp
COPY startServer.sh .
RUN echo "/tmp/startServer.sh ${maximoapp}" > /tmp/startMaxServer.sh
RUN chmod +x /tmp/*.sh
ENTRYPOINT ["/bin/bash","/tmp/startMaxServer.sh"]

