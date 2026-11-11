# Archer · la casa del agente operativo de Cáscara Collective

Archer es UN solo agente con dos sectores que no se pisan:

| Sector | Qué cuida | Dónde corre | Firma en Slack |
|---|---|---|---|
| **Archer · Apps** | Founders App, La Cáscara APP, landings, pedidos de Facu, salud de los sitios | Rutina de Claude Code en la nube `trig_018kpSkXfV2Fv7hymCoLBznB` (en vivo con pedidos de #operaciones-cáscara + lun–vie cada 2 h, 7:59–19:59 ARG). Reemplaza a la tarea de Cowork `trig_011P71GnrgQUFeargBjxrStW` | «Archer · Apps» · publica el resumen diario |
| **Archer · Desk** | DESK (desk.cascaraco.com, repo cascara-hq): reportes del equipo, datos puntuales y PRs en ramas `archer/*` | Rutina de Claude Code en la nube `trig_014ScCRaRYmE9Ggm7Ct5GA7G` (en vivo + lun–vie cada 2 h, 8:30–18:30 ARG) | «Archer · Desk» · sin resúmenes |

Este repo es **la fuente de verdad del prompt de cada sector**. Nadie edita el prompt desde claude.ai ni desde Cowork: se edita acá, se versiona, y se despliega.

Teo (operaciones, no técnico en lo cotidiano) es el dueño. Escribile simple, en rioplatense, corto. **Teo corre todos los comandos git a mano**: entregale el comando, no lo ejecutes.

## Dónde le habla Archer a Teo

- **Tablero** (canvas «Tablero de Archer», Slack `F0CB0F7EW9W`): lo único que Teo mira. 🔴 decidir · 🙋 hacer · 🔄 en curso · ⏳ esperando · ⏸ pausa · ⌛ vencidos · ✅ resuelto (7 días) · 🧰 para copiar · Inventario. Reglas en `prompts/core.md` («EL TABLERO»).
- **#monitor-cascara**: solo lo que cambió y alguien tiene que saber; todo en el hilo de su ítem; un resumen diario a las 19:59 (lo publica Apps). Nada de «todo OK».

## Mapa

- `prompts/core.md` — núcleo común: identidad, voz, niveles 🟢🟡🔴⚪, cómo escribe en Slack, reglas no negociables. Placeholders `{{SECTOR}}` y `{{FIRMA}}`.
- `prompts/apps.md`, `prompts/desk.md` — lo propio de cada sector.
- `scripts/build.mjs` — arma `dist/<sector>.txt` (núcleo + sector) y `dist/desk.update.json` (body completo para `RemoteTrigger update`). `--check` valida.
- `state/<sector>.config.json` — la parte fija del job_config de cada rutina (trigger, entorno, repo, herramientas, modelo, conectores).
- `docs/` — mapa de rutinas, IDs, conectores y disparadores (`docs/mapa.md`), pasos manuales para Teo (`docs/pasos-teo.md`).
- `historial/` — versiones originales de referencia.
- `.claude/commands/desplegar.md` — `/desplegar desk` o `/desplegar apps`.

## Reglas de la casa

1. **Un cambio de comportamiento = un cambio acá.** Si la regla vale para los dos sectores, va en `core.md`; si es de uno, en su archivo. Nunca dupliques una regla en los dos sectores.
2. **Los sectores no se pisan.** Todo ítem tiene un solo dueño. Lo de DESK es de Desk de punta a punta; lo demás es de Apps. Si sumás un sector nuevo, sumalo a la tabla de arriba, a `core.md` y a `SECTORES` en `scripts/build.mjs`.
3. **Desplegar** (los dos sectores): siempre con el job_config completo (si mandás parcial, se pisa). Seguí `.claude/commands/desplegar.md`.
4. **Apps se despliega igual que Desk** (rutina en la nube). La tarea vieja de Cowork no se toca por API: tiene un system prompt de ~71k caracteres que se perdería.
5. **Nada de secretos acá.** El token del disparo en vivo va directo de claude.ai a Vercel; no se pega en el chat ni en este repo.
6. **Antes de desplegar, `node scripts/build.mjs --check` tiene que dar ✓.** Después de desplegar Desk, verificá con `RemoteTrigger get` que el prompt y los conectores quedaron.
7. Lo que Archer no puede hacer (plata, borrar, esquema, permisos) no se le habilita desde un prompt sin que Teo lo pida explícitamente. Excepción pedida por Teo (12/11/2026): Archer · Desk decide solo y le pregunta a Teo únicamente lo sensible (valores, contratos, datos personales sensibles, permisos, borrar, secretos, mensajes masivos); puede sumar campos u opciones al esquema (nunca renombrar ni borrar); y sus PRs `archer/*` se publican solos con la acción «Archer · publicar PRs» de cascara-hq (sin «dale»; los borradores no salen).
