keyboard = require 'msi-keyboard'


keyboardClear = ->
  keyboard.stopBlink()

module.exports = (data) ->
  return keyboardClear() if data?

  keyboard.color 'left',
      color: 'red'
      intensity: 'med'

  keyboard.color 'middle', 'green'

  keyboard.color 'right',
      color: 'sky'
      intensity: 'high'

  keyboard.blink ['left', 'middle', 'right'], 500
  