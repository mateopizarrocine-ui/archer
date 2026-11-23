# Pasos a mano para Teo

Cosas que solo podés hacer vos (tokens, Vercel, GitHub, Cowork, git). En orden.

## 1 · Versionar este proyecto (una sola vez)

Creá el repo vacío y privado en GitHub (sin README): https://github.com/new → nombre `archer`, Private.
Después, en la terminal:

```bash
cd ~/Documents/Claude/archer && git init -b main && git add -A && git commit -m "Archer: proyecto inicial (núcleo + sectores Apps y Desk, despliegue, Desk en vivo)"
```

```bash
cd ~/Documents/Claude/archer && git remote add origin https://github.com/mateopizarrocine-ui/archer.git && git push -u origin main
```

## 2 · Token del disparo en vivo de Archer · Desk

1. Entrá a https://claude.ai/code/routines/trig_014ScCRaRYmE9Ggm7Ct5GA7G → **Editar**.
2. En la fila **Disparadores** tocá **+** → **API** → **Generar token**.
3. El token se ve UNA sola vez. Copialo y pegalo directo en el paso 3 (no lo pegues en el chat ni en ningún archivo).

## 3 · Variable en Vercel y deploy de DESK

1. Vercel → proyecto de DESK → **Settings → Environment Variables** → **Add**:
   - Name: `ARCHER_DESK_FIRE_TOKEN`
   - Value: el token del paso 2
   - Environment: Production
2. Commiteá el cambio de DESK (ya está hecho en tu carpeta, sin commitear):

```bash
cd ~/Documents/Claude/cascara-hq && git add api/supabase.js docs/estado.md && git commit -m "Feedback: dispara Archer · Desk en vivo con cada reporte nuevo" && git push
```

3. Si el deploy arrancó antes de cargar la variable, hacé **Redeploy** del último deploy (las variables se congelan por deploy).

Sin token, DESK sigue igual que hoy (el cambio no hace nada); la pasada de cada 2 h sigue.

## 4 · Disparador de GitHub (PR mergeado → Archer verifica y avisa)

1. Si no está, instalá la app de Claude en el repo: https://github.com/apps/claude → Configure → acceso a `cascara-hq`.
2. En https://claude.ai/code/routines/trig_014ScCRaRYmE9Ggm7Ct5GA7G → **Editar** → **Disparadores** → **+** → **GitHub**:
   - Repo: `mateopizarrocine-ui/cascara-hq`
   - Evento: **Pull request → closed**
   - Filtros: **Is merged** = true · **Head branch** starts with `archer/`
3. Guardar.

## 5 · Pegar el prompt nuevo de Archer · Apps

1. Abrí `dist/apps.txt` de esta carpeta (si no está, pedile a Claude «armá los prompts» o corré `node scripts/build.mjs`).
2. Claude → Cowork → tareas programadas → **Archer · Apps** → editar → reemplazá TODO el texto de las instrucciones por el de `dist/apps.txt` → guardar.
3. Qué cambia: firma «Archer · Apps», deja DESK (solo chequea que cargue), saltea los reportes de DESK en #monitor-cascara, y los pedidos de Facu sobre DESK se los pasa a Archer · Desk en vez de armarte prompts para pegar.

## 6 · Probar de punta a punta

Cargá un reporte cualquiera desde DESK (botón de sugerencias/reportes, tipo «duda», ej. «Prueba en vivo: ¿cuántos closers hay cargados?»). En menos de un minuto tiene que aparecer en el hilo de #monitor-cascara una respuesta de «Archer · Desk».

## Encender Archer · CascarApp (actualizado 24/11/2026)

Ya está hecho: el control publicado y probado en la app, el canal #cascarapp-updates, la rutina y el Zap (en borrador). Falta un solo paso tuyo, la llave:

1. Abrí la rutina: https://claude.ai/code/routines/trig_01GpdK9oWtRv2j6QM2v4qKeE → **Editar** → fila **Disparadores** → **+** → **API** → **Generar token**. Se ve UNA sola vez: copialo.
2. Abrí https://mcp.zapier.com/api/v1/connect-auth/App235435CLIAPI?accountId=25060309 y creá una conexión nueva de «API by Zapier» igual a la de Desk: tipo Static Headers, dominio `api.anthropic.com`, y dos encabezados: `Authorization` = `Bearer ` + el token, y `anthropic-version` = `2023-06-01`. Ponele de nombre «Archer CascarApp».
3. Avisale a Claude «listo la llave». Claude conecta el Zap, lo enciende y lo verifica.
4. **Prueba con Aye**: que pida un cambio de texto chico en #cascarapp-updates, mire la vista previa y conteste «publicar».

El token no se pega en el chat ni en ningún archivo.
