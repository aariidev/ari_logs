local ESX = nil

if GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended']:getSharedObject()
end

local logsEnabled = true

local DEFAULT_COLOR = 8421504
local DESCRIPTION_LIMIT = 3900
local FIELD_VALUE_LIMIT = 1000

local function cleanText(value, fallback)
    if value == nil or value == "" then
        return fallback or "N/A"
    end

    value = tostring(value)
    value = value:gsub("```", "` ` `")
    value = value:gsub("[%c]", function(char)
        if char == "\n" or char == "\r" or char == "\t" then
            return char
        end
        return " "
    end)

    return value
end

local function trimText(value, limit)
    value = cleanText(value)
    if #value <= limit then return value end
    return value:sub(1, limit - 3) .. "..."
end

local function quoteBlock(value, limit)
    value = trimText(value, limit)

    local lines = {}
    for line in (value .. "\n"):gmatch("(.-)\n") do
        if line == "" then
            line = " "
        end

        lines[#lines + 1] = "> " .. line
    end

    return table.concat(lines, "\n")
end

local function textBlock(label, value)
    return ("**%s**\n%s"):format(label, quoteBlock(value, FIELD_VALUE_LIMIT))
end

local function joinBlocks(blocks)
    local cleaned = {}
    for _, block in ipairs(blocks) do
        if block and block ~= "" then
            cleaned[#cleaned + 1] = block
        end
    end

    return trimText(table.concat(cleaned, "\n"), DESCRIPTION_LIMIT)
end

local function embedField(name, value, inline)
    return {
        name = cleanText(name, "Detalle"),
        value = quoteBlock(value, FIELD_VALUE_LIMIT),
        inline = inline == true
    }
end

local function normalizeFields(fields)
    if not fields then return nil end

    local normalized = {}
    for _, field in ipairs(fields) do
        if field and field.name and field.value then
            normalized[#normalized + 1] = embedField(field.name, field.value, field.inline)
        end
    end

    return normalized
end

local function getWebhook(channel)
    if not Config.Webhooks then return "" end
    local hook = Config.Webhooks[channel]
    if not hook or hook == "" then
        return Config.Webhooks['default'] or ""
    end
    return hook
end

local function buildEmbed(title, msg, color, fields)
    local description = msg
    local embedFields = fields

    if type(msg) == "table" then
        description = msg.description or msg.message or ""
        embedFields = msg.fields or fields
    end

    local embed = {
        color = color or DEFAULT_COLOR,
        title = cleanText(title, "Log"),
        description = trimText(description, DESCRIPTION_LIMIT),
        footer = {
            text = Config.BotName,
            icon_url = Config.AvatarURL
        },
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
    }

    embedFields = normalizeFields(embedFields)

    if embedFields and #embedFields > 0 then
        embed.fields = embedFields
    end

    return embed
end

local function postWebhook(hook, payload, channel)
    PerformHttpRequest(hook, function(statusCode, response)
        statusCode = tonumber(statusCode) or 0
        if statusCode < 200 or statusCode >= 300 then
            print(("[ari_logs] Error enviando webhook '%s'. HTTP %s: %s"):format(
                tostring(channel),
                tostring(statusCode),
                trimText(response or "Sin respuesta", 300)
            ))
        end
    end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
end

-- Export function updated to receive channel
local function SendLog(channel, title, msg, color, fields)
    if not logsEnabled then return end 

    local hook = getWebhook(channel)
    if hook == "" or hook == "TU_WEBHOOK_AQUI" then 
        print("^1[ari_logs] ERROR: Webhook inválido para el canal: " .. tostring(channel) .. "^0")
        return 
    end
    
    postWebhook(hook, {
        username = Config.BotName, 
        avatar_url = Config.AvatarURL,
        embeds = { buildEmbed(title, msg, color, fields) }
    }, channel)
end

exports('SendLog', SendLog)

-- Mantenemos compatibilidad con el formato antiguo del export (sin especificar canal)
exports('SendLogOld', function(title, msg, color)
    SendLog('default', title, msg, color)
end)

-- ==========================================
-- FUNCIONES DE UTILIDAD
-- ==========================================

local function getPlayerIdentifiersList(source)
    local identifiers = {}
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if id:find("^steam:") then identifiers.steam = id end
        if id:find("^ip:") then identifiers.ip = id:gsub("ip:", "") end
        if id:find("^discord:") then identifiers.discord = id end
        if id:find("^license:") then identifiers.license = id end
    end
    return identifiers
end

local function formatIP(ip)
    if not ip then return "Desconocida" end
    if Config.SendFullIP then
        return ip
    else
        local parts = {}
        for part in string.gmatch(ip, "[^%.]+") do
            table.insert(parts, part)
        end
        if #parts == 4 then
            return parts[1] .. "." .. parts[2] .. ".*.*"
        end
        return "IP Oculta"
    end
end

local function formatIdentifiersString(ids)
    return string.format("🎮 Steam: %s\n💬 Discord: %s\n🔑 License: %s\n🌐 IP: %s",
        ids.steam or "N/A",
        ids.discord and ids.discord:gsub("discord:", "") or "N/A",
        ids.license or "N/A",
        formatIP(ids.ip)
    )
end

local function formatPlayerLine(source, name)
    if not name and source then
        name = GetPlayerName(source)
    end

    return ("%s (ID: %s)"):format(cleanText(name, "Desconocido"), tostring(source or "N/A"))
end

local function eventValue(eventData, key)
    if type(eventData) ~= "table" then return nil end
    return eventData[key]
end

-- ==========================================
-- EVENTOS DE CONEXIÓN Y DESCONEXIÓN
-- ==========================================

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    local ids = getPlayerIdentifiersList(src)
    local msg = joinBlocks({
        textBlock("👤 Jugador", formatPlayerLine(src, name)),
        textBlock("🪪 Identificadores", formatIdentifiersString(ids))
    })
    SendLog('joins', "📥 Jugador Conectándose", msg, 3066993) -- Verde
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    local name = GetPlayerName(src)
    if not name then return end
    local ids = getPlayerIdentifiersList(src)
    local msg = joinBlocks({
        textBlock("👤 Jugador", formatPlayerLine(src, name)),
        textBlock("📄 Razón", reason),
        textBlock("🪪 Identificadores", formatIdentifiersString(ids))
    })
    SendLog('joins', "📤 Jugador Desconectado", msg, 15158332) -- Rojo
end)

-- ==========================================
-- CHAT Y COMANDOS
-- ==========================================

AddEventHandler('chatMessage', function(source, name, message)
    local src = source
    if not src then return end
    
    local isCommand = string.sub(message, 1, 1) == "/"
    local title = isCommand and "⌨️ Comando Usado" or "💬 Mensaje de Chat"
    local color = isCommand and 3447003 or 9807270 -- Azul para comandos, Gris para chat
    
    local msg = joinBlocks({
        textBlock("👤 Jugador", formatPlayerLine(src, name)),
        textBlock(isCommand and "⌨️ Comando" or "💬 Mensaje", message)
    })
    SendLog('chat', title, msg, color)
end)

-- ==========================================
-- MUERTES (Requiere baseevents)
-- ==========================================

RegisterNetEvent('baseevents:onPlayerDied', function(killedBy, pos)
    local src = source
    local name = GetPlayerName(src)
    local msg = joinBlocks({
        textBlock("👤 Jugador", formatPlayerLine(src, name)),
        textBlock("❤️ Estado", "Ha muerto")
    })
    SendLog('deaths', "☠️ Muerte", msg, 10038562) -- Rojo oscuro
end)

RegisterNetEvent('baseevents:onPlayerKilled', function(killerId, deathData)
    local src = source
    local victimName = GetPlayerName(src)
    local killerName = killerId and GetPlayerName(killerId) or nil
    
    local blocks = {
        textBlock("🔫 Asesino", formatPlayerLine(killerId, killerName)),
        textBlock("💀 Víctima", formatPlayerLine(src, victimName))
    }
    
    if deathData and deathData.weaponType then
        blocks[#blocks + 1] = textBlock("🧨 Arma", ("Hash %s"):format(deathData.weaponType))
    end
    
    SendLog('deaths', "🔫 Asesinato", joinBlocks(blocks), 15158332) -- Rojo brillante
end)

-- ==========================================
-- EVENTOS DE TXADMIN
-- ==========================================

AddEventHandler('txAdmin:events:playerWarned', function(eventData)
    local msg = joinBlocks({
        textBlock("🛡️ Admin", eventValue(eventData, "author")),
        textBlock("👤 Jugador", eventValue(eventData, "targetName")),
        textBlock("📄 Razón", eventValue(eventData, "reason"))
    })
    SendLog('moderation', "⚠️ Jugador Advertido", msg, 16753920) -- Naranja
end)

AddEventHandler('txAdmin:events:playerKicked', function(eventData)
    local msg = joinBlocks({
        textBlock("🛡️ Admin", eventValue(eventData, "author")),
        textBlock("👤 Jugador", eventValue(eventData, "targetName")),
        textBlock("📄 Razón", eventValue(eventData, "reason"))
    })
    SendLog('moderation', "👢 Jugador Expulsado", msg, 15158332) -- Rojo
end)

AddEventHandler('txAdmin:events:playerBanned', function(eventData)
    local msg = joinBlocks({
        textBlock("🛡️ Admin", eventValue(eventData, "author")),
        textBlock("👤 Jugador", eventValue(eventData, "targetName")),
        textBlock("📄 Razón", eventValue(eventData, "reason"))
    })
    SendLog('moderation', "🔨 Jugador Baneado", msg, 15158332) -- Rojo
end)

AddEventHandler('txAdmin:events:announcement', function(eventData)
    local msg = joinBlocks({
        textBlock("🛡️ Admin", eventValue(eventData, "author")),
        textBlock("💬 Mensaje", eventValue(eventData, "message"))
    })
    SendLog('moderation', "📢 Anuncio de txAdmin", msg, 3447003) -- Azul
end)

-- ==========================================
-- SISTEMA DE ADMINISTRACIÓN Y PERMISOS
-- ==========================================

local function isPlayerAdmin(source)
    -- Verificar si tiene permiso de txAdmin o ace general
    if IsPlayerAceAllowed(source, 'command.admin') or IsPlayerAceAllowed(source, 'command') then
        return true
    end

    -- Verificar grupos ESX
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer and xPlayer.getGroup then
            if Config.AdminGroups[xPlayer.getGroup()] then
                return true
            end
        end
    end

    -- Verificar IDs explícitos de Discord
    local identifiers = getPlayerIdentifiersList(source)
    if identifiers.discord then
        for _, adminId in ipairs(Config.Admins) do
            if identifiers.discord == adminId then
                return true
            end
        end
    end

    return false
end

lib.callback.register('ari_logs:server:checkPermissions', function(source)
    return isPlayerAdmin(source)
end)

local function notifyNoPermission(source)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Sin permisos',
        description = 'No tienes acceso a esta acción.',
        type = 'error'
    })
end

RegisterNetEvent('ari_logs:server:customAnnouncement', function(title, message)
    local src = source
    if isPlayerAdmin(src) then
        local adminName = GetPlayerName(src)
        local formattedMessage = joinBlocks({
            textBlock("📨 Enviado por", formatPlayerLine(src, adminName)),
            textBlock("💬 Mensaje", message)
        })
        
        local previousState = logsEnabled
        logsEnabled = true 
        SendLog('default', "📣 " .. cleanText(title, "Anuncio"), formattedMessage, 10181046) 
        logsEnabled = previousState 

        TriggerClientEvent('ox_lib:notify', src, { title = 'Enviado', description = 'Anuncio publicado en Discord.', type = 'success' })
    else
        notifyNoPermission(src)
    end
end)

RegisterNetEvent('ari_logs:server:toggleLogs', function()
    local src = source
    if isPlayerAdmin(src) then
        logsEnabled = not logsEnabled 
        
        local statusText = logsEnabled and "REANUDADOS" or "PAUSADOS"
        local notifyType = logsEnabled and "success" or "warning"
        local adminName = GetPlayerName(src)
        local currentState = logsEnabled

        logsEnabled = true
        SendLog('moderation', "🔁 Estado de Logs Actualizado", joinBlocks({
            textBlock("🛡️ Admin", formatPlayerLine(src, adminName)),
            textBlock("📌 Estado", statusText)
        }), currentState and 3066993 or 16753920)
        logsEnabled = currentState

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Estado Actualizado',
            description = 'Los logs han sido ' .. statusText .. '.',
            type = notifyType
        })
    else
        notifyNoPermission(src)
    end
end)

RegisterNetEvent('ari_logs:server:testWebhook', function()
    local src = source
    if isPlayerAdmin(src) then
        local previousState = logsEnabled
        logsEnabled = true 
        SendLog('default', "🔧 Prueba de Sistema", textBlock("📌 Estado", "El menú de administración funciona y el webhook principal está conectado correctamente."), 5763719) 
        SendLog('joins', "🔧 Prueba de Joins", textBlock("📌 Estado", "Prueba de canal de conexiones."), 3066993)
        logsEnabled = previousState

        TriggerClientEvent('ox_lib:notify', src, { title = 'Éxito', description = 'Mensajes de prueba enviados a todos los canales configurados.', type = 'success' })
    else
        notifyNoPermission(src)
    end
end)

-- ==========================================
-- VERSION CHECKER
-- ==========================================

local GITHUB_USER = "aariidev"
local GITHUB_REPO = "ari_logs"

CreateThread(function()
    Wait(5000)

    local currentVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)

    PerformHttpRequest(
        ("https://api.github.com/repos/%s/%s/releases/latest"):format(
            GITHUB_USER,
            GITHUB_REPO
        ),
        function(statusCode, response)
            if statusCode ~= 200 then
                print("^3[ari_logs]^7 No se pudo comprobar si existen actualizaciones.")
                return
            end

            local success, data = pcall(json.decode, response)

            if not success or not data then
                print("^1[ari_logs]^7 Error al procesar la respuesta de GitHub.")
                return
            end

            local latestVersion = data.tag_name

            if not latestVersion then
                return
            end

            if latestVersion ~= currentVersion then
                print("^3========================================================^7")
                print("^3[ari_logs]^7 Nueva versión disponible")
                print(("^7Versión instalada: ^1%s^7"):format(currentVersion))
                print(("^7Última versión: ^2%s^7"):format(latestVersion))
                print(("^7Descargar: ^5https://github.com/%s/%s/releases^7"):format(
                    GITHUB_USER,
                    GITHUB_REPO
                ))
                print("^3========================================================^7")
            else
                print(("^2[ari_logs]^7 Versión actual (%s)"):format(currentVersion))
            end
        end,
        "GET",
        "",
        {
            ["User-Agent"] = "FiveM ari_logs"
        }
    )
end)
