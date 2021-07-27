fx_version 'cerulean'
games { 'gta5' }

client_script "@np-errorlog/client/cl_errorlog.lua"
client_script "@np-lib/client/cl_ui.lua"

client_scripts {
    '@np-lib/client/cl_rpc.lua',
    '@np-lib/shared/sh_cacheable.lua',
    "client/cl_*.lua"
}

server_scripts {
    '@np-lib/server/sv_rpc.lua',
    '@np-lib/server/sv_asyncExports.lua',
    'server/sv_*.lua',
}