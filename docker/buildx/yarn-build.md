```sh
echo ">>📌 3. npm install && build"
yarn_cache="/opt/worker/modules/${CI_ENV}_yarn/${JOB_NAME}"
docker exec -i -w $PWD -u node cicd-node${ci_node_version:16}.dev bash <<EOF
set -e
export http_proxy=http://v2proxy:11100
export https_proxy=http://v2proxy:11100
ls -a && npm config list
yarn --non-interactive --cache-folder $yarn_cache
yarn run build --registry https://registry.npmmirror.com

# npm_cache="/opt/worker/modules/${CI_ENV}_npm/${JOB_NAME}"
# npm install --quiet --cache $npm_cache --registry https://registry.npmmirror.com
# npm run build --quiet
EOF
```