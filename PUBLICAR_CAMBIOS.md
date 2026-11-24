# Protocolo para entregar cambios con `PUBLICAR.bat`

Este repositorio es la referencia reutilizable de publicación para proyectos de POPUPS. El método está inspirado en el flujo probado de [Oficina Virtual](https://github.com/Somospopups/Oficina-virtual), pero no impone sus reglas de producto, sprites ni versionado a otros proyectos.

## Regla central

El agente hace el trabajo técnico y entrega un ZIP pequeño para publicar con doble clic. El propietario no programa, no usa terminal, no copia archivos manualmente, no crea commits y no resuelve conflictos.

El ZIP de cada actualización contiene una carpeta con solo:

```text
actualizacion-nombre-fecha/
├── PUBLICAR.bat
├── cambio-nombre-fecha.bundle
└── LEEME.txt
```

## Antes de tocar el proyecto

1. Lee estas instrucciones y todos los archivos de guía del proyecto (`AGENTS.md`, `AGENTE.md`, `CONTRIBUTING.md` u otros).
2. Descarga el último `origin/main`; trabaja siempre desde esa base, no desde una copia vieja:

```bash
git fetch origin main
git switch main
git reset --hard origin/main
```

3. Revisa el estado del repo y conserva cambios ajenos a la tarea. No hagas `reset --hard` sobre trabajo del usuario sin identificar primero qué se perdería.
4. Respeta nombres, interfaz, versionado, pruebas, atribuciones, licencias y restricciones particulares del proyecto.

## Seguridad de credenciales

- Nunca pidas ni uses tokens, contraseñas, cookies o claves pegadas en el chat.
- No guardes credenciales en el repo, BAT, bundle, ZIP, commits ni logs.
- El BAT deja que Git Credential Manager abra la autenticación oficial de GitHub.
- No uses `git push --force`, `--force-with-lease`, ni reescribas ramas para evitar conflictos.

## Implementar y verificar

1. Haz solo los cambios solicitados; no reemplaces archivos completos cuando baste un cambio acotado.
2. Ejecuta las pruebas indicadas por el proyecto (`npm test`, chequeos, linters o equivalentes) y pruebas de sintaxis/recursos cuando correspondan.
3. Revisa `git diff --check`, `git status` y el diff completo. No empaquetes si alguna prueba falla.
4. Confirma que el commit se basa en el último `origin/main` y contiene solo cambios de esta tarea.
5. Usa la identidad de commit definida por el proyecto. Si no hay una, la plantilla usa `Arena Agent <arena-agent@users.noreply.github.com>`.

## Commit y bundle de una sola actualización

Crea un solo commit, claro y acotado. Para un repo con historial existente, el bundle contiene solo ese commit y declara como prerrequisito su padre:

```bash
BASE=$(git rev-parse HEAD^)
git bundle create cambio-nombre-fecha.bundle HEAD ^$BASE
git bundle verify cambio-nombre-fecha.bundle
```

Para un repositorio vacío, consulta la sección “Primer commit de un repo vacío” al final: requiere un commit raíz y un BAT de inicialización, no un cherry-pick normal.

## Preparar `PUBLICAR.bat`

Usa [`PLANTILLA_PUBLICAR.bat`](PLANTILLA_PUBLICAR.bat), reemplaza la URL del repo y el nombre del bundle, y adapta solo lo necesario. El BAT debe:

1. Comprobar que Git esté instalado y que el bundle exista.
2. Clonar la versión actual de `main` en una carpeta temporal.
3. Obtener el commit del bundle con `git fetch`.
4. Detectar si el cambio ya fue publicado. `git cherry origin/main FETCH_HEAD` devuelve `- <sha>` si el parche ya está incorporado: mostrar “ya publicado” y salir con éxito, no tratarlo como error ni crear un commit vacío.
5. Hacer `cherry-pick` normal. Ante conflicto, abortar, limpiar la copia temporal e informar que el agente debe preparar un ZIP nuevo.
6. Ejecutar `git push origin main` sin force.
7. Verificar con `git ls-remote` que el SHA remoto sea exactamente el nuevo SHA.
8. Limpiar la carpeta temporal y mostrar un mensaje veraz de éxito/error.

El usuario final solo extrae el ZIP, hace doble clic en el BAT y autentica GitHub si se lo pide. Nunca debe abrir una terminal ni editar código.

## Preparar y entregar el ZIP

- Crea una carpeta con nombre descriptivo de producto/actualización/fecha local de Argentina.
- Incluye el BAT, el bundle de esa actualización y un `LEEME.txt` con pasos breves.
- No metas el repositorio entero, `.git`, tokens, cachés, archivos temporales ni fuentes que no pertenezcan al bundle.
- Verifica integridad del bundle y del ZIP; simula en un clon limpio que el bundle se puede aplicar y corre las pruebas una vez más.
- Presenta el ZIP en la respuesta. No afirmes que algo está publicado hasta que el BAT haya verificado el SHA remoto.

## Si el repo todavía está vacío

No uses el flujo normal de clone de una rama existente ni `cherry-pick`. Prepara un commit raíz con los documentos iniciales, un bundle sin prerrequisitos y un BAT de inicialización:

1. Consulta `git ls-remote <repo> refs/heads/main`.
2. Si `main` está vacía, clona el repo vacío, obtiene el bundle y crea `main` desde `FETCH_HEAD`.
3. Publica con `git push -u origin main` y verifica el SHA remoto.
4. Si ya existe `main` con el SHA del bundle, informa “ya inicializado” y termina con éxito.
5. Si existe `main` con cualquier otro SHA, detente. No sobrescribas ni mezcles automáticamente; vuelve a basarte en la rama actual.

## Si algo falla

- No afirmes éxito ni pidas al propietario resolver conflictos.
- Indica exactamente qué chequeo falló; vuelve a clonar el `origin/main` actual, reaplica la tarea y prepara una nueva actualización.
- Si el push tuvo éxito pero falló la comprobación posterior, no digas que no se publicó: informa que el resultado quedó sin verificar y compruébalo antes de crear otro bundle.

## Previews

Muestra previews solo cuando el propietario los pida o cuando sean parte explícita del encargo. Para archivos de vista previa del agente, usa HTML/CSS/JS inline o assets autocontenidos cuando el visor sandbox no permita red.
