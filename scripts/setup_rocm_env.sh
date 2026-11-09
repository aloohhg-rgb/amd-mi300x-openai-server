#!/usr/bin/env bash
# quick host checks before I forget what broke last time
set -euo pipefail

log() { printf '[setup] %s\n' "$*"; }
warn() { printf '[setup] WARN: %s\n' "$*" >&2; }
die() { printf '[setup] ERROR: %s\n' "$*" >&2; exit 1; }

log "host: $(uname -a || true)"

command -v python3 >/dev/null || die "need python3"
python3 -c 'import sys; assert sys.version_info >= (3, 10)' || die "python >= 3.10 please"
log "python $(python3 --version)"

if command -v rocminfo >/dev/null 2>&1; then
  log "rocminfo (trimmed):"
  rocminfo | grep -E 'Agent|Name:|Marketing Name:|Device Type:' | head -n 60 || true
else
  warn "no rocminfo — are you even on a ROCm image?"
fi

if command -v rocm-smi >/dev/null 2>&1; then
  rocm-smi || warn "rocm-smi failed"
else
  warn "no rocm-smi"
fi

# TODO: detect gfx942 specifically once I'm on real iron
if python3 -c 'import torch' >/dev/null 2>&1; then
  python3 - <<'PY'
import torch
print("[setup] torch", torch.__version__, "hip", getattr(torch.version, "hip", None))
print("[setup] device_count", torch.cuda.device_count() if torch.cuda.is_available() else 0)
if torch.cuda.is_available():
    print("[setup] device0", torch.cuda.get_device_name(0))
PY
else
  warn "torch not installed yet — grab the ROCm wheel that matches the image"
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="${ROOT}/.venv"
if [[ ! -d "${VENV}" ]]; then
  log "making venv"
  python3 -m venv "${VENV}"
fi
# shellcheck disable=SC1091
source "${VENV}/bin/activate"
pip install -q --upgrade pip wheel
# light stuff only; vLLM install is its own adventure
pip install -q 'huggingface_hub>=0.23' 'httpx>=0.27' 'pyyaml>=6.0' || warn "pip extras failed (whatever)"

log "venv ready @ ${VIRTUAL_ENV}"
log "next: install an engine, then ./scripts/serve_openai.sh"
