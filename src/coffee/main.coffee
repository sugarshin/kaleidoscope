Kaleidoscope = require './kaleidoscope'
FileRead = require './fileread'

inputFile = document.getElementById 'file'
fileRead = new FileRead inputFile

inputFile.addEventListener 'change', (ev) ->
  fileRead
  .setImgSrc ev
  .then (results) ->
    el = document.getElementById 'result'
    for src, i in results[0].getImgSrc()
      img = document.createElement 'img'
      img.src = src
      el.appendChild img
