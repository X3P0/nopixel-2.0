fx_version 'cerulean'

games {
  'gta5',
  'rdr3'
}

client_script "@np-lib/client/cl_ui.lua"

client_scripts {
  '@np-lib/client/cl_rpc.lua',
  '@np-lib/client/cl_animTask.lua',
  'client/cl_*.lua'
}

shared_scripts {
  '@np-lib/shared/sh_util.lua',
  "shared/sh_*.lua"
}

server_scripts {
  'server/sv_*.lua'
}