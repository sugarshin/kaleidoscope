FileRead = require './fileread'
Kaleidoscope = require './kaleidoscope'

inputFile = document.getElementById 'file'
fileRead = new FileRead inputFile

# todo ---------------------------------
instance = {}

fileRead.on 'input:change', (ev) ->
  fileRead
  .setImgSrc ev
  .then (results) ->
    img = document.createElement 'img'

    # todo -----------------------------
    srcs = results[0].getImgSrc()
    img.src = srcs[srcs.length - 1]

    # todo -----------------------------
    if Kaleidoscope.isRun()
      instance.kaleidoscope.setImage img
      return

    if window.ontouchstart isnt undefined
      w = window.screen.availWidth / 2
      h = window.screen.availHeight / 2
    else 
      w = window.innerWidth / 2
      h = window.innerHeight / 2

    instance.kaleidoscope = new Kaleidoscope
      image: img
      slices: 10
      radius: Math.min w, h

    instance.kaleidoscope.initStyle().render()
