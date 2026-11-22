# Founders App · 4 decisiones de Teo (22/11/2026)

Supabase `hklrjudyhgprzgvfwuph` · Lovable `34de3ead-dd89-4ae6-9ef1-556c4873a2e2` (foundersapp.cascaraco.com).
Todo lo de abajo sirve para revertir. Nada se borró.

---

## 1. Onboardings que se comen el cupo de 1:1 (opción 1)

### Datos: sesiones reclasificadas `1:1` → `onboarding`
Todas eran `origen='calendar'`, dirigidas por Teo, realizadas, con resumen de onboarding.

| Cliente | Sesión | Fecha | Antes | Ahora |
|---|---|---|---|---|
| Santiago Guevara | eb374d40-2391-4648-8435-3b298ae03a62 | 23/10 | 1:1 | onboarding |
| Delfina Corsalini | ba2e707d-33ef-4186-916a-710bcfeacef3 | 05/10 | 1:1 | onboarding |
| Tomás Visser | c4021fe4-e9f1-48ab-8320-54174f3808ac | 19/10 | 1:1 | onboarding |
| Infinity Crew | e9584084-47c4-49d3-943f-28624e8dec40 | 17/11 | 1:1 | onboarding |
| Osmo Estudio · Ivi González | 8e65f4f3-7219-4ac8-8250-3d994abf915b | 02/10 | 1:1 | onboarding |

Para revertir:
```sql
update public.sesiones set tipo='1:1'
where id in ('eb374d40-2391-4648-8435-3b298ae03a62','ba2e707d-33ef-4186-916a-710bcfeacef3',
             'c4021fe4-e9f1-48ab-8320-54174f3808ac','e9584084-47c4-49d3-943f-28624e8dec40',
             '8e65f4f3-7219-4ac8-8250-3d994abf915b');
```

No tocadas (dudosas o sin efecto): Sharon Palacio db038e8b-95f4-47f9-b7a1-fb30edb4b72b (Teo, 05/10, "cerramos el proceso": es cierre, no onboarding); canceladas de Teo (no cuentan en el cupo): Marcelo Fernández 130ca001…, Scarlett Montilla c64b2fce…, Andrea Saturno 5e73fabe…, Santiago Guevara 86bd2160…, Infinity Crew e4ab0165….

### Carga: trigger nuevo en `sesiones` (migración `sesiones_onboarding_teo_desde_calendar`)
`trg_sesion_calendar_onboarding_teo` (BEFORE INSERT) → función `sesion_calendar_onboarding_teo()`: si la sesión entra con `origen='calendar'`, tipo `1:1`, dirigida por Teo (perfil mateopizarrocine@gmail.com) y el cliente todavía no tiene un onboarding no cancelado, entra como `onboarding`. La segunda llamada de Teo con el mismo cliente sigue entrando como 1:1.
El workflow de n8n «Cerebro · Calendar → sesiones» (0yZpl70v42NmMBAN) NO se tocó (ojo: tiene un borrador sin publicar con cambios de otra persona).

Para revertir:
```sql
drop trigger if exists trg_sesion_calendar_onboarding_teo on public.sesiones;
drop function if exists public.sesion_calendar_onboarding_teo();
```

---

## 2. Varias cartas a la vez: solo briefs al lado de la principal (opción 2)

### Base (migración `cartas_brief_activas_junto_a_principal`)
- Columna nueva `cartas.es_brief boolean not null default false`. Marcadas en true: `mi-editing-brief` (ce354859-4118-47bd-b0fd-9cac48b4386e), `brief-para-tu-editor` (72b09245-a099-4d23-8ce6-9993372dbc32), `mi-editing-brief--sol-boutmy` (55a9a1fe-4464-423e-aa31-95f28950a2ad).
- Función nueva `carta_es_brief(uuid)`.
- `una_activa_por_cliente()`: un brief activo no pausa a nadie; una principal pausa solo a las otras principales.
- `activar_proxima()`: los briefs activos no frenan la próxima carta principal.

Para revertir (funciones como estaban antes):
```sql
create or replace function public.una_activa_por_cliente()
returns trigger language plpgsql security definer as $function$
begin
  if new.estado = 'activa' then
    update public.asignaciones set estado = 'pausada'
    where cliente_id = new.cliente_id and id <> new.id and estado = 'activa';
  end if;
  return new;
end $function$;

create or replace function public.activar_proxima(p_cliente uuid, p_excluir uuid default null::uuid)
returns uuid language plpgsql security definer set search_path to 'public' as $function$
declare v_sig uuid;
begin
  if auth.uid() is not null and not es_equipo() then return null; end if;
  if exists (select 1 from asignaciones where cliente_id = p_cliente and estado = 'activa'
             and id is distinct from p_excluir) then return null; end if;
  select id into v_sig from asignaciones where cliente_id = p_cliente and estado = 'proxima' order by creado limit 1;
  if v_sig is null then return null; end if;
  update asignaciones set estado = 'activa', inicio = (now() at time zone 'America/Argentina/Buenos_Aires')::date where id = v_sig;
  return v_sig;
end $function$;
-- La columna es_brief y carta_es_brief() pueden quedar (no molestan). No borrar la columna sin pedirlo.
```

### App (Lovable, commit ac590ae61917f41ac5df7a485c5ef660abcfeda5, publicado)
Helper `src/lib/cartas-activas.ts` (esBrief / activaPrincipal / briefsActivos); store (activar/asignar respetan briefs); "la carta activa" en todas las pantallas = la principal; Tu carta e Inicio muestran «También activos» con link a cada brief; editor de cartas del equipo con tilde «Es brief».
Para revertir: en Lovable, volver al commit anterior a ac590ae (historial del proyecto).

---

## 3. Link a Connect Wall (opción 1)

App (Lovable, commit 4a59d28cbe408f19040a45e1cc3e05bde907a6cd, publicado):
- Menú del founder: ítem «Connect Wall» → https://cw.cascaraco.com en pestaña nueva (en celular, dentro de «Más»). `ItemNav` sumó campo opcional `href`.
- Tu carta: si la carta es «Contratar a tu editor» (`contratar-primer-rol` o su variante), caja «Para buscar a tu editor» con botón «Abrir Connect Wall».
- El HTML de la carta en sí (repo de Facu) no se tocó.

Para revertir: en Lovable, volver al commit anterior a 4a59d28.

---

## 4. Los 90 días desde la Clarity Call con Facu

### Datos: fecha de inicio corrida a la Clarity (y fecha_fin = inicio + 89, como hace la app al crear un cliente)

| Cliente | id | Clarity (sesión) | fecha_inicio antes | fecha_fin antes | fecha_inicio ahora | fecha_fin ahora |
|---|---|---|---|---|---|---|
| Carolina Lalin | 38de21e1-2088-4acb-9b56-3a6febdc8653 | dec22c8a-1fe2-4b0e-9edd-9c08a1fa013d (10/11) | 2026-10-29 | null | 2026-11-10 | 2027-02-07 |
| Alejandra Ayala | 359b4f10-9440-4a80-8121-2972c410996c | 8b2832a9-18f6-46a7-8f13-3d1280b49304 (13/11) | 2026-10-28 | null | 2026-11-13 | 2027-02-10 |
| Gabriel Pacahuala | 988edc33-1b99-4e3a-9ffe-fa0c5602046e | 263b6ae9-5627-4a42-b6ee-3a5b4b31ef47 (12/11) | 2026-10-26 | null | 2026-11-12 | 2027-02-09 |

La fecha original quedó guardada en la columna nueva `clientes.inicio_alta`.

Para revertir:
```sql
update public.clientes set fecha_inicio = inicio_alta, fecha_fin = null, inicio_alta = null
where id in ('38de21e1-2088-4acb-9b56-3a6febdc8653','359b4f10-9440-4a80-8121-2972c410996c','988edc33-1b99-4e3a-9ffe-fa0c5602046e')
  and inicio_alta is not null;
```

### Regla para nuevos (migración `programa_90_dias_desde_clarity`)
Trigger `trg_cliente_inicio_desde_clarity` (AFTER INSERT/UPDATE de estado, tipo, dirigio_id en `sesiones`) → `cliente_inicio_desde_clarity()`: cuando se registra como realizada la PRIMERA 1:1 del cliente con Facu, `fecha_inicio` pasa a ese día (hora Argentina), `inicio_alta` guarda la de antes y `fecha_fin` = inicio + 89 (solo si estaba vacía o era la estándar). Solo hacia adelante, hasta 30 días después del alta, una vez por cliente, solo Cascara Founders.

Para revertir la regla (los clientes ya movidos se revierten con el update de arriba, usando `inicio_alta`):
```sql
drop trigger if exists trg_cliente_inicio_desde_clarity on public.sesiones;
drop function if exists public.cliente_inicio_desde_clarity();
```

Qué depende de `fecha_inicio` y quedó consistente: ciclos del cupo (`cupo_sesiones`, verificado: ciclo 1 de los tres arranca en su Clarity, 1 de 2 usadas), «día N de 90», mes del programa (Tu recorrido), roadmap del equipo. Los plazos de las cartas salen de `asignaciones.inicio` (no de `fecha_inicio`) y no se tocaron. Los avisos del Cerebro en n8n no se revisaron ni tocaron.
