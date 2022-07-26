FROM alpine:3.16

ARG FIREBASE_VERSION

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
    && firebase setup:emulators:ui


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
