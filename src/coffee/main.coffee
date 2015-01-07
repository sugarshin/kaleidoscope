FileRead = require './fileread'
Range = require './range'
Kaleidoscope = require './kaleidoscope'

inputFile = document.getElementById 'file'
fileRead = new FileRead inputFile, result: document.getElementById 'result-file'

inputRange = document.getElementById 'range'
range = new Range inputRange, text: document.getElementById 'result-range'

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

    fileRead.outputResult srcs[srcs.length - 1]

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
      output: document.getElementById 'output'
      image: img
      slices: range.getVal()
      radius: Math.min w, h

fileRead.on 'result:click', (ev) ->
  target = ev.target
  if Kaleidoscope.isRun() and
  target.tagName.toLowerCase() is 'img'
    img = document.createElement 'img'
    img.src = target.currentSrc
    instance.kaleidoscope.setImage img

range.on 'input:change', (ev) ->
  # todo -----------------------------
  if Kaleidoscope.isRun()
    instance.kaleidoscope.setSlices range.getVal()
