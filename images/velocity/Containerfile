FROM ubuntu:noble

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl openjdk-21-jdk zsh && \
    apt-get clean

RUN useradd -m minecraft

USER minecraft

WORKDIR /home/minecraft/server

ARG VERSION_VELOCITY

ARG VERSION_VELOCITY_BUILD

RUN curl -sfLo velocity.jar https://api.papermc.io/v2/projects/velocity/versions/$VERSION_VELOCITY/builds/$VERSION_VELOCITY_BUILD/downloads/velocity-$VERSION_VELOCITY-$VERSION_VELOCITY_BUILD.jar

RUN mkdir plugins

RUN curl -sfLo plugins/ambassador.jar https://cdn.modrinth.com/data/cOj6YqJM/versions/YeQbhgna/Ambassador-Velocity-1.4.5-all.jar

COPY --chown=minecraft overrides .

CMD exec java -jar velocity.jar
