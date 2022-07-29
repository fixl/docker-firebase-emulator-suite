FROM node:16-alpine as downloader

ARG FIREBASE_VERSION

RUN npm install -g firebase-tools@${FIREBASE_VERSION} \
    && firebase setup:emulators:firestore \
    && find / -name "*firestore-emulator*" -type f -exec cp {} /firestore-emulator.jar \;

FROM openjdk:11-slim-bullseye as builder

ENV JADX_VERSION=1.4.3

RUN apt-get update && apt-get install -y \
    curl \
    bash \
    zip \
    unzip \
    sed

RUN mkdir /jadx \
    && cd /jadx \
    && curl -L https://github.com/skylot/jadx/releases/download/v${JADX_VERSION}/jadx-${JADX_VERSION}.zip -o jadx.zip \
    && unzip jadx.zip

COPY --from=downloader /firestore-emulator.jar /

COPY patch-firestore.sh /patch-firestore.sh
COPY patch.txt /patch.txt

RUN bash /patch-firestore.sh

FROM alpine:3.16

ARG FIREBASE_VERSION

COPY --from=builder /firestore-emulator-patched.jar /

RUN apk add --no-cache \
        make \
        bash \
        jq \
        openjdk11-jre-headless \
        nodejs \
        npm \
    && npm install -g firebase-tools@${FIREBASE_VERSION} \
    && mkdir -p /data \
    && firebase setup:emulators:database \
    && firebase setup:emulators:firestore \
    && firebase setup:emulators:pubsub \
    && firebase setup:emulators:storage \
    && firebase setup:emulators:ui \
    && find / -name "*firestore-emulator*" -type f -exec cp /firestore-emulator-patched.jar {} \;

ENV FIREBASE_PROJECT_ID=
# Required for some cli operations:  https://firebase.google.com/docs/cli#cli-ci-systems
ENV FIREBASE_TOKEN=

EXPOSE 4000 5000 5001 8080 8085 9000 9099

# 9005 is used by `firebase login:ci`
EXPOSE 9005

COPY entrypoint.sh /entrypoint.sh
COPY storage.rules /storage.rules

ENTRYPOINT ["/entrypoint.sh"]

VOLUME ["/data"]

# Run emulators by default
CMD ["--non-interactive", "emulators:start", "--import", "/data/saved-data", "--export-on-exit"]
