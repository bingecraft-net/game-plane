for executable in git kind kubectl; do
    if ! which $executable ; then
        echo "$executable is not installed. Please install $executable and try again."
        exit 1
    fi
done

cd $HOME
if [ ! -d .git ] ; then
    git init
    git remote add origin https://github.com/bingecraft-net/game-plane
    git sparse-checkout init --cone
fi
git sparse-checkout set bootstrap-manifests
git fetch origin main
git reset --hard origin/main

if kind get clusters 2>&1 | grep "No kind clusters found"; then
    kind create cluster
fi

if ! kubectl get namespace argocd >/dev/null 2>&1; then
    kubectl create namespace argocd
fi

ARGO_CD_VERSION="stable"

kubectl apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/${ARGO_CD_VERSION}/manifests/install.yaml

kubectl apply -n argocd --server-side -f bootstrap-manifests/bootstrap.yaml