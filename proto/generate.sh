#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SRC_DIR=${SCRIPT_DIR}/src
PROTO_DIR=${SCRIPT_DIR}/hello

[ -d ${SRC_DIR} ] || mkdir -p ${SRC_DIR} 

rm -f ${SRC_DIR}/lib.rs 

protoc --rust_out=${SRC_DIR} --grpc_out=${SRC_DIR} -I ${PROTO_DIR} --plugin=protoc-gen-grpc=`which grpc_rust_plugin` ${PROTO_DIR}/*.proto

pushd .
cd ${SRC_DIR} 

for f in *.rs; do
    while IFS='.' read mod _ ; do
        mods+=`printf "\npub mod ${mod};"`
    done <<< $f
done

cat > lib.rs << EOF
extern crate futures;
extern crate grpcio;
extern crate protobuf;
$mods
EOF

popd
