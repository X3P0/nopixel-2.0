fx_version 'cerulean'
games { 'gta5' }

--[[ dependencies {
    "np-sync",
    "np-flags",
    "np-npcs"
} ]]--

client_script "@np-sync/client/lib.lua"
client_script "@np-lib/client/cl_flags.lua"
client_script "@np-lib/client/cl_vehicles.lua"
client_script "@np-lib/client/cl_rpc.lua"

client_scripts {
    "client/*.lua",
    "client/modules/*.lua"
}

server_script "@np-lib/server/sv_rpc.lua"

server_scripts {
    "server/classes/*.lua",
    "server/*.lua",
    "server/controllers/*.lua",
}