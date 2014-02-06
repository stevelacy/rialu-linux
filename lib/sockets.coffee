io  = require "socket.io-client"
async = require  "async"
setKeyboard = require "./keyboard"
keyboardPanic = require "./keyboardPanic"
myLoc = require "./location"
config = require "./config"
{exec} = require "child_process"

client = io.connect config.server,
  'force new connection': true
  'reconnect': true
  'reconnection delay': 1000
  'max reconnection attempts': 10


panicNum = 0
twitter = config.keys.twitter

check = 0
sendReply = (message, device) ->
  client.emit 'reply', {message:message, device:config.nickname}

client.on 'connect', (socket) ->
  if check == 0
    console.log "connected"
    client.emit 'auth', {auth:twitter, nickname:config.nickname, os:config.os}
    sendReply "connected", "#{config.nickname}"
    check = 1
  client.on 'disconnect', (dis) ->
    check = 0
    console.log "disconnected from server!"
  
client.on 'auth', (auth) ->
  console.log "Twitter authorized #{auth.auth}"

client.on 'volume', (volume) ->
  return true unless volume.client == config.nickname
  console.log "volume #{volume.volume}"
  exec "amixer set Master #{volume.volume}"
  #sendReply "Volume: #{volume.volume}", "#{config.nickname}" #Optional for Verbose emitting

client.on 'lock', (lock) ->
  return true unless lock.client == config.nickname
  exec 'gnome-screensaver-command --lock'
  sendReply "Locking ", "#{config.nickname}"

client.on 'panic', (panic) ->
  return true unless panic.client == config.nickname
  console.log "panic #{panic.panic}"
  if panicNum == 0
    panicNum = 1
    exec "gnome-screensaver-command --lock && amixer set Master 100 && cvlc #{__dirname}/assets/alarm.mp3"
    keyboardPanic()
    sendReply "Panic Started!","#{config.nickname}"
  else
    panicNum = 0
    keyboardPanic "end"
    exec 'killall vlc'

client.on 'horn', (horn) ->
  return true unless horn.client == config.nickname
  console.log "horn #{horn.horn}"
  exec "amixer set Master 100 && cvlc #{__dirname}/assets/horn.mp3"
  sendReply "Horn", "#{config.nickname}"

client.on 'command', (command) ->
  return true unless command.client == config.nickname
  console.log "command #{command.command}"
  exec command.command
  sendReply "Run: #{command.command}", "#{config.nickname}"

client.on 'gps', (gps) ->
  return true unless gps.client == config.nickname
  myLoc (gps) ->
    console.log gps
    client.emit 'gps', {gps:gps}

client.on 'keyboard', (keyboard) ->
  return true unless keyboard.client == config.nickname
  console.log "keyboard #{JSON.stringify keyboard.keyboard}"
  sendReply "Keyboard", "#{config.nickname}"
  async.forEach Object.keys(keyboard.keyboard.data), (item, cb) ->
    setKeyboard(item, keyboard.keyboard.data[item])
    cb
  , (err) ->
    console.log err if err?
    console.log "done"
client.on 'webcam', (webcam) ->
  return true unless webcam.client == config.nickname
  console.log "webcam #{JSON.stringify webcam.photo}"
    
