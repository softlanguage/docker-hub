# start_llama.vscode.sh
# for llama-vscode extension in VsCode
set -e
printf '
llama-vscode from ggml.ai
Here are recommended settings, depending on the amount of VRAM that you have:

More than 16GB VRAM:
llama-server --fim-qwen-7b-default

Less than 16GB VRAM:
llama-server --fim-qwen-3b-default

Less than 8GB VRAM:
llama-server --fim-qwen-1.5b-default

llama-server \
    --hf-repo qwen/Qwen2.5-Coder-1.5B-Q8_0-GGUF \
    --hf-file qwen2.5-coder-1.5b-q8_0.gguf \
    --port 8012 -ngl 99 -fa -u
'

# openssl rand -base64 32
# --api-key KEY, API key to use for authentication (default: none)
export LLAMA_API_KEY=""
# --cache-resuse=0.default
export LLAMA_ARG_ALIAS="qwen2.5-coder-7b"
export LLAMA_ARG_ALIAS="qwen2.5-coder-7b"
# --cache-resuse=0.default
export LLAMA_ARG_CACHE_REUSE=256
# b 1024 -b 1024 -dt 0.1 \
    --cache-reuse 256
# https://modelscope.cn/models/Qwen/Qwen2.5-Coder-7B-Instruct-GGUF/files

nohup llama-server -m $cwd/models/qwen2.5-coder-7b-instruct-q6_k.gguf -ngl 99 --host 0.0.0.0 --port 8012 \
            > $(realpath $0).log 2>&1 & disown

printf "
https://github.com/ggml-org/llama.vscode
The plugin requires FIM-compatible models: HF collection
    https://huggingface.co/collections/ggml-org/llamavim-6720fece33898ac10544ecf9

$(ifconfig eth0|grep inet)
http://0.0.0.0:8012
tail -f start_codellama-7b-python.sh.log
"
