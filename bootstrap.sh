for executable in git kind kubectl argocd; do
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

# todo pin the version
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml