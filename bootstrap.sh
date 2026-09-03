cd $HOME
if [ ! -d .git ] ; then
    git init
    git remote add origin https://github.com/bingecraft-net/game-plane
    git sparse-checkout init --cone
fi
git sparse-checkout set bootstrap-manifests
git fetch origin main
git reset --hard origin/main