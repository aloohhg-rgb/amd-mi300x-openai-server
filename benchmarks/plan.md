# bench ideas (not run yet)

Wanna know, roughly:

1. tok/s at concurrency 1 / 4 / 16
2. TTFT under light vs loaded queue
3. does 32k context actually fit for the model I pick
4. vLLM vs llama.cpp on the same weights family (if licenses allow)

Models I'll probably try first:
- something ~27B instruct (fast iterate)
- a 70B-class if HBM is as roomy as the datasheet says
- maybe a MoE with small active params

No numbers here until I actually run things. Empty `results/` is intentional.

## checklist for "ok this works"

- [ ] setup script sees the GPU
- [ ] at least one engine answers `/v1/chat/completions`
- [ ] write down ROCm version + any weird env vars that were required
- [ ] dump raw logs into results/ (gitignored for now)
