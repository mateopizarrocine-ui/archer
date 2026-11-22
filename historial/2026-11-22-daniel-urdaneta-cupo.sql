-- Daniel Urdaneta (Founders Group): decisión de Teo 22/11/2026, opción 1 (una llamada por ciclo, solo para él).
-- Supabase de la Founders App (hklrjudyhgprzgvfwuph). Antes: sesiones_por_ciclo=2; sesiones 30/10 y 02/11 con tipo '1:1'.
-- Para volver atrás:
update clientes set sesiones_por_ciclo=2 where id='d3fbf97d-ba5f-437a-ac67-55252b362f23';
update sesiones set tipo='1:1' where id in ('5d4d4355-a3f4-48d5-a3de-966732a8654a','a8bf127a-f2bb-4e95-a13d-27ff52795390');
