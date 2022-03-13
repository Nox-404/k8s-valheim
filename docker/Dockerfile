FROM steamcmd/steamcmd:alpine-3 AS steamcmd

ENV APP_ID="896660"

RUN steamcmd +force_install_dir /valheim +login anonymous +app_update ${APP_ID} +quit

FROM alpine:3 AS runtime

ARG GLIBC_VERSION="2.34-r0"

# Use built glib as gcompat is not enough
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk \
 && apk --no-cache add glibc-${GLIBC_VERSION}.apk glibc-bin-${GLIBC_VERSION}.apk tini \
 && rm glibc*.apk /etc/apk/keys/sgerrand.rsa.pub \
 && apk del libc-utils

# Add user
RUN addgroup -S -g 1000 valheim && adduser -S -u 1000 -h /valheim -G valheim valheim

COPY --from=steamcmd --chown=valheim:valheim /valheim /valheim
USER valheim
WORKDIR /valheim

ENV LD_LIBRARY_PATH="./linux64:${LD_LIBRARY_PATH}" \
    SteamAppId="892970" \
    SERVER_NAME="Valheim Server" \
    SERVER_WORLD_NAME="world" \
    SERVER_PASSWORD="Password" \
    SERVER_PORT="2456" \
    SERVER_PUBLIC="1"

EXPOSE 2456-2457/udp
STOPSIGNAL SIGINT

COPY --chown=valheim:valheim valheim.sh /valheim

CMD [ "./valheim.sh" ]

VOLUME /valheim/saves
