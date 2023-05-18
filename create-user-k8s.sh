#!/bin/bash

USERNAME=${1}
K8SGROUP=${2}
USERPATH="./users/${USERNAME}"

if [ -z ${USERNAME} ]; then
    echo "Username is required."
    echo "Usage: $0 <username> <k8s group>"
    exit 1
fi

if [ -z ${K8SGROUP} ]; then
    echo "K8s group is required."
    echo "Usage: $0 <username> <k8s group>"
    exit 1
fi

if [ -d ${USERPATH} ]; then
    echo "User already exists."
    exit 1
else
    mkdir -p ${USERPATH}
fi

openssl genrsa -out ${USERPATH}/${USERNAME}.key 4096
openssl req -new -key ${USERPATH}/${USERNAME}.key -out ${USERPATH}/${USERNAME}.csr -subj "/CN=${USERNAME}/O=${K8SGROUP}"

cp ./templates/signing-request-template.yaml ${USERPATH}/${USERNAME}-signing-request.yaml
sed -i "s@__USERNAME__@${USERNAME}@" ${USERPATH}/${USERNAME}-signing-request.yaml
sed -i "s@__K8SGROUP__@${K8SGROUP}@" ${USERPATH}/${USERNAME}-signing-request.yaml

B64=`cat ${USERNAME}.csr | base64 | tr -d '\n'`
sed -i "s@__CSRREQUEST__@${B64}@" ${USERPATH}/${USERNAME}-signing-request.yaml

kubectl create -f ${USERPATH}/${USERNAME}-signing-request.yaml
kubectl certificate approve ${USERNAME}-csr

KEY=`cat ${USERNAME}.key | base64 | tr -d '\n'`
CERT=`kubectl get csr ${USERNAME}-csr -o jsonpath='{.status.certificate}'`

echo -n "client-key-data: "
echo ${KEY}
echo

echo -n "client-certificate-data: "
echo ${CERT}
echo
