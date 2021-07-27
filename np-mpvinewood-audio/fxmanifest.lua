fx_version 'cerulean'
game 'gta5'

 dependencies {
} 

 files {
  'audio/dlcvinewood_amp.dat10',
  'audio/dlcvinewood_amp.dat10.nametable',
  'audio/dlcvinewood_amp.dat10.rel',
  'audio/dlcvinewood_game.dat151',
  'audio/dlcvinewood_game.dat151.nametable',
  'audio/dlcvinewood_game.dat151.rel',
  'audio/dlcvinewood_mix.dat15',
  'audio/dlcvinewood_mix.dat15.nametable',
  'audio/dlcvinewood_mix.dat15.rel',
  'audio/dlcvinewood_sounds.dat54',
  'audio/dlcvinewood_sounds.dat54.nametable',
  'audio/dlcvinewood_sounds.dat54.rel',
  'audio/dlcvinewood_speech.dat4',
  'audio/dlcvinewood_speech.dat4.nametable',
  'audio/dlcvinewood_speech.dat4.rel',
	'audio/sfx/dlc_vinewood/*.awc',
}

data_file 'AUDIO_GAMEDATA' 'audio/dlcvinewood_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/dlcvinewood_sounds.dat'
data_file 'AUDIO_SYNTHDATA' 'audio/dlcvinewood_amp.dat'
data_file 'AUDIO_WAVEPACK' 'audio/sfx/dlc_vinewood'
data_file 'AUDIO_DYNAMIXDATA' 'audio/dlcvinewood_mix.dat'
data_file 'AUDIO_SPEECHDATA' 'audio/dlcvinewood_speech.dat'

client_script 'data/names.lua'

