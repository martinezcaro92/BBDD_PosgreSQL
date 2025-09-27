# 🐘 PostgreSQL + pgAdmin en Docker (Windows)

Este proyecto despliega **PostgreSQL 16** con **persistencia** y un script de **inicialización** para crear una base de datos y un usuario de aplicación. Incluye **pgAdmin 4** como interfaz gráfica opcional.

---

## 📦 Estructura del proyecto

```
postgres-docker/
├─ docker-compose.yml
├─ .env              # (crear desde .env.example)
├─ init/
│  └─ 01-init.sh
└─ scripts/
   └─ connect.ps1
```

---

## ✅ Requisitos

- **Windows 10/11** con **Docker Desktop** (WSL2 backend recomendado).
- Conectividad a Docker Hub (si estás en red corporativa con proxy/inspección TLS, revisa *Troubleshooting*).
- 512 MB–1 GB RAM libres para el contenedor de Postgres.

---

## ⚙️ Variables (.env)

Crea un fichero `.env` en la raíz del proyecto (o copia desde `.env.example`) con este contenido:

```ini
POSTGRES_USER=postgres
POSTGRES_PASSWORD=Str0ngP@ssw0rd!2025
POSTGRES_DB=postgres

APP_DB=mi_base_datos
APP_USER=usuario_app
APP_PASSWORD=Usu@rioP4ss2025!

POSTGRES_PORT=5432
PGADMIN_PORT=8081

PGADMIN_DEFAULT_EMAIL=admin@example.com
PGADMIN_DEFAULT_PASSWORD=AdminP@ss2025!
```

> **Notas:**  
> - `POSTGRES_USER/POSTGRES_PASSWORD` crean el superusuario y la BBDD inicial.  
> - El script `init/01-init.sh` crea `APP_DB` + `APP_USER` y ajusta privilegios.  
> - Cambia contraseñas antes de producción.

---

## 🧩 docker-compose.yml

Se levanta Postgres con volumen persistente y **pgAdmin 4**:

```yaml
services:
  postgres:
    image: docker.io/library/postgres:16
    container_name: pg_server
    restart: unless-stopped
    env_file: .env
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
      - TZ=Europe/Madrid
    ports:
      - "${POSTGRES_PORT}:5432"
    volumes:
      - pg_data:/var/lib/postgresql/data
      - ./init:/docker-entrypoint-initdb.d:ro
    # If you're on Windows ARM and face issues, uncomment to force emulation
    # platform: linux/amd64

  pgadmin:
    image: docker.io/dpage/pgadmin4:latest
    container_name: pgadmin
    restart: unless-stopped
    env_file: .env
    environment:
      - PGADMIN_DEFAULT_EMAIL=${PGADMIN_DEFAULT_EMAIL}
      - PGADMIN_DEFAULT_PASSWORD=${PGADMIN_DEFAULT_PASSWORD}
    ports:
      - "${PGADMIN_PORT}:80"
    depends_on:
      - postgres
    volumes:
      - pgadmin_data:/var/lib/pgadmin

volumes:
  pg_data:
  pgadmin_data:
```

---

## ▶️ Puesta en marcha

1. **Crea `.env`** a partir de `.env.example` y ajusta variables.  
2. **Inicia los servicios** (PowerShell/CMD en la carpeta):
   ```powershell
   docker compose up -d
   ```
3. **Verifica contenedores**:
   ```powershell
   docker ps
   ```
4. **Logs de Postgres** (opcional):
   ```powershell
   docker logs -f pg_server
   ```

---

## 🔌 Conexión a la base de datos

### CLI (psql dentro del contenedor)
```powershell
docker exec -it pg_server psql -U postgres -d %APP_DB%
```
o usando el script:
```powershell
.\scripts\connect.ps1
```

### GUI (pgAdmin 4)
- Abre: `http://localhost:8081`  
- Login: `PGADMIN_DEFAULT_EMAIL` / `PGADMIN_DEFAULT_PASSWORD`  
- **Add New Server** → **Connection**:  
  - Host: `postgres` (nombre del servicio en docker-compose)  
  - Port: `5432`  
  - Username: `postgres` (o `APP_USER`)  
  - Password: la de `.env`

> Si quieres acceder desde un cliente externo (DBeaver, IntelliJ, etc.): `localhost:5432`.

---

## 🗄️ Persistencia y backups

- Datos en el volumen **`pg_data`** (no se pierden al reiniciar contenedores).  
- Backup (ejemplo) de la BBDD de aplicación:
  ```powershell
  docker exec -i pg_server pg_dump -U postgres -d %APP_DB% > backup_%APP_DB%.sql
  ```
- Restore:
  ```powershell
  type backup_%APP_DB%.sql | docker exec -i pg_server psql -U postgres -d %APP_DB%
  ```

---

## 🧹 Gestión rápida

- **Parar**: `docker compose down`  
- **Parar y borrar datos**: `docker compose down -v`  ⚠️ *(elimina la BBDD)*  
- **Actualizar imágenes**: `docker compose pull && docker compose up -d`

---

## 🛠️ Troubleshooting

- **TLS/x509 al hacer pull**: si estás tras un proxy con inspección TLS, añade exclusiones **NO_PROXY** o instala la **CA corporativa** en Docker Desktop.  
- **Init scripts no se re-ejecutan**: los scripts de `/docker-entrypoint-initdb.d` solo corren **la primera vez** (cuando `pg_data` está vacío). Borra el volumen (`docker compose down -v`) para re-inicializar.  
- **Puerto 5432 ocupado**: cambia `POSTGRES_PORT` en `.env`.  
- **Windows ARM**: descomenta `platform: linux/amd64` si tienes problemas con la imagen.

---

## 📥 Descarga rápida

- [Descargar `docker-compose.yml`](sandbox:/mnt/data/postgres-docker/docker-compose.yml)  
- [Descargar `.env.example`](sandbox:/mnt/data/postgres-docker/.env.example)  
- [Descargar `init/01-init.sh`](sandbox:/mnt/data/postgres-docker/init/01-init.sh)  
- [Descargar `scripts/connect.ps1`](sandbox:/mnt/data/postgres-docker/scripts/connect.ps1)  
- [Descargar `README.md`](sandbox:/mnt/data/postgres-docker/README.md)

---

¿Quieres que añada un `backup.ps1`/`restore.ps1` para automatizar copias con nombres por fecha? 
