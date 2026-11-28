# 2026-11-28 · CascarApp · ventana de alumnos para los alumnos de la v2 (PR #58)

Migración: `supabase/migrations/20261126000100_cascarapp_ventana_clientes.sql` (rama `servicio/ventana-alumnos-v2`).
Proyecto Supabase: nwpusuytiagfsincbvwd. Ventana: desde 2026-11-23T03:00Z, hasta 2026-12-03T03:00Z (2-12 23:59 ARG).
Pruebas: `node supabase/tests/ventana.mjs` → 22 ok, 0 fallas (corrida local el 28-11, 03:29 UTC).

## Antes (respaldo)

- Cuentas con `prueba_hasta = hasta` de la ventana antes de aplicar: 48.
- Alumnos v3 pendientes de estirar: 0.
- Cuentas que cambian (clientes de Airtable con prueba de cliente, sin plan completo, no equipo, prueba vencida o antes del cierre): **25**.

### id y prueba_hasta de esas 25 cuentas (antes)

| id | prueba_hasta antes |
|---|---|
| 00caf8cd-ebe5-4cf6-b80b-cd96561533f8 | 2026-11-18T14:38:39.990343+00:00 |
| 1f102455-9ebc-4822-a439-174f36dae1d6 | 2026-11-22T16:54:02.365165+00:00 |
| 387596f1-22fa-4181-b0bf-5b93937e2363 | 2026-11-24T14:04:28.56065+00:00 |
| 3a7c6597-fc78-4e6e-9155-c8545ab9c116 | 2026-11-22T11:56:13.110494+00:00 |
| 457ca19d-b116-4892-bad3-4114c88795a8 | 2026-11-25T22:40:36.773116+00:00 |
| 48023a29-2a87-4e5c-bc42-1a3a15edfb29 | 2026-11-18T14:32:19.484732+00:00 |
| 5935dfcc-c6d7-4f78-baa0-4c0ee398a82c | 2026-11-19T19:43:02.770479+00:00 |
| 5c9a4e35-53ca-4764-808b-3710d31742c3 | 2026-11-25T21:39:19.587446+00:00 |
| 643b4d22-e9aa-4277-bba6-b36521595287 | 2026-11-18T14:34:25.548191+00:00 |
| 6fcf985a-a05f-4484-85f8-6e453da13663 | 2026-11-18T14:32:59.785617+00:00 |
| 7b117ecc-b4f0-42df-a775-cf2aa391eac4 | 2026-11-25T16:43:35.122604+00:00 |
| 8d75ec08-1b66-479f-9469-7667eac91569 | 2026-11-21T15:34:50.710002+00:00 |
| 90512103-af90-4ca4-9795-e23e6ccff32b | 2026-12-02T12:50:16.817086+00:00 |
| a20685a6-ed6d-4a7d-aab3-cc02ac7caf23 | 2026-11-24T22:09:23.263178+00:00 |
| a3c3cc34-7cd6-4d8f-a278-1a7567d76f5a | 2026-11-18T14:32:39.633109+00:00 |
| a9c88d7f-5209-4bdd-b94a-12a74bc4a656 | 2026-11-24T21:45:18.529298+00:00 |
| c9f8f96c-fc32-4e23-bac1-0b1f243f1302 | 2026-11-27T22:21:00.465144+00:00 |
| ccbe276e-9bb4-489d-9e87-d4603d1bda68 | 2026-11-18T14:34:15.156696+00:00 |
| d192b3ea-5cfb-43a2-8ea4-11d3e596d42c | 2026-11-19T18:28:16.959308+00:00 |
| da55bb58-b0dd-4b11-ae95-4050dfc026de | 2026-11-20T04:14:10.315808+00:00 |
| e69a3e72-a945-42ad-9632-1e0d528f9359 | 2026-11-18T14:34:45.335587+00:00 |
| ebf611ff-0131-46e7-b009-85af12ffe939 | 2026-11-26T15:13:51.083454+00:00 |
| ef16a39f-6df5-4600-9b32-ba3ab6ae5ea7 | 2026-11-24T15:37:50.091277+00:00 |
| f5cce288-a401-4170-8afe-614f28bbbcfc | 2026-11-19T17:38:31.244291+00:00 |
| ffdc92a6-c698-4e1a-ac6b-24c53729d42a | 2026-11-18T14:33:40.237384+00:00 |

### Permisos antes
Las dos funciones: `{postgres=X/postgres,service_role=X/postgres}` (la migración deja lo mismo).

### Definición anterior · ca_prueba_cliente

```sql
CREATE OR REPLACE FUNCTION public.ca_prueba_cliente(_usuario uuid, _es_cliente boolean)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare u public.ca_usuario; dada boolean := false;
begin
  if not public.ca_es_interno() then raise exception 'solo interno'; end if;
  select * into u from public.ca_usuario where id = _usuario;
  if not found then return false; end if;
  perform set_config('ca.interno', '1', true);
  if coalesce(_es_cliente, false) and u.plan <> 'completo' and u.prueba_hasta is null then
    update public.ca_usuario set prueba_hasta = now() + interval '7 days', cliente_chequeado_at = now() where id = _usuario;
    dada := true;
  else
    update public.ca_usuario set cliente_chequeado_at = now() where id = _usuario;
  end if;
  perform set_config('ca.interno', '', true);
  if dada then
    insert into public.ca_evento (usuario_id, tipo, detalle) values (_usuario, 'prueba', jsonb_build_object('dias', 7, 'origen', 'cliente_airtable'));
    perform public.ca_avisar(_usuario);
  end if;
  return dada;
end $function$;
revoke execute on function public.ca_prueba_cliente(uuid, boolean) from public, anon, authenticated;
grant execute on function public.ca_prueba_cliente(uuid, boolean) to service_role;
```

### Definición anterior · ca_aplicar_ventana_alumnos

```sql
CREATE OR REPLACE FUNCTION public.ca_aplicar_ventana_alumnos()
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare w public.ca_ventana_alumnos; r record; n int := 0;
begin
  if not (public.ca_es_interno() or public.is_staff()) then
    raise exception 'solo staff';
  end if;
  select * into w from public.ca_ventana_alumnos where id;
  if not found or now() >= w.hasta then return 0; end if;
  perform set_config('ca.interno', '1', true);
  for r in
    update public.ca_usuario u set prueba_hasta = w.hasta
     where u.origen = 'alumno_v3' and u.plan <> 'completo' and not u.equipo
       and (u.prueba_hasta is null or u.prueba_hasta < w.hasta)
    returning u.id
  loop
    insert into public.ca_evento (usuario_id, tipo, detalle)
    values (r.id, 'prueba', jsonb_build_object('origen', 'ventana_alumnos', 'hasta', w.hasta));
    perform public.ca_avisar(r.id);
    n := n + 1;
  end loop;
  perform set_config('ca.interno', '', true);
  return n;
end $function$;
revoke all on function public.ca_aplicar_ventana_alumnos() from public, anon, authenticated;
```

## Cómo revertir

1. Volver a crear las dos funciones con las definiciones de arriba (pegar los dos bloques SQL en el SQL editor de Supabase).
2. Devolverles la fecha anterior a las 25 cuentas (una por una, con where por id; a nadie que no esté en la tabla):
   `select set_config('ca.interno','1',true); update public.ca_usuario set prueba_hasta = '<antes>' where id = '<id>';`
   (los eventos `prueba` con origen `ventana_alumnos` que dejó el barrido quedan como historial; no se borran).

## Después (verificado el 28-11-2026, ~03:30 UTC)

- Migración aplicada con apply_migration (nombre `cascarapp_ventana_clientes`).
- Cuentas con `prueba_hasta = hasta` de la ventana: 73 (48 antes + 25 del barrido).
- Pendientes con la misma consulta: 0. Eventos `prueba` / `ventana_alumnos` nuevos: 25.
- Permisos de las dos funciones iguales que antes.
