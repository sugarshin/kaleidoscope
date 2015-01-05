Kaleidoscope = require './kaleidoscope'
FileRead = require './fileread'

inputFile = document.getElementById 'file'
fileRead = new FileRead inputFile

inputFile.addEventListener 'change', (ev) ->
  fileRead
  .setImgSrc ev
  .then (results) ->
    img = document.createElement 'img'
    img.src = results[0].getImgSrc()[0]

    kaleidoscope = new Kaleidoscope
      image: img
      slices: 10
      radius: 480

    kaleidoscope.initStyle().render()#.events()
