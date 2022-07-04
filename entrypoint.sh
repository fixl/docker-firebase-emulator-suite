#!/usr/bin/env bash

#set -x

if [[ -z "${FIREBASE_PROJECT_ID}" ]] ; then
    export FIREBASE_PROJECT_ID=local
    echo "Defaulting FIREBASE_PROJECT_ID to ${FIREBASE_PROJECT_ID}"
fi

if [[ -z "${FIREBASE_TOKEN}" ]] ; then
    echo "Warning: FIREBASE_TOKEN not set"
fi

echo "Generating firebase.json"

if [[ -z "${UI_PORT}" ]] ; then
    UI_PORT=4000
    echo "Defaulting UI_PORT to ${UI_PORT}"
fi

IP_ADDRESS=$(hostname -i)

# UI
CONFIG=$(echo '{}' | jq '.emulators.ui.enabled|=true' | jq ".emulators.ui.host|=\"${IP_ADDRESS}\"" | jq ".emulators.ui.port|="${UI_PORT}"")

function configure_emulator() {
    TYPE=${1}
    PORT=${2}
    CONFIG=${3}
    echo ${CONFIG} | jq ".emulators.${TYPE}.host|=\"${IP_ADDRESS}\"" | jq ".emulators.${TYPE}.port|=\"${PORT}\""
}

# Add hosting config
if [[ "${HOSTING}" == "true" || -n "${HOSTING_PORT}" ]] ; then
    CONFIG=$(configure_emulator "hosting" "${HOSTING_PORT:-5000}" "${CONFIG}")
else
    echo "Skipping hosting. Set HOSTING to 'true' or HOSTING_PORT."
fi

# Add functions config
if [[ "${FUNCTIONS}" == "true" || -n "${FUNCTIONS_PORT}" ]] ; then
    CONFIG=$(configure_emulator "functions" "${FUNCTIONS_PORT:-5001}" "${CONFIG}")
else
    echo "Skipping functions. Set FUNCTIONS to 'true' or FUNCTIONS_PORT."
fi


# Add firestore config
if [[ "${FIRESTORE}" == "true" || -n "${FIRESTORE_PORT}" ]] ; then
    CONFIG=$(configure_emulator "firestore" "${FIRESTORE_PORT:-8081}" "${CONFIG}")
else
    echo "Skipping firestore. Set FIRESTORE to 'true' or FIRESTORE_PORT."
fi

# Add pubsub config
if [[ "${PUBSUB}" == "true" || -n "${PUBSUB_PORT}" ]] ; then
    CONFIG=$(configure_emulator "pubsub" "${PUBSUB_PORT:-8085}" "${CONFIG}")
else
    echo "Skipping pubsub. Set PUBSUB to 'true' or PUBSUB_PORT."
fi

# Add database config
if [[ "${DATABASE}" == "true" || -n "${DATABASE_PORT}" ]] ; then
    CONFIG=$(configure_emulator "database" "${DATABASE_PORT:-9000}" "${CONFIG}")
else
    echo "Skipping database. Set DATABASE to 'true' or DATABASE_PORT."
fi

# Add auth config
if [[ "${AUTH}" == "true" || -n ${AUTH_PORT} ]] ; then
    CONFIG=$(configure_emulator "auth" "${AUTH_PORT:-9099}" "${CONFIG}")
else
    echo "Skipping auth. Set AUTH to 'true' or AUTH_PORT."
fi

# Add storage config
if [[ "${STORAGE}" == "true" || -n ${STORAGE_PORT} ]] ; then
    CONFIG=$(configure_emulator "storage" "${STORAGE_PORT:-9199}" "${CONFIG}")
    CONFIG=$(echo ${CONFIG} | jq '.storage.rules|="/storage.rules"')
else
    echo "Skipping storage. Set STORAGE to 'true' or STORAGE_PORT."
fi


#echo "Configuration"
echo ${CONFIG} > firebase.json
cat firebase.json | jq '.'

echo "firebase --project ${FIREBASE_PROJECT_ID} $@"
exec firebase --project ${FIREBASE_PROJECT_ID} $@
