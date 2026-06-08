# ari_logs v1.0.0

Sistema de logs para servidores FiveM ESX con integración mediante Webhooks de Discord.

## 📋 Características

* Logs de conexión y desconexión de jugadores.
* Registro de creación de personajes.
* Logs de aparición (spawn) de jugadores.
* Integración con Discord mediante Webhooks.
* Configuración sencilla mediante archivo `config.lua`.
* Compatible con ESX Legacy.
* Código ligero y optimizado.

## 📦 Instalación

1. Descarga la última versión disponible.
2. Coloca la carpeta `ari_logs` dentro de tu directorio `resources`.
3. Configura tus Webhooks de Discord en:

```lua
config/config.lua
```

4. Añade el recurso a tu `server.cfg`:

```cfg
ensure ari_logs
```

5. Reinicia el servidor.

## ⚙️ Configuración

Toda la configuración se encuentra en:

```lua
config/config.lua
```

Desde este archivo podrás modificar:

* Webhooks de Discord.
* Nombre del servidor.
* Mensajes enviados a Discord.
* Configuración general del sistema.

## 📌 Dependencias

* ESX Legacy
* FiveM Artifact actualizado

## 🔗 Soporte

Si encuentras algún error o deseas proponer mejoras, puedes abrir una Issue en el repositorio oficial.

Repositorio oficial:

https://github.com/aariidev/ari_logs

## 📄 Licencia

Este proyecto se distribuye bajo licencia MIT.

---

Desarrollado por AariDev ❤️
