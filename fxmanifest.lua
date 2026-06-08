fx_version 'cerulean'
game 'gta5'

author 'Ari'
description 'Ari Logs - A simple logging system for FiveM servers.'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua'
}

server_script 'server/server.lua'
client_script 'client/client.lua'