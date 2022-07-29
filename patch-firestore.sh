#!/usr/bin/env bash
# Inspired by: https://github.com/firebase/firebase-tools/issues/3837#issuecomment-963389118

set -x

JADX_BIN=$(find / -name "jadx" -type f)
FIRESTORE_FILE=$(find ${PWD} -name "*firestore-emulator*.jar" -type f)
FIRESTORE_PATCHED_FILE=$(PWD)/firestore-emulator-patched.jar
BUILD_DIR=/build
JAVA_FILE=java/com/google/cloud/datastore/emulator/firestore/CloudFirestore.java

mkdir -p ${BUILD_DIR}/{classes,java}

pushd ${BUILD_DIR} || exit

unzip "${FIRESTORE_FILE}" com/google/cloud/datastore/emulator/firestore/CloudFirestore\* -d classes
${JADX_BIN} -ds java classes/com/google/cloud/datastore/emulator/firestore/*

# fix file
sed -i -e '/int websocketPort = findOpenPort();/r ../patch.txt' ${JAVA_FILE}
sed -i -e '/@VisibleForTesting$/d' ${JAVA_FILE}
sed -i -e '/^import com.google.common.annotations.VisibleForTesting;$/d' ${JAVA_FILE}
sed -i -e '/^import com.google.firestore.v1.FirestoreGrpc;$/d' ${JAVA_FILE}
sed -i -e '/^import com.google.firestore.v1beta1.FirestoreGrpc;$/d' ${JAVA_FILE}
sed -i -e 's/FirestoreGrpc.FirestoreStub firestorev1Stub = FirestoreGrpc.newStub(channel);/com.google.firestore.v1.FirestoreGrpc.FirestoreStub firestorev1Stub = com.google.firestore.v1.FirestoreGrpc.newStub(channel);/g' ${JAVA_FILE}
sed -i -e 's/FirestoreGrpc.FirestoreStub firestorev1beta1Stub = com.google.firestore.v1beta1.FirestoreGrpc.newStub(channel);/com.google.firestore.v1beta1.FirestoreGrpc.FirestoreStub firestorev1beta1Stub = com.google.firestore.v1beta1.FirestoreGrpc.newStub(channel);/g' ${JAVA_FILE}

javac -verbose -cp "${FIRESTORE_FILE}" ${JAVA_FILE}

pushd java || exit

cp "${FIRESTORE_FILE}" "${FIRESTORE_PATCHED_FILE}"

zip "${FIRESTORE_PATCHED_FILE}" com/google/cloud/datastore/emulator/firestore/*.class
