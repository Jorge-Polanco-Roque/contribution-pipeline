# C011 — yt-dlp #16865 (abcotvs hqMp4 720p) — ❌ DESCARTADO por política NO AI/LLM

| Campo | Valor |
|---|---|
| Estado | **DESCARTADO (filtro 0)** — no se abre PR |
| Nicho | media/devtools (Python, downloader, 187k★) |
| Salud del repo | GO técnico (activo, welcoming a humanos) — pero **VETADO por política de IA** |
| Stack | Python |
| Origen | veta `patch-available` (#16865: bajar hqMp4 720p si el link vive, fallback a mp4 360p) |
| Política IA | ❌ **NO AI / NO LLM POLICY** estricta (CONTRIBUTING.md); PR obliga a atestiguar cumplimiento |
| Trabajo hecho | fix implementado + **verificado en vivo** (ambos casos), ruff ✓ — inenviable por el pipeline |
| Fechas | seleccionado + implementado + descartado 2026-08-30 |

## Qué se hizo (y funciona)
El extractor `abcotvs.py` solo ofrecía `mp4` (360p). Añadí, antes del mp4, un bloque que prueba `hqMp4`
(720p) con `HEADRequest` (idiom de `cbc.py`, más limpio que el probe-GET del reporter) y lo ofrece como
`https-hq` solo si responde. Verificado contra las URLs del issue:
- videoClip **19218975** (hqMp4 vivo, HEAD 200) → aparece `https-hq 1280x720` y **descarga MP4 válido**.
- videoClip **19218676** (hqMp4 muerto, HEAD 403) → **no** se ofrece, cae a `https 640x360`. Sin formato roto.
- `ruff check` limpio; `_TESTS` no se rompen (usan `skip_download`, sin aserciones de formato).

## Por qué NO se envía (la lección)
🔎 **Causa raíz — proceso:** verifiqué la política de IA **al armar el PR**, no **al seleccionar**. yt-dlp
prohíbe explícitamente contribuciones asistidas por IA/LLM y el template obliga a marcar una casilla de
cumplimiento. Enviar trabajo hecho por un LLM marcando esa casilla = **atestación falsa** bajo la cuenta del
accionista → riesgo de flag/ban → **resta reputación** (justo lo contrario del objetivo). Es el caso **servo**
otra vez. 🛠️ **Regla:** para todo repo nuevo, el PRIMER paso es `grep -riE "\bAI\b|LLM" CONTRIBUTING.md .github/`
(o `recon profile`); si prohíbe IA → STOP, ni se clona. yt-dlp vetado en SOUL §5.

## Nota
El fix es correcto y está listo en `/Users/antm/Desktop/AnatemaBot/yt-dlp-work` (rama sin crear). Si el
accionista, **como humano**, quisiera retomar el patch original del reporter por su cuenta, es su decisión;
el pipeline (IA) no puede producirlo para este repo.
