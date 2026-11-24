# Así subimos los cambios

Guía común para preparar y entregar actualizaciones de proyectos de POPUPS con un ZIP de un solo uso que incluye `PUBLICAR.bat` y un bundle Git.

## Para agentes de IA

Antes de modificar un proyecto, lee completo [`PUBLICAR_CAMBIOS.md`](PUBLICAR_CAMBIOS.md) y también las instrucciones propias de ese proyecto (`AGENTS.md`, `AGENTE.md` o equivalentes). Si se contradicen, las reglas específicas del proyecto mandan sobre su arquitectura; este protocolo manda sobre la entrega y la publicación.

El propietario trabaja con doble clic: el agente hace los cambios técnicos, ejecuta las pruebas y prepara el ZIP. No le pidas usar terminal, copiar archivos, crear commits ni resolver conflictos.

## Para publicar

Extrae el ZIP de actualización y ejecuta `PUBLICAR.bat`. Inicia sesión mediante Git Credential Manager si GitHub lo solicita. El BAT aplica el bundle sobre la rama actual con un push normal, sin sobrescribir el historial, y verifica el SHA publicado.
