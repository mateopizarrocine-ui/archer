---
description: Despliega el prompt de un sector de Archer (apps o desk) a su rutina en la nube
argument-hint: desk | apps
---

Desplegá el sector `$ARGUMENTS` de Archer. Los dos sectores son rutinas de Claude Code en la nube y se despliegan igual.

1. Corré `node scripts/build.mjs --check`. Si falla, pará y contá qué falta.
2. Leé `state/$ARGUMENTS.config.json` (ahí está el `trigger_id`).
3. `RemoteTrigger get` de ese trigger. Compará `job_config.ccr.environment_id`, `session_context`, el `uuid` del evento y los conectores (`mcp_connections`, si el config los lista) con el config. Si alguien cambió algo desde claude.ai (repo, modelo, herramientas, conectores), actualizá el config primero y volvé al paso 1.
4. `RemoteTrigger update` con el contenido EXACTO de `dist/$ARGUMENTS.update.json` como body (job_config completo; si se manda parcial, se pisa).
5. Verificá con `RemoteTrigger get`: `derived_state.prompt` igual a `dist/$ARGUMENTS.txt` (salvo el salto de línea final), los conectores siguen, el cron y el token (`api_token_hint`) siguen.
6. Pasale a Teo el comando git para versionar (no lo corras vos):
   `cd ~/Documents/Claude/archer && git add -A && git commit -m "<sector>: <qué cambió>" && git push`

Nota: la tarea vieja de Cowork «Archer · Apps» (`trig_011P71GnrgQUFeargBjxrStW`) quedó reemplazada por la rutina en la nube. Nunca la actualices por API (su config trae un system prompt de Cowork de ~71k caracteres).
