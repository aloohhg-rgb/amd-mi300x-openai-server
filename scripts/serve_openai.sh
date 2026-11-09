#!/usr/bin/env bash
# OpenAI-shaped server on :8000
# ENGINE=vllm|llama_cpp|sglang
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PORT="${PORT:-8000}"
HOST="${HOST:-0.0.0.0}"
ENGINE="${ENGINE:-vllm}"

log() { printf '[serve] %s\n' "$*"; }
die() { printf '[serve] ERROR: %s\n' "$*" >&2; exit 1; }

if [[ -f "${ROOT}/.venv/bin/activate" ]]; then
  # shellcheck disable=SC1091
  source "${ROOT}/.venv/bin/activate"
fi

log "ENGINE=${ENGINE} ${HOST}:${PORT}"

case "${ENGINE}" in
  vllm)
    command -v python3 >/dev/null || die "python3 missing"
    if python3 -c 'import vllm' >/dev/null 2>&1; then
      MODEL="${MODEL_ID:-Qwen/Qwen2.5-72B-Instruct}"
      log "vLLM -> ${MODEL}"
      # FIXME: some ROCm builds want different flags; revisit after first boot
      exec python3 -m vllm.entrypoints.openai.api_server \
        --model "${MODEL}" \
        --host "${HOST}" \
        --port "${PORT}" \
        --dtype auto \
        --max-model-len "${MAX_MODEL_LEN:-32768}" \
        --gpu-memory-utilization "${GPU_MEM_UTIL:-0.90}" \
        --trust-remote-code \
        ${EXTRA_VLLM_ARGS:-}
    else
      die "vllm not importable. install a ROCm build first."
    fi
    ;;
  llama_cpp)
    BIN="${LLAMA_SERVER_BIN:-llama-server}"
    [[ -n "${MODEL_PATH:-}" ]] || die "set MODEL_PATH to a .gguf"
    command -v "${BIN}" >/dev/null || die "${BIN} not in PATH"
    # TODO: expose --tensor-split if I ever touch multi-GPU again (hoping not)
    exec "${BIN}" -m "${MODEL_PATH}" --host "${HOST}" --port "${PORT}" \
      -ngl "${N_GPU_LAYERS:-999}" -c "${CTX_SIZE:-32768}" ${EXTRA_LLAMA_ARGS:-}
    ;;
  sglang)
    # FIXME: I copied this from upstream docs and never ran it
    MODEL="${MODEL_ID:-Qwen/Qwen2.5-72B-Instruct}"
    if python3 -c 'import sglang' >/dev/null 2>&1; then
      exec python3 -m sglang.launch_server \
        --model-path "${MODEL}" --host "${HOST}" --port "${PORT}" \
        --trust-remote-code ${EXTRA_SGLANG_ARGS:-}
    else
      die "sglang missing"
    fi
    ;;
  *)
    die "unknown ENGINE=${ENGINE}"
    ;;
esac
