-- Respaldo antes de sacar el link de GitHub de los avisos del Cerebro (pedido de Facu, 19/11/2026).
-- Supabase de la Founders App (hklrjudyhgprzgvfwuph). Para volver atrás, correr estas dos definiciones tal cual.
-- n8n «Cerebro · Revisión → canal cf-» (TDBMK6cdwXtREMhS), nodo «Armar mensaje», versión a366cc93-73c1-4d74-8508-cfaba9f003c2:
-- la línea de respaldo era:
--   cuerpo = `*${cliente}* mandó a revisión *${titulo}*.` + (carta.url ? `\n• Carta: ${carta.url}` : '') + `\n• Ver respuestas: https://foundersapp.cascaraco.com/admin/clientes/${slug}`;

CREATE OR REPLACE FUNCTION public.resumen_devolucion(p_id uuid, p_evento text DEFAULT 'nueva'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare d record; canal text; t text;
begin
  select dv.titulo, dv.resumen, dv.doc_url, dv.respuesta, dv.autor_nombre, c.slug, c.nombre, c.proyecto, c.slack_canal, ca.nombre carta
    into d
  from devoluciones dv join clientes c on c.id = dv.cliente_id left join cartas ca on ca.id = dv.carta_id
  where dv.id = p_id;
  if not found then return null; end if;
  canal := coalesce(nullif(ltrim(d.slack_canal, '#'), ''), 'cf-' || d.slug);
  if p_evento = 'respuesta' then
    t := ':speech_balloon: *' || coalesce(d.proyecto, d.nombre) || '* respondió la devolución *' || coalesce(d.titulo,'') || '*:'
      || E'\n> ' || left(regexp_replace(coalesce(d.respuesta,''), '\s+', ' ', 'g'), 500);
  else
    t := ':memo: Nueva devolución' || coalesce(' sobre *' || d.carta || '*', '') || ': *' || coalesce(d.titulo,'') || '*'
      || coalesce(E'\n' || d.resumen, '')
      || coalesce(E'\n:point_right: ' || d.doc_url, '')
      || E'\nLa podés leer y marcar como leída en la app, en Devoluciones.';
  end if;
  return jsonb_build_object('canal', canal, 'texto', t);
end $function$;

CREATE OR REPLACE FUNCTION public.resumen_revision(p_asignacion uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  a record; lineas text := ''; r record; n_llenos int; n_total int; muestra text; canal text;
begin
  select asg.id, asg.entrega_url, c.slug, c.nombre, c.proyecto, c.slack_canal, ca.nombre carta, ca.url carta_url
    into a
  from asignaciones asg join clientes c on c.id = asg.cliente_id left join cartas ca on ca.id = asg.carta_id
  where asg.id = p_asignacion;
  if not found then return null; end if;

  for r in select seccion, titulo, completada, contenido from respuestas where asignacion_id = p_asignacion order by seccion loop
    select count(*) filter (where nullif(trim(v),'') is not null), count(*) into n_llenos, n_total
      from jsonb_each_text(coalesce(r.contenido,'{}'::jsonb)) as t(k,v);
    select left(regexp_replace(v, '\s+', ' ', 'g'), 140) into muestra
      from jsonb_each_text(coalesce(r.contenido,'{}'::jsonb)) as t(k,v)
      where nullif(trim(v),'') is not null order by length(v) desc limit 1;
    lineas := lineas || E'\n• *' || coalesce(r.titulo, r.seccion) || '*: '
      || case when n_llenos = 0 then 'sin completar'
              else n_llenos || ' de ' || n_total || ' campos' || coalesce(' · «' || muestra || case when length(muestra) >= 140 then '…' else '' end || '»', '') end;
  end loop;
  if lineas = '' then lineas := E'\n• (todavía no hay respuestas guardadas en la app)'; end if;

  canal := coalesce(nullif(ltrim(a.slack_canal, '#'), ''), 'cf-' || a.slug);
  return jsonb_build_object(
    'canal', canal,
    'texto', ':inbox_tray: *' || coalesce(a.proyecto, a.nombre) || '* mandó a revisión la carta *' || coalesce(a.carta, 'sin nombre') || '*'
      || E'\n\nLo que completó:' || lineas
      || E'\n\n:point_right: Ver respuestas en la app: https://foundersapp.cascaraco.com/admin/clientes/' || a.slug
      || coalesce(E'\n:page_facing_up: Carta: ' || coalesce(a.carta_url, a.entrega_url), ''));
end $function$;
