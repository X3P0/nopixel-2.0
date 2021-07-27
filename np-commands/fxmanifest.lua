fx_version 'cerulean'
games { 'gta5' }

--[[ dependencies {
    "np-lib",
    "np-ui"
} ]]--

client_script "@np-lib/client/cl_ui.lua"

client_scripts {
    '@np-lib/client/cl_rpc.lua',
    'cl_*.lua',
}

shared_script {
  '@np-lib/shared/sh_util.lua',
}

server_scripts {
    '@np-lib/server/sv_rpc.lua',
    '@np-lib/server/sv_sql.lua',
    '@np-lib/server/sv_infinity.lua',
    'sv_*.lua',
}


