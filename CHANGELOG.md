# changelog

## 2026-11-09
- added smoke curl examples to README (kept forgetting the payload shape)
- FIXME in serve script: sglang path is barely tested, don't trust it yet

## 2026-11-07
- yaml config: bumped max_model_len note, 32k might be optimistic depending on residual HBM
- started benchmarks/plan.md — empty results on purpose

## 2026-11-05
- serve_openai.sh: ENGINE switch (vllm / llama_cpp / sglang)
- setup script creates venv + warns if rocminfo missing

## 2026-11-03
- initial dump. mostly README + shell stubs
