# alive — Punk Records Hosting

## ¿Qué es?
`alive` es un sitio frontend estático servido **exclusivamente en red local (LAN)** como parte del proyecto **punk-records**.

Este hosting sigue un enfoque **local-first**:
- GitHub es solo repositorio
- El servidor decide cuándo actualizarse
- No hay push, webhooks ni dependencias externas

---

## Arquitectura (simple y explícita)

GitHub (repo)
   ↓ (pull)
Servidor local (cron)
   ↓
update.sh
   ↓
deploy.sh
   ↓
Caddy (hot reload)
   ↓
Clientes en LAN

**Source of truth:** el servidor
**Scheduler:** cron
**Reverse proxy:** Caddy
**CI/CD:** pull periódico desde el server

---

## Estructura del directorio

alive/
├── site/ # archivos estáticos del frontend
├── deploy.sh # recarga Caddy (hot reload)
├── update.sh # git pull + deploy
├── cron.log # log del cron
└── README.md

markdown
Copiar código

### Contrato del patrón
- `site/` **no** tiene lógica de deploy
- `update.sh` es el único punto de entrada del CI/CD
- `deploy.sh` solo hace deploy (sin git)
- `cron.log` es la primera fuente de debug

---

## Flujo de deploy (local-first)

1. `cron` ejecuta `update.sh`
2. `update.sh`:
   - verifica estado del repo
   - hace `git pull`
   - llama a `deploy.sh`
3. `deploy.sh`:
   - recarga Caddy sin downtime
4. El sitio queda actualizado en LAN

Cron actual:
*/5 * * * * cd /srv/punk-records/hosting/alive && ./update.sh >> cron.log 2>&1

yaml
Copiar código

---

## Decisiones

- ❌ No GitHub Actions
  → el servidor no es accesible desde Internet

- ❌ No webhooks
  → sin IP pública, sin puertos abiertos

- ❌ No HTTPS / dominios
  → solo LAN, sin complejidad innecesaria

- ✅ Pull periódico
  → funciona aunque el server esté apagado horas o días

---

## Debug rápido

```bash
# ver último deploy
tail -n 50 cron.log

# verificar estado del repo
git status

# logs de Caddy
docker logs caddy
Restauración básica
Si algo se rompe:

revisar cron.log

revertir commit en GitHub si hace falta

esperar próximo cron o ejecutar manualmente:

bash
Copiar código
./update.sh