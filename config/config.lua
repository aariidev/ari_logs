Config = {}

Config.BotName = "Logs Ari Tets | ari_logs"

-- Configuración de Webhooks por categoría
Config.Webhooks = {
    default    = "https://discord.com/api/webhooks/1497386820009328776/eAY_2YzoMcb27O_OaTFSbtLh1KWqBLPy_fYUwqGj0FLP33K_DqqJzt6hpl_wsiz4TLef",
    joins      = "https://discord.com/api/webhooks/1497386820009328776/eAY_2YzoMcb27O_OaTFSbtLh1KWqBLPy_fYUwqGj0FLP33K_DqqJzt6hpl_wsiz4TLef", -- Cambia esto por tu webhook real
    chat       = "https://discord.com/api/webhooks/1497386820009328776/eAY_2YzoMcb27O_OaTFSbtLh1KWqBLPy_fYUwqGj0FLP33K_DqqJzt6hpl_wsiz4TLef", -- Cambia esto por tu webhook real
    deaths     = "https://discord.com/api/webhooks/1497386820009328776/eAY_2YzoMcb27O_OaTFSbtLh1KWqBLPy_fYUwqGj0FLP33K_DqqJzt6hpl_wsiz4TLef", -- Cambia esto por tu webhook real
    moderation = "https://discord.com/api/webhooks/1497386820009328776/eAY_2YzoMcb27O_OaTFSbtLh1KWqBLPy_fYUwqGj0FLP33K_DqqJzt6hpl_wsiz4TLef", -- Cambia esto por tu webhook real
}

-- Configuración de Permisos
-- Si el jugador tiene el grupo en ESX, o su identificador coincide con Admins, tendrá acceso al menú
Config.AdminGroups = {
    ['admin'] = true,
    ['superadmin'] = true
}

-- Lista de Discord IDs que también tendrán permiso (si no usan ESX groups o para dar permisos directos)
Config.Admins = {
    "discord:819080793447333918"
}

-- Opciones de Privacidad
Config.SendFullIP = true -- Si es true, envía la IP real. Si es false, la oculta parcialmente (ej. 192.168.x.x)

-- Iconos y Avatares opcionales
Config.AvatarURL = "https://i.imgur.com/8Yv9W5g.png" -- Cambia por el logo de tu servidor