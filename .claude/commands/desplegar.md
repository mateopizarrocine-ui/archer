---
description: Despliega el prompt de un sector de Archer (desk por API, apps a mano)
argument-hint: desk | apps
---

Desplegá el sector `$ARGUMENTS` de Archer.

1. Corré `node scripts/build.mjs --check`. Si falla, pará y contá qué falta.
2. **desk**:
   a. `RemoteTrigger get` de `trig_014ScCRaRYmE9Ggm7Ct5GA7G`. Compará `job_config.ccr.environment_id`, `session_context` y el `uuid` del evento con `state/desk.config.json`. Si alguien cambió algo desde claude.ai (repo, modelo, herramientas), actualizá `state/desk.config.json` primero y volvé al paso 1.
   b. `RemoteTrigger update` con el contenido EXACTO de `dist/desk.update.json` como body (job_config completo).
   c. Verificá con `RemoteTrigger get`: `derived_state.prompt` igual a `dist/desk.txt`, los 4 conectores (Zapier, Supabase, Airtable, Slack) siguen, el cron sigue `30 8-18/2 * * 1-5`.
   d. Pasale a Teo el comando git para versionar (no lo corras vos):
      `cd ~/Documents/Claude/archer && git add -A && git commit -m "Desk: <qué cambió>" && git push`
3. **apps**: NO uses RemoteTrigger update (se perdería el system prompt de Cowork). Abrí `dist/apps.txt` y decile a Teo: abrí Claude → Cowork → tareas programadas → «Archer · Apps» → editar → reemplazá todo el texto de las instrucciones por el de `dist/apps.txt` → guardar. Después, verificá con `RemoteTrigger get` de `trig_011P71GnrgQUFeargBjxrStW` que `derived_state.prompt` empieza con «Sos Archer, el agente operativo» y contiene «SECTOR APPS».
