---
name: servicio-propio
description: Deploy or fix one of the user's self-hosted services on this machine as a systemd user unit, optionally published on the tailnet with `tailscale serve`. Use when the user asks to "montar/levantar/dejar corriendo/publicar por Tailscale" a server, app, panel or daemon, or when a user unit fails to start.
---

# Servicio propio (systemd --user + Tailscale)

Solo Linux con systemd. Antes de crear la unit, comprueba `loginctl show-user $USER -p Linger`. Si dice `no`, pregunta antes de activarlo con `loginctl enable-linger`: sin eso la unit no arranca sin sesión.

## 1. Antes de crear nada
- Puerto libre: `ss -ltnH | awk '{print $4}'` y `tailscale serve status`. No adivines ni reutilices puertos.
- Nombre: si ya hay una unit parecida en `~/.config/systemd/user/`, sigue su estilo.
- Escucha en `127.0.0.1`. La exposición la hace `tailscale serve`, no el servicio.

## 2. Unit
`~/.config/systemd/user/<nombre>.service`:

```ini
[Unit]
Description=<qué es>
After=network-online.target

[Service]
ExecStart=<ruta absoluta> <args>
WorkingDirectory=%h/<dir>
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

- Rutas absolutas (`%h` = home). Nada de secretos en la unit: usa `EnvironmentFile=%h/.config/<nombre>/env` con `chmod 600`.
- Para cambiar la unit de un proyecto que trae la suya, usa un drop-in `~/.config/systemd/user/<nombre>.service.d/override.conf`.

## 3. Arrancar y verificar (obligatorio)
```bash
systemctl --user daemon-reload
systemctl --user enable --now <nombre>
systemctl --user status <nombre> --no-pager -n 0
journalctl --user -u <nombre> -n 40 --no-pager
curl -fsS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:<puerto>/
```
Si falla, cita el error de `journalctl` y arregla la causa. No des por hecho que arrancó.

## 4. Publicar en la tailnet (solo si lo piden)
- `tailscale serve --bg --https=<puerto-externo> http://127.0.0.1:<puerto>`. El puerto externo no puede estar ya en `tailscale serve status`.
- **Nunca `tailscale funnel`**: abre a Internet. Solo con orden explícita y avisando.
- URL resultante: `https://<nombre-dns>:<puerto-externo>`. El nombre sale de `tailscale status --json | jq -r .Self.DNSName` (quita el punto final). Verifícala con `curl -fsS` desde esta máquina.

## 5. Cerrar
- Comandos para el usuario en la sintaxis de su shell si tiene que hacer algo a mano.
- Guarda una memoria corta (unit, puerto, URL, gotchas) si el servicio es nuevo.
