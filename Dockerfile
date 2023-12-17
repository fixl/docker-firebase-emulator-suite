FROM openjdk:11-slim-bullseye

ARG FIREBASE_VERSION
ARG NODE_VERSION

RUN apt-get update -y  \
        && apt-get dist-upgrade -y \
        && apt-get install -y \
            make \
            bash \
            jq \
            curl \
            wget \
            ca-certificates \
            gnupg \
        && mkdir -p /etc/apt/keyrings \
        && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
        && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
        && apt-get update -y \
        && apt-get install -y nodejs \
        && npm install -g firebase-tools@${FIREBASE_VERSION} \
        && mkdir -p /data \
        && firebase setup:emulators:database \
        && firebase setup:emulators:firestore \
        && firebase setup:emulators:pubsub \
        && firebase setup:emulators:storage \
        && firebase setup:emulators:ui \
        && rm -rf /var/lib/apt/lists/*


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
