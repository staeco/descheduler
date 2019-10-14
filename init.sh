#!/bin/bash

cat << EOF| kubectl apply -f -
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: descheduler-cluster-role
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "watch", "list"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list", "delete"]
- apiGroups: [""]
  resources: ["pods/eviction"]
  verbs: ["create"]
EOF

kubectl create sa descheduler-sa -n kube-system

kubectl create clusterrolebinding descheduler-cluster-role-binding \
    --clusterrole=descheduler-cluster-role \
    --serviceaccount=kube-system:descheduler-sa

kubectl delete configmap descheduler-policy-configmap -n kube-system
kubectl create configmap descheduler-policy-configmap \
     -n kube-system --from-file=./examples/policy.yaml

kubectl delete job descheduler-job -n kube-system
kubectl apply -f cron.yaml
