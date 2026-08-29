FROM ubuntu:noble AS base

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl git openjdk-25-jre-headless zsh && \
    apt-get clean

FROM base AS build

ARG NODE_VERSION=23

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential zip && \
    apt-get clean

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

RUN mkdir /git

WORKDIR /git

RUN git init

RUN git remote add origin https://github.com/ThePansmith/Monifactory

ARG refspec

RUN git fetch --depth 1 origin $refspec

RUN git checkout $refspec

WORKDIR /git/build

RUN bash -c "source /root/.nvm/nvm.sh && npm install && node index.ts build-server"

FROM base

ENV RCON_CLI_VERSION=1.7.3

RUN curl -sLO https://github.com/itzg/rcon-cli/releases/download/$RCON_CLI_VERSION/rcon-cli_$RCON_CLI_VERSION\_linux_amd64.tar.gz && \
    tar xf rcon-cli_$RCON_CLI_VERSION\_linux_amd64.tar.gz rcon-cli && \
    mv rcon-cli /bin/rcon-cli && \
    rm rcon-cli_$RCON_CLI_VERSION\_linux_amd64.tar.gz

ENV MINECRAFT_VERSION=1.20.1

ENV FORGE_VERSION=47.4.10

RUN curl -sLo /opt/forge-installer.jar https://maven.minecraftforge.net/net/minecraftforge/forge/$MINECRAFT_VERSION-$FORGE_VERSION/forge-$MINECRAFT_VERSION-$FORGE_VERSION-installer.jar

RUN useradd -m minecraft

USER minecraft

WORKDIR /home/minecraft

RUN java -jar /opt/forge-installer.jar --installServer server

RUN sed -i 's/^java/exec java/' server/run.sh

COPY --from=build --chown=minecraft /git/dist/server server

RUN java -jar server/mods/monilabs-*.jar E

RUN curl -sfLo server/mods/pcf.jar https://cdn.modrinth.com/data/vDyrHl8l/versions/82bwNhmQ/proxy-compatible-forge-1.2.1.jar

COPY --chown=minecraft overrides server

ENV PATH="$PATH:/home/minecraft/.local/bin"

COPY ./bin/ .local/bin/

WORKDIR server

CMD exec start ./run.sh
