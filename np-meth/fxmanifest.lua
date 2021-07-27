fx_version 'cerulean'

games { 'gta5' }

client_script "@np-sync/client/lib.lua"
client_script "@np-lib/client/cl_ui.lua"

client_scripts {
  '@np-lib/client/cl_rpc.lua',
  '@np-lib/client/cl_animTask.lua',
  'client/cl_*.lua',
  "@PolyZone/client.lua",
}

server_script "@np-lib/server/sv_npx.js"
server_scripts {
  '@np-lib/server/sv_rpc.lua',
  '@np-lib/server/sv_rpc.js',
  '@np-lib/server/sv_sql.lua',
  '@np-lib/server/sv_sql.js',
  'server/sv_*.lua',
  'server/sv_*.js',
  'build-server/sv_*.js',
}
