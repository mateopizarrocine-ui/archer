# 22/11/2026 · La Cáscara APP · «No se pudo guardar» al cerrar módulo

Supabase `nwpusuytiagfsincbvwd` · Lovable `6e02f965-6efe-4925-abf8-566bbe487579`

## Causa raíz
El trigger `trg_detectar_upsell` (AFTER INSERT OR UPDATE en `cierre_fase`) llama a
`public.fn_detectar_upsell()`, que inserta en `upsell`. La función corría con los permisos
del alumno (no era SECURITY DEFINER) y `upsell` solo tiene la policy `upsell_staff_all`
(is_staff). Si el alumno mandaba readiness >= 4 (o interes_1a1 = true), el upsert de
`cierre_fase` fallaba con 42501 «new row violates row-level security policy for table upsell».

## Cambio 1 · base (migración `fn_detectar_upsell_security_definer`)
```sql
alter function public.fn_detectar_upsell() security definer;
```
Estado anterior: `prosecdef = false`, `proconfig = {search_path=public}`, dueño `postgres`.
Definición (sin cambios en el cuerpo):
```sql
CREATE OR REPLACE FUNCTION public.fn_detectar_upsell()
 RETURNS trigger LANGUAGE plpgsql SET search_path TO 'public'
AS $function$
begin
  if (coalesce(new.readiness_score,0) >= 4 or new.interes_1a1 is true) then
    insert into upsell (alumno_id, modulo_id, origen, estado, readiness_score)
    values (new.alumno_id, new.modulo_id, 'readiness_cierre', 'leida', new.readiness_score)
    on conflict (alumno_id, modulo_id, origen)
      do update set readiness_score = excluded.readiness_score;
  end if;
  return null;
end; $function$
```
En la misma migración: `revoke execute on function public.fn_detectar_upsell() from anon;`
(no afecta al trigger; solo evita que se pueda llamar suelta).

**Revertir:** 
```sql
alter function public.fn_detectar_upsell() security invoker;
grant execute on function public.fn_detectar_upsell() to anon;
```

Verificado: simulando a un alumno (rol authenticated, en transacción con rollback), el insert
en `cierre_fase` con readiness 5 pasa y crea la fila en `upsell`. No quedó nada del test.

## Cambio 2 · dato (alumno afectado, mismo arreglo que a Lía el 17/11)
Thomas Iglesias (iglesiasthomas2.0) · módulo 8 «Creativo Contratable» · cierre del 04/11
con readiness 5 que había fallado.
```sql
update cierre_fase set readiness_score=5 where id='537f480a-00c8-4f6a-8ad5-9781455b8353';
```
Valor anterior: `readiness_score = null`. El trigger creó la fila de upsell
`20e080bf-85ee-400f-9f5f-1e49e4f9a4d2` (módulo 8, estado leida, readiness 5).
**Revertir:** `update cierre_fase set readiness_score=null where id='537f480a-00c8-4f6a-8ad5-9781455b8353';`
(la fila de upsell quedaría; borrarla es decisión de Teo).

## Cambio 3 · código (Lovable) · COMMITEADO, NO PUBLICADO
Segundo bug: la pregunta «interes_1a1» es si/no, pero el código hacía `Number("si")` → NaN
y nunca guardaba `interes_1a1` (columna boolean). Arreglo en `src/routes/cierre.$moduloId.tsx`
(persist): «si» → true, «no» → false. Commit `60856d5511a39b91674f1e9033c9ae14b2894565`
(mensaje Lovable `umsg_01m8178rm4f31s7smzhh2x2qg6`).
Lovable además commiteó aparte un `bun.lock` «generado por la plataforma» que no pude revisar,
así que NO se publicó. Para publicar: botón Publish en Lovable (o deploy_project).
**Revertir:** restaurar en Lovable la versión anterior a esos dos commits.
Ojo cosmético si se publica: `src/routes/admin.$alumnoId.tsx` muestra `{c.interes_1a1}/10`;
con boolean se vería «interés 1a1: /10».

## 22/11 · Teo eligió 1: publicar y anotar
- Lovable: commit `804d32ea41ae625ee987200d88983712ca3c82f5` (admin muestra «sí/no» en interés 1a1) y publicado junto con `60856d55…` (deploy `533059cc-5e0a-4308-83c4-c70682210de1`).
- Dato: `interes_1a1` pasó de null a true en 5 cierres que tenían «si» en las respuestas (Agustín Turcato 8, 10, 11; Thomas Iglesias 8, 10). El trigger creó o actualizó sus filas en `upsell`.
**Revertir el dato:**
```sql
update cierre_fase set interes_1a1=null where id in ('e1227dc9-b073-4398-967c-57f3aa8ddefe','62906b8e-362b-42db-9021-594f8ec216b5','84c9eb70-6633-4e4d-947b-2f7771ae3798','537f480a-00c8-4f6a-8ad5-9781455b8353','51b0626d-4fcf-406e-be28-1a2c74be9ff9');
```
(las filas de upsell quedarían; borrarlas es decisión de Teo).
