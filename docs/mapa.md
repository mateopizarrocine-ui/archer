# Mapa de Archer · rutinas, IDs, conectores y disparadores

## Rutinas

### Archer · Desk
- ID: `trig_014ScCRaRYmE9Ggm7Ct5GA7G` · https://claude.ai/code/routines/trig_014ScCRaRYmE9Ggm7Ct5GA7G
- Tipo: Claude Code en la nube, repo `mateopizarrocine-ui/cascara-hq`, entorno `env_011jX1LSjZBh3oioAoL6Yiuc`, modelo `claude-opus-5-5`.
- Herramientas: Bash, Read, Write, Edit, Glob, Grep, WebFetch.
- Conectores: Zapier, Supabase, Airtable, Slack.
- Disparadores:
  1. **Horario** (red de seguridad): `CRON_TZ=America/Argentina/Buenos_Aires 30 8-18/2 * * 1-5`.
  2. **API · en vivo**: `POST https://api.anthropic.com/v1/claude_code/routines/trig_014ScCRaRYmE9Ggm7Ct5GA7G/fire`, headers `Authorization: Bearer <token>`, `anthropic-version: 2023-06-01`, body `{"text": "reporte_nuevo · hq_feedback id <uuid> · tipo <tipo>"}`. Lo llama DESK desde `api/supabase.js` (`fbArcher`, después de publicar el reporte en Slack). Token en Vercel como `ARCHER_DESK_FIRE_TOKEN`. Límite: 30 disparos por hora por rutina (compartido con «Run now»), 100 por hora por cuenta. Cada disparo = una sesión nueva. Experimental.
  3. **GitHub · PR mergeado**: `pull_request.closed`, filtro «Is merged = true» y «Head branch starts with archer/», repo cascara-hq. Requiere la app de Claude en GitHub instalada en el repo. (Se configura desde la web, ver `pasos-teo.md`.)
- Modos del prompt: A en vivo (solo el ítem del payload), B PR cerrado (revisa merges y hace pasada), C pasada programada.
- No duplicar: cada corrida «toma» el reporte con un update atómico que escribe `contexto.archer_toma` (vale 45 min). Si otra corrida ya lo tomó, no lo toca.

### Archer · Apps (ex «Monitor Cáscara»)
- ID: `trig_018kpSkXfV2Fv7hymCoLBznB` · https://claude.ai/code/routines/trig_018kpSkXfV2Fv7hymCoLBznB · rutina de Claude Code en la nube (desde el 10/11/2026), repo `archer` como carpeta de arranque, entorno `env_011jX1LSjZBh3oioAoL6Yiuc`.
- Conectores: Slack, Zapier, Supabase, Airtable, Lovable, Netlify, n8n (lista fija en `state/apps.config.json`).
- Disparadores:
  1. **Horario**: `CRON_TZ=America/Argentina/Buenos_Aires 59 7-19/2 * * 1-5`. La pasada de las 19:59 publica el resumen diario.
  2. **API · en vivo**: lo llama el workflow de Zapier «Archer · Apps en vivo (#operaciones-cáscara)» (`01a1c4a8-752b-7e6a-a2e9-0ce0c75aa5a5`, privado, https://zapier.com/workflow/01a1c4a8-752b-7e6a-a2e9-0ce0c75aa5a5): cada mensaje nuevo de Facu o Aye en #operaciones-cáscara (no respuestas en hilo, no bots) → `{"text": "pedido_nuevo · canal C0C4VG94HFH · ts <ts>"}`. El token NO está en el código: vive en la conexión de Zapier «API by Zapier» (`02d17ef4-d3f0-834e-bf94-5e85f5cafc18`, Static Headers `Authorization: Bearer …` + `anthropic-version: 2023-06-01`, dominio api.anthropic.com). Si se regenera el token, se actualiza ahí con «Replace credential».
- Ojo: agregar o editar un disparador desde la web de claude.ai puede borrar el horario (pasó el 10/11). Después de tocar disparadores en la web, verificar `cron_expression` con `RemoteTrigger get`.
- La tarea vieja de Cowork `trig_011P71GnrgQUFeargBjxrStW` quedó **pausada** (respaldo). Nunca actualizarla por API (system prompt de Cowork de ~71k caracteres).

## IDs que usan los prompts

| Qué | ID |
|---|---|
| Slack #monitor-cascara (privado) | `C0C9ZSU166P` |
| Slack #operaciones-cáscara (privado) | `C0C4VG94HFH` |
| Canvas «Tablero de Archer» (ex «Decisiones para Teo») | `F0CB0F7EW9W` |
| Teo / Facu / Aye (Slack) | `U09JX0ZS08N` / `U08QM60TVFC` / `U0C3L3ZTV38` |
| Bot Archer (Slack) | `B0C5ESHP56Y` |
| Zapier · conexión Slack del bot | `02be5195-97ba-8c1c-b4a4-cb64747819dc` (SlackCLIAPI, `private_channel_message`) |
| Supabase v3 + DESK (`hq_feedback`) | `nwpusuytiagfsincbvwd` |
| Supabase Founders App | `hklrjudyhgprzgvfwuph` |
| Airtable Cascara Base | `appPfeNtFS0dCMfPQ` |

## Cómo llega un reporte de DESK a Archer

1. Alguien carga un reporte en DESK → `api/supabase.js` inserta en `hq_feedback` (estado `nuevo`).
2. `fbSlack` publica el mensaje raíz en #monitor-cascara («📥 Desk …» o «🏹 Archer escala a Teo …», termina con `id <uuid>`).
3. `fbArcher` dispara la rutina con el id (si hay token; 4 s de tope; nunca bloquea).
4. Archer · Desk (modo A) lee el reporte por id, lo toma, lo resuelve o abre PR y contesta en el hilo como «Archer · Desk».
5. Si el disparo falló, la pasada de cada 2 h lo encuentra igual.
6. Cuando Teo mergea un PR `archer/*`, GitHub dispara la rutina (modo B), que verifica en producción y avisa.
