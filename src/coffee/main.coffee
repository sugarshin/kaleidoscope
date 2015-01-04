$ = require 'jquery'
_ = require 'underscore'

Kaleidoscope = require './kaleidoscope'
FileRead = require './fileread'

inputFile = document.getElementById 'file'
fileRead = new FileRead inputFile

inputFile.addEventListener 'change', (ev) ->
  console.log "1"
  fileRead
  .setImgTag ev
  .done (self) ->
    console.log self.getImgTag()
    for img, i in self.getImgTag()
      $('#result').append img
# $('#result')