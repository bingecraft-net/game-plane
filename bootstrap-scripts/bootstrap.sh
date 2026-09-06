for executable in kind kubectl; do
    if ! which $executable ; then
        echo "$executable is not installed. Please install $executable and try again."
        exit 1
    fi
done

if kind get clusters 2>&1 | grep "No kind clusters found"; then

    CLOUD_PROVIDER_KIND_VERSION="latest"

    go install "sigs.k8s.io/cloud-provider-kind@${CLOUD_PROVIDER_KIND_VERSION}"

    kind create cluster

fi

if ! kubectl get namespace argocd >/dev/null 2>&1; then
    kubectl create namespace argocd
fi

ARGO_CD_VERSION="stable"

kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/${ARGO_CD_VERSION}/manifests/install.yaml

kubectl apply -n argocd --server-side -f bootstrap-manifests