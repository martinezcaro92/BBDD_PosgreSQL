# 🐘 PostgreSQL + pgAdmin en Docker (Windows)

---

## 🌐 Índice de idiomas / Language Index / Sprachindex

| | Idioma | Sección |
|---|---|---|
| 🇪🇸 | Español | [Ver en español](#-versión-en-español) |
| 🇬🇧 | English | [View in English](#-english-version) |
| 🇩🇪 | Deutsch | [Auf Deutsch lesen](#-deutsche-version) |

---

---

# 🇪🇸 Versión en Español

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
    # Si estás en Windows ARM y tienes problemas, descomenta para forzar emulación
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
- **Parar y borrar datos**: `docker compose down -v` ⚠️ *(elimina la BBDD)*
- **Actualizar imágenes**: `docker compose pull && docker compose up -d`

---

## 🛠️ Troubleshooting

- **TLS/x509 al hacer pull**: si estás tras un proxy con inspección TLS, añade exclusiones **NO_PROXY** o instala la **CA corporativa** en Docker Desktop.
- **Init scripts no se re-ejecutan**: los scripts de `/docker-entrypoint-initdb.d` solo corren **la primera vez** (cuando `pg_data` está vacío). Borra el volumen (`docker compose down -v`) para re-inicializar.
- **Puerto 5432 ocupado**: cambia `POSTGRES_PORT` en `.env`.
- **Windows ARM**: descomenta `platform: linux/amd64` si tienes problemas con la imagen.

---

[⬆️ Volver al índice](#-índice-de-idiomas--language-index--sprachindex)

---

---

# 🇬🇧 English Version

This project deploys **PostgreSQL 16** with **persistence** and an **initialization script** to create a database and an application user. It includes **pgAdmin 4** as an optional graphical interface.

---

## 📦 Project Structure

```
postgres-docker/
├─ docker-compose.yml
├─ .env              # (create from .env.example)
├─ init/
│  └─ 01-init.sh
└─ scripts/
   └─ connect.ps1
```

---

## ✅ Requirements

- **Windows 10/11** with **Docker Desktop** (WSL2 backend recommended).
- Connectivity to Docker Hub (if you are on a corporate network with proxy/TLS inspection, check *Troubleshooting*).
- 512 MB–1 GB of free RAM for the Postgres container.

---

## ⚙️ Variables (.env)

Create a `.env` file at the project root (or copy from `.env.example`) with the following content:

```ini
POSTGRES_USER=postgres
POSTGRES_PASSWORD=Str0ngP@ssw0rd!2025
POSTGRES_DB=postgres

APP_DB=my_database
APP_USER=app_user
APP_PASSWORD=Usu@rioP4ss2025!

POSTGRES_PORT=5432
PGADMIN_PORT=8081

PGADMIN_DEFAULT_EMAIL=admin@example.com
PGADMIN_DEFAULT_PASSWORD=AdminP@ss2025!
```

> **Notes:**
> - `POSTGRES_USER/POSTGRES_PASSWORD` create the superuser and the initial database.
> - The `init/01-init.sh` script creates `APP_DB` + `APP_USER` and sets privileges.
> - Change passwords before going to production.

---

## 🧩 docker-compose.yml

Starts Postgres with a persistent volume and **pgAdmin 4**:

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

## ▶️ Getting Started

1. **Create `.env`** from `.env.example` and adjust the variables.
2. **Start the services** (PowerShell/CMD in the project folder):
   ```powershell
   docker compose up -d
   ```
3. **Verify containers**:
   ```powershell
   docker ps
   ```
4. **Postgres logs** (optional):
   ```powershell
   docker logs -f pg_server
   ```

---

## 🔌 Connecting to the Database

### CLI (psql inside the container)
```powershell
docker exec -it pg_server psql -U postgres -d %APP_DB%
```
or using the script:
```powershell
.\scripts\connect.ps1
```

### GUI (pgAdmin 4)
- Open: `http://localhost:8081`
- Login: `PGADMIN_DEFAULT_EMAIL` / `PGADMIN_DEFAULT_PASSWORD`
- **Add New Server** → **Connection**:
  - Host: `postgres` (service name in docker-compose)
  - Port: `5432`
  - Username: `postgres` (or `APP_USER`)
  - Password: as defined in `.env`

> To connect from an external client (DBeaver, IntelliJ, etc.): `localhost:5432`.

---

## 🗄️ Persistence and Backups

- Data is stored in the **`pg_data`** volume (not lost when containers are restarted).
- Backup (example) of the application database:
  ```powershell
  docker exec -i pg_server pg_dump -U postgres -d %APP_DB% > backup_%APP_DB%.sql
  ```
- Restore:
  ```powershell
  type backup_%APP_DB%.sql | docker exec -i pg_server psql -U postgres -d %APP_DB%
  ```

---

## 🧹 Quick Management

- **Stop**: `docker compose down`
- **Stop and delete data**: `docker compose down -v` ⚠️ *(removes the database)*
- **Update images**: `docker compose pull && docker compose up -d`

---

## 🛠️ Troubleshooting

- **TLS/x509 when pulling**: if you are behind a proxy with TLS inspection, add **NO_PROXY** exclusions or install the **corporate CA** in Docker Desktop.
- **Init scripts not re-running**: scripts in `/docker-entrypoint-initdb.d` only run **the first time** (when `pg_data` is empty). Delete the volume (`docker compose down -v`) to re-initialize.
- **Port 5432 in use**: change `POSTGRES_PORT` in `.env`.
- **Windows ARM**: uncomment `platform: linux/amd64` if you have issues with the image.

---

[⬆️ Back to index](#-índice-de-idiomas--language-index--sprachindex)

---

---

# 🇩🇪 Deutsche Version

Dieses Projekt stellt **PostgreSQL 16** mit **Persistenz** und einem **Initialisierungsskript** bereit, das eine Datenbank und einen Anwendungsbenutzer erstellt. Es enthält **pgAdmin 4** als optionale grafische Oberfläche.

---

## 📦 Projektstruktur

```
postgres-docker/
├─ docker-compose.yml
├─ .env              # (aus .env.example erstellen)
├─ init/
│  └─ 01-init.sh
└─ scripts/
   └─ connect.ps1
```

---

## ✅ Voraussetzungen

- **Windows 10/11** mit **Docker Desktop** (WSL2-Backend empfohlen).
- Verbindung zu Docker Hub (bei Unternehmensnetzwerk mit Proxy/TLS-Inspektion *Fehlerbehebung* beachten).
- 512 MB–1 GB freier RAM für den Postgres-Container.

---

## ⚙️ Variablen (.env)

Erstelle eine `.env`-Datei im Projektstammverzeichnis (oder kopiere aus `.env.example`) mit folgendem Inhalt:

```ini
POSTGRES_USER=postgres
POSTGRES_PASSWORD=Str0ngP@ssw0rd!2025
POSTGRES_DB=postgres

APP_DB=meine_datenbank
APP_USER=app_benutzer
APP_PASSWORD=Usu@rioP4ss2025!

POSTGRES_PORT=5432
PGADMIN_PORT=8081

PGADMIN_DEFAULT_EMAIL=admin@example.com
PGADMIN_DEFAULT_PASSWORD=AdminP@ss2025!
```

> **Hinweise:**
> - `POSTGRES_USER/POSTGRES_PASSWORD` erstellen den Superbenutzer und die initiale Datenbank.
> - Das Skript `init/01-init.sh` erstellt `APP_DB` + `APP_USER` und setzt die Berechtigungen.
> - Passwörter vor dem Produktionseinsatz ändern.

---

## 🧩 docker-compose.yml

Startet Postgres mit persistentem Volume und **pgAdmin 4**:

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
    # Bei Windows ARM und Problemen folgende Zeile auskommentieren, um Emulation zu erzwingen
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

## ▶️ Inbetriebnahme

1. **`.env` erstellen** aus `.env.example` und Variablen anpassen.
2. **Dienste starten** (PowerShell/CMD im Projektordner):
   ```powershell
   docker compose up -d
   ```
3. **Container überprüfen**:
   ```powershell
   docker ps
   ```
4. **Postgres-Logs** (optional):
   ```powershell
   docker logs -f pg_server
   ```

---

## 🔌 Verbindung zur Datenbank

### CLI (psql im Container)
```powershell
docker exec -it pg_server psql -U postgres -d %APP_DB%
```
oder mit dem Skript:
```powershell
.\scripts\connect.ps1
```

### GUI (pgAdmin 4)
- Öffne: `http://localhost:8081`
- Login: `PGADMIN_DEFAULT_EMAIL` / `PGADMIN_DEFAULT_PASSWORD`
- **Add New Server** → **Connection**:
  - Host: `postgres` (Dienstname in docker-compose)
  - Port: `5432`
  - Benutzername: `postgres` (oder `APP_USER`)
  - Passwort: wie in `.env` definiert

> Für den Zugriff von einem externen Client (DBeaver, IntelliJ, etc.): `localhost:5432`.

---

## 🗄️ Persistenz und Backups

- Daten im Volume **`pg_data`** (bleiben beim Neustart der Container erhalten).
- Backup (Beispiel) der Anwendungsdatenbank:
  ```powershell
  docker exec -i pg_server pg_dump -U postgres -d %APP_DB% > backup_%APP_DB%.sql
  ```
- Wiederherstellen:
  ```powershell
  type backup_%APP_DB%.sql | docker exec -i pg_server psql -U postgres -d %APP_DB%
  ```

---

## 🧹 Schnellverwaltung

- **Stoppen**: `docker compose down`
- **Stoppen und Daten löschen**: `docker compose down -v` ⚠️ *(löscht die Datenbank)*
- **Images aktualisieren**: `docker compose pull && docker compose up -d`

---

## 🛠️ Fehlerbehebung

- **TLS/x509 beim Pull**: bei Proxy mit TLS-Inspektion **NO_PROXY**-Ausnahmen hinzufügen oder das **Unternehmens-CA** in Docker Desktop installieren.
- **Init-Skripte werden nicht erneut ausgeführt**: Skripte in `/docker-entrypoint-initdb.d` laufen nur **beim ersten Start** (wenn `pg_data` leer ist). Volume löschen (`docker compose down -v`) zum erneuten Initialisieren.
- **Port 5432 belegt**: `POSTGRES_PORT` in `.env` ändern.
- **Windows ARM**: `platform: linux/amd64` auskommentieren, wenn Probleme mit dem Image auftreten.

---

[⬆️ Zurück zum Index](#-índice-de-idiomas--language-index--sprachindex)