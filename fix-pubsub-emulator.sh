#!/usr/bin/env bash
# Fixes: https://issuetracker.google.com/issues/219992967
#
# Use latest available pubsub emulator instead of the once configured in firebase.
#
# Find the latest pubsub emulator URL at:
#
#      https://dl.google.com/dl/cloudsdk/channels/rapid/components-2.json
#

PUBSUB_URL=https://dl.google.com/dl/cloudsdk/channels/rapid/components/google-cloud-sdk-pubsub-emulator-20220722145557.tar.gz
TMP_DIR=./tmp
CACHE_DIR=/root/.cache/firebase

OLD_JAR=$(find ${CACHE_DIR} -name "*pubsub-emulator*.jar" -type f)

echo "Downloading ${PUBSUB_URL}"
curl ${PUBSUB_URL} -s -o ${TMP_DIR}/pubsub-emulator.tar.gz

pushd ${TMP_DIR} || exit
tar -xzf pubsub-emulator.tar.gz
NEW_JAR=$(find "${PWD}" -name "*.jar" -type f)
popd || exit

echo "Moving ${NEW_JAR} to ${OLD_JAR}"
mv "${NEW_JAR}" "${OLD_JAR}"

rm -rf ${TMP_DIR}/*
