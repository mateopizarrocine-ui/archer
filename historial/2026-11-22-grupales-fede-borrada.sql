-- Respaldo de la fila borrada de Grupales (decisión de Teo 13/11, confirmada el 22/11/2026).
-- Supabase de la Founders App (hklrjudyhgprzgvfwuph). Para restaurarla, correr este insert tal cual.
insert into public.grupales (id, fecha, dia, tema, host, grabacion_url, resumen) values (
  '6f814c1c-5350-4d75-b1cf-f23386d76e76', '2026-11-06', 'viernes', 'Meet', 'Fede',
  'https://fathom.video/share/banV4RVx6sgkjaPxCzNSMAfL5yY6yVDy',
  E'Presentar la consultoría Cáscara Founders y un marco de lanzamiento de 5 pasos.\nCáscara Founders es una consultoría de 90 días para agencias creativas que buscan escalar, con 10 sesiones 1:1 con los 5 fundadores de Cáscara sobre estrategia, oferta, contenido, marca y operaciones.\nEl marco de lanzamiento de 5 pasos (Estrategia → Creatividad → Contenido → Producto → Accionables) permite a los fundadores planificar con anticipación, crear un arco narrativo y producir contenido que venda.\nEl contenido debe combinar tres pilares: necesidades comerciales (dolores de los clientes), campaña creativa (narrativa de marca) y formatos de tendencia (alcance).\nLa consultoría es para agencias creativas de alto ticket, no para negocios de productos físicos, ya que el modelo de Cáscara está diseñado para escalar servicios digitales.'
);
