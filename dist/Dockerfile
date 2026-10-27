FROM jacobalberty/firebird

ENV CAMINHO_BD=portalsoft.net.br:/home/EKIPE/PRINCIPAL.FDB
ENV DB_USER=SYSDBA
ENV DB_PASS=masterkey

RUN apt-get update -y && apt upgrade -y && apt-get dist-upgrade -y
# RUN apt-get install -y zlib1g-dev
RUN apt-get install -y libcurl4-gnutls-dev

COPY ./ServidorEkipe ./servidor/ServidorEkipe

EXPOSE 8080

ENTRYPOINT ./servidor/ServidorEkipe