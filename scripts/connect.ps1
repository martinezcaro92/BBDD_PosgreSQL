\
# scripts\connect.ps1
# Loads variables from .env and opens a psql session inside the container.

$envPath = Join-Path -Path (Get-Location) -ChildPath ".env"
if (!(Test-Path $envPath)) {
  Write-Error ".env file not found at $envPath"
  exit 1
}

Get-Content $envPath | ForEach-Object {
  if ($_ -match '^\s*#') { return }
  if ($_ -match '^\s*$') { return }
  $kv = $_ -split '=',2
  if ($kv.Count -eq 2) {
    $key = $kv[0].Trim()
    $val = $kv[1].Trim()
    [System.Environment]::SetEnvironmentVariable($key, $val)
  }
}

if (-not $env:POSTGRES_USER -or -not $env:POSTGRES_DB) {
  Write-Error "POSTGRES_USER/POSTGRES_DB not found in .env"
  exit 1
}

docker exec -it pg_server psql -U "$($env:POSTGRES_USER)" -d "$($env:APP_DB)"
