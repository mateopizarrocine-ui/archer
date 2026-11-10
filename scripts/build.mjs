#!/usr/bin/env node
// Arma el prompt final de cada sector (núcleo + sector) y, para Desk, el cuerpo del
// `RemoteTrigger update` con el job_config COMPLETO (si se manda parcial, se pisa).
//
//   node scripts/build.mjs            → arma todo en dist/
//   node scripts/build.mjs --check    → además valida (sin placeholders sueltos, largo razonable)
//
// Salidas:
//   dist/apps.txt               texto para pegar a mano en la tarea de Cowork «Archer · Apps»
//   dist/desk.txt               prompt final de «Archer · Desk»
//   dist/desk.update.json       body para RemoteTrigger update (trig_014ScCRaRYmE9Ggm7Ct5GA7G)
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const leer = (p) => readFileSync(join(ROOT, p), "utf8").trim();

export const SECTORES = {
  apps: { sector: "APPS", firma: "Archer · Apps" },
  desk: { sector: "DESK", firma: "Archer · Desk" },
};

export function armar(nombre) {
  const s = SECTORES[nombre];
  if (!s) throw new Error("Sector desconocido: " + nombre);
  const texto = leer("prompts/core.md") + "\n\n" + leer(`prompts/${nombre}.md`) + "\n";
  return texto.replaceAll("{{SECTOR}}", s.sector).replaceAll("{{FIRMA}}", s.firma);
}

export function cuerpoDesk(prompt) {
  const c = JSON.parse(leer("state/desk.config.json"));
  return {
    job_config: {
      ccr: {
        environment_id: c.environment_id,
        events: [{
          data: {
            message: { content: prompt, role: "user" },
            parent_tool_use_id: null,
            session_id: "",
            type: "user",
            uuid: c.event_uuid,
          },
        }],
        session_context: c.session_context,
      },
    },
  };
}

function validar(nombre, texto) {
  const errores = [];
  const sueltos = texto.match(/\{\{[A-Z_]+\}\}/g);
  if (sueltos) errores.push("placeholders sin reemplazar: " + [...new Set(sueltos)].join(", "));
  if (texto.length < 2000) errores.push("prompt sospechosamente corto (" + texto.length + ")");
  if (texto.length > 60000) errores.push("prompt demasiado largo (" + texto.length + ")");
  const firma = SECTORES[nombre].firma;
  if (!texto.includes(`"username": "${firma}"`)) errores.push("la firma de Slack no es " + firma);
  return errores;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const check = process.argv.includes("--check");
  mkdirSync(join(ROOT, "dist"), { recursive: true });
  let mal = 0;
  for (const nombre of Object.keys(SECTORES)) {
    const texto = armar(nombre);
    writeFileSync(join(ROOT, `dist/${nombre}.txt`), texto);
    if (nombre === "desk") writeFileSync(join(ROOT, "dist/desk.update.json"), JSON.stringify(cuerpoDesk(texto), null, 2) + "\n");
    const errores = check ? validar(nombre, texto) : [];
    errores.forEach((e) => console.error(`✗ ${nombre}: ${e}`));
    mal += errores.length;
    console.log(`${errores.length ? "✗" : "✓"} ${nombre}: ${texto.length} caracteres → dist/${nombre}.txt`);
  }
  console.log("✓ desk: body de RemoteTrigger update → dist/desk.update.json");
  process.exit(mal ? 1 : 0);
}
