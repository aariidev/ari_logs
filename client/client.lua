-- Función para abrir el formulario de anuncio
local function openAnnouncementDialog()
    local input = lib.inputDialog('📢 Anuncio a Discord', {
        {type = 'input', label = 'Título del Anuncio', required = true, placeholder = 'Ej: Mantenimiento Programado'},
        {type = 'textarea', label = 'Mensaje', required = true, placeholder = 'Escribe aquí los detalles...'}
    })

    if not input then return end 

    TriggerServerEvent('ari_logs:server:customAnnouncement', input[1], input[2])
end

lib.registerContext({
    id = 'ari_logs_admin_menu',
    title = '🛠️ Panel ari_logs',
    options = {
        {
            title = 'Enviar Anuncio Personalizado',
            description = 'Escribe un mensaje y envíalo directamente al canal de Discord.',
            icon = 'bullhorn',
            onSelect = openAnnouncementDialog 
        },
        {
            title = 'Pausar / Reanudar Logs',
            description = 'Activa o desactiva temporalmente el envío de logs automáticos.',
            icon = 'power-off',
            serverEvent = 'ari_logs:server:toggleLogs' 
        },
        {
            title = 'Enviar Webhook de Prueba',
            description = 'Comprueba si el bot de Discord está conectado.',
            icon = 'paper-plane',
            serverEvent = 'ari_logs:server:testWebhook'
        },
        {
            title = 'Información del Sistema',
            description = 'El script está cargado correctamente.',
            icon = 'circle-info',
            readOnly = true 
        }
    }
})


RegisterCommand('arilogs', function()
    
    local isAdmin = lib.callback.await('ari_logs:server:checkPermissions', false)

    if isAdmin then
        lib.showContext('ari_logs_admin_menu')
    else
        lib.notify({
            title = 'QUIETOOO PARAOOO!',
            description = '¿ande vas? Que tu no tienes permisos para esto.',
            type = 'error',
            icon = 'ban'
        })
    end
end, false)