# scratch notes

- still waiting on a real MI300X box. writing this on a machine that only has CUDA drivers lol
- dual T4 was fine for Q4 12B, fell over once I tried bigger MoE + longer context
- TODO: pin exact ROCm docker tag once I know which image the cloud gives me
- TODO: write a tiny httpx harness for TTFT instead of eyeballing curl
- heard vLLM ROCm builds are picky about flash-attn; if graph capture dies, try `enforce_eager`
- don't forget HIP_VISIBLE_DEVICES=0 when someone left junk on other devices
- maybe try SGLang later. lower priority.

random thought: if 72B bf16 fits with headroom, compare same model at fp8 just for curiosity — not because I need the VRAM.
