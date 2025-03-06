# start.sh
#nohup "$APP_COMMAND" > "$LOG_FILE" 2>&1 & disown
#alias start_ollama='systemd-run --scope -p MemoryMax=50G bash -e /data/ollama/start.sh'
set -e

export OLLAMA_HOST=0.0.0.0:11434
export OLLAMA_MODELS=/data/ollama/models
# https://github.com/ollama/ollama-python
# https://github.com/ollama/ollama/blob/main/docs/faq.md
export OLLAMA_NUM_PARALLEL=16
export OLLAMA_MAX_LOADED_MODELS=16

# disable proxy
export no_proxy= 
export ftp_proxy= 
export https_proxy= 
export http_proxy=

# set proxy
no_proxy=10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,localhost,127.0.0.0/8,::1
ftp_proxy=http://tinyproxy.v2ray:8888
https_proxy=http://tinyproxy.v2ray:8888
http_proxy=http://tinyproxy.v2ray:8888

# apt install tinyproxy # nginx as agent of tinyproxy
# vim /etc/tinyproxy/tinyproxy.conf Port=8888, Listen 127.0.0.1

nohup ollama serve > $(realpath $0).log 2>&1 & disown

printf "\nOLLAMA_MODELS=${OLLAMA_MODELS}\nhttp://${OLLAMA_HOST}\n\n"
# https://github.com/ollama/ollama-python

# Example usage (commented out):
# ollama run llama3
# >>> /set parameter num_thread 16 (Set parameter 'num_thread' to '16')
# >>> why is the sky blue? (What a great question!)
