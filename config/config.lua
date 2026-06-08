Config = {}

Config.BotName = "Pon lo que quieras aqui| ari_logs"

-- Configuración de Webhooks por categoría
Config.Webhooks = {
    default    = "",
    joins      = "", -- Cambia esto por tu webhook real
    chat       = "", -- Cambia esto por tu webhook real
    deaths     = "", -- Cambia esto por tu webhook real
    moderation = "", -- Cambia esto por tu webhook real
}

-- Configuración de Permisos
-- Si el jugador tiene el grupo en ESX, o su identificador coincide con Admins, tendrá acceso al menú
Config.AdminGroups = {
    ['admin'] = true,
    ['superadmin'] = true
}

-- Lista de Discord IDs que también tendrán permiso (si no usan ESX groups o para dar permisos directos)
Config.Admins = {
    "" --  discord:123456789012345678
}

-- Opciones de Privacidad
Config.SendFullIP = true -- Si es true, envía la IP real. Si es false, la oculta parcialmente (ej. 192.168.x.x)

-- Iconos y Avatares opcionales
Config.AvatarURL = "https://i.imgur.com/8Yv9W5g.png" -- Cambia por el logo de tu servidor