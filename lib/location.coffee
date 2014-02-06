location = require "wifi-location"

module.exports = (cb) ->
  location.getTowers (err, towers) ->
    location.getLocation towers, (err, loc) ->
      cb loc
    