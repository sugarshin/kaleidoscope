Kaleidoscope = require './kaleidoscope'
FileRead = require './fileread'

inputFile = document.getElementById 'file'
fileRead = new FileRead inputFile

inputFile.addEventListener 'change', (ev) ->
  fileRead
  .setImgSrc ev
  .then (results) ->
    # todo -----------------------------
    if Kaleidoscope.isRun()
      result = document.getElementById 'result'
      result.innerHTML = ''

    img = document.createElement 'img'

    # todo -----------------------------
    srcs = results[0].getImgSrc()
    img.src = srcs[srcs.length - 1]

    if window.ontouchstart isnt undefined
      w = window.screen.availWidth / 2
      h = window.screen.availHeight / 2
    else 
      w = window.innerWidth / 2
      h = window.innerHeight / 2

    kaleidoscope = new Kaleidoscope
      image: img
      slices: 10
      radius: Math.min w, h

    kaleidoscope.initStyle().render()#.events()
