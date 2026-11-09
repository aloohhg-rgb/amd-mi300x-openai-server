# amd-mi300x-openai-server

Messing around with an OpenAI-compatible LLM server on a big AMD GPU (Instinct MI300X / ROCm).

I got tired of juggling two T4s (~32GB split) just to keep a mid-size model alive. Tensor split works… until it doesn't, and then you're debugging RCCL instead of the model. Single card with a ton of HBM sounded nicer, so this repo is my notes + scripts for that.

**Status:** scaffold / WIP. I haven't actually sat on an MI300X yet — still waiting on access. Scripts are written against upstream ROCm docs and will probably need tweaks on day one.

## what this is

- `scripts/setup_rocm_env.sh` — sanity checks (`rocminfo`, `rocm-smi`, venv)
- `scripts/serve_openai.sh` — start vLLM / llama.cpp / SGLang on port 8000
- `configs/example_vllm.yaml` — starting knobs for a ~70B-ish load on one card
- `benchmarks/plan.md` — what I want to measure once hardware exists
- `docs/notes.md` — random gotchas I bump into

Not shipping weights. Grab stuff from Hugging Face yourself.

## quick start (whenever I get a ROCm box)

```bash
git clone https://github.com/aloohhg-rgb/amd-mi300x-openai-server.git
cd amd-mi300x-openai-server
chmod +x scripts/*.sh
./scripts/setup_rocm_env.sh

export MODEL_ID="Qwen/Qwen2.5-72B-Instruct"
./scripts/serve_openai.sh   # ENGINE=vllm by default

curl -s http://127.0.0.1:8000/v1/models | head
```

GGUF path if I'm feeling llama.cpp that day:

```bash
export ENGINE=llama_cpp
export MODEL_PATH=/path/to/model.Q4_K_M.gguf
export LLAMA_SERVER_BIN=llama-server
./scripts/serve_openai.sh
```

Don't commit tokens. Env vars only.

## why MI300X

192GB HBM3 on one chip. That's enough to stop babysitting layer splits for the models I care about (Gemma-ish MoE, Qwen ~27–70B). I'm curious whether vLLM or a HIP llama-server feels better for plain `/v1/chat/completions` local API work.

## related junk

- [amd-mi300x-finetune-lab](https://github.com/aloohhg-rgb/amd-mi300x-finetune-lab) — LoRA experiments (also WIP)
- [amd-rocm-benchkit](https://github.com/aloohhg-rgb/amd-rocm-benchkit) — tiny ROCm health probes

## license

MIT — see LICENSE. Not affiliated with AMD; just tinkering.
