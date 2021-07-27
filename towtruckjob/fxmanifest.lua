fx_version 'cerulean'
games {'gta5'}

client_script "@np-errorlog/client/cl_errorlog.lua"


client_script {
  "@np-lib/client/cl_flags.lua",
  "@np-sync/client/lib.lua",
  "sh_tow.lua"
}

server_script "sv_towgarage.lua"
