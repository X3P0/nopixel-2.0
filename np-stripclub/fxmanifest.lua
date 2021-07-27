fx_version 'cerulean'
games { 'gta5' }

client_script "@np-lib/client/cl_flags.lua"

client_scripts {
  "@PolyZone/client.lua",
  'cl_*.lua'
}

shared_script 'sh_*.lua'

server_script 'sv_*.lua'