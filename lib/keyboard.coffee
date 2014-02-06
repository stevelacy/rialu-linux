keyboard = require 'msi-keyboard'


setKeyboard = (region, object) ->
  #console.log region, object.color, object.intensity
  keyboard.color region,{
    color: object.color
    intensity: object.intensity
  }

module.exports = setKeyboard