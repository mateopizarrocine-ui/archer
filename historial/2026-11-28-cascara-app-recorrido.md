# La Cáscara APP · recorrido (testimonio + checks + Estratega Creativo) · 28/11/2026

Pedido de Teo, armado por Archer · Apps **solo en vista previa**. Check-ins fuera (se consultan con Aye).

## Qué se tocó

- **Código:** solo dentro del borrador (draft) de Lovable `drft_01m8g4zaxre4c9w65qkw9ke2fq`
  («Recorrido: testimonio + checks + Estratega Creativo (vista previa)»), base `035546f0aed2fa40a3b22abff2811473194cfa0f`.
  La app publicada (main) no cambió. Sin deploy. Último commit del borrador: `3b192afe35581a54bd15dc0b6e67f046ca31e189`.
  Vista previa: https://id-preview-1--6e02f965-6efe-4925-abf8-566bbe487579.lovable.app/recorrido?preview=recorrido
  Archivos: nuevos `src/lib/preview-recorrido.ts` (+ test), `src/lib/checks-propuesta.ts`, `src/components/preview/{PreviewBanner,TestimonioCard,ChecksPreview,EstrategaCreativoPreview}.tsx`, `AGENTS.md`; editados `src/routes/recorrido.tsx`, `src/components/MobileApp.tsx`, `src/components/windows/RoadmapWindowBody.tsx`, `src/components/windows/ActividadContent.tsx`, `roadmap.md`. Cada cambio en un archivo existente queda detrás de la bandera.
- **Supabase (nwpusuytiagfsincbvwd):** NADA. Cero filas, cero esquema, cero funciones. Solo lecturas.
- Todo lo nuevo se ve únicamente con la bandera `?preview=recorrido` y guarda solo en el navegador (localStorage, claves `cascara:preview:*`).

## Por qué no se usaron componente / componente_check (todavía)

1. La app publicada ya lee `componente` en las actividades `mixto`/`checklist` (y en contingencia, «primer paso»). Cargar filas hoy = los alumnos las ven al instante.
2. El trigger `trg_recompute_progreso` de `componente_check` recalcula `progreso` de la actividad con el % de checks (≥70% = completa, si no `en_curso` y borra `completed_at`). Si un alumno que ya completó un formulario tilda 1 check, su actividad pasa a «en curso» y puede volver a trabar el desbloqueo de módulos. Además pelea con `trg_recompute_progreso_resp` (el de las respuestas).
3. `ChecklistView` hace upsert con la columna `checked`, pero la tabla tiene `done` (revisar `toComponenteCheckUpsertPayload` antes de usarlo).

## Cómo revertir

- Descartar el borrador en Lovable (reject_draft `drft_01m8g4zaxre4c9w65qkw9ke2fq`, o «Discard» en el editor). Main queda como estaba.
- En la base no hay nada que revertir.
- En un navegador de prueba: entrar con `?preview=off` para apagar la bandera.

## Para publicar (pendiente de Teo/Aye)

- Aye revisa la propuesta de checks (`src/lib/checks-propuesta.ts` en el borrador).
- Testimonios: hace falta un lugar en la base (propuesta: tabla `testimonio` con alumno_id, modulo_id, texto, video_url, permiso_uso, created_at + RLS «el alumno escribe/lee lo suyo, staff lee todo»). Requiere OK de Teo para cambiar esquema.
- Checks: o tabla propia (`actividad_check`), o usar componente/componente_check cambiando antes el trigger para que los checks no pisen el progreso. Requiere OK de Teo.
- Recién después: pasar el guardado de localStorage a la base, sacar la bandera, aceptar el borrador y hacer deploy.
