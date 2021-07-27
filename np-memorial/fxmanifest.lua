fx_version "cerulean"

games {"gta5"}

description "Memorial"

server_script '@np-lib/server/sv_infinity.lua'

server_scripts {
    'server/*.lua'
}

client_scripts {
    'client.lua',
    'client/*.lua'
}

