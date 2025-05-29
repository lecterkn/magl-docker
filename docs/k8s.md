# Kubernetes

ローカル環境で構築する

## クラスタ

### 1. ローカルでクラスタ作成

```sh
kind create cluster --name dev-cluster
```

### 2. 接続確認

```sh
kubectl cluster-info --context kind-dev-cluster
```

## Pod
