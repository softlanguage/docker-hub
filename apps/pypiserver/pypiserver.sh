set -e 

# docker run -p 80:8080 -v ~/packages:/data/packages pypiserver/pypiserver:latest run
# docker run -p 80:8080 -v ~/.htpasswd:/data/.htpasswd pypiserver/pypiserver:latest run -P .htpasswd packages

pip install pypiserver                # Or: pypiserver[passlib,cache]
mkdir ~/packages                      # Copy packages into this directory.

pypi-server run -p 8080 ~/packages &      # Will listen to all IPs.

cat <<///readme
# Download and install hosted packages.
pip install --extra-index-url http://localhost:8080/simple/ ...

# or
pip install --extra-index-url http://localhost:8080 ...

# Search hosted packages.
pip search --index http://localhost:8080 ...

# Note that pip search does not currently work with the /simple/ endpoint.

usage: pypi-server [-h] [-v] [--log-file FILE] [--log-stream STREAM]
                  [--log-frmt FORMAT] [--hash-algo HASH_ALGO]
                  [--backend {auto,simple-dir,cached-dir}] [--version]
                  {run,update} ...
///readme