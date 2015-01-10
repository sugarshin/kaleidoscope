FileRead = require './fileread'
Range = require './range'
Kaleidoscope = require './kaleidoscope'
Shake = require 'shakejs'

inputFile = document.getElementById 'file'
fileRead = new FileRead inputFile

inputRange = document.getElementById 'range'
range = new Range inputRange, text: document.getElementById 'result-range'

shake = new Shake# threshold: 15
shake.start()



# todo ---------------------------------
instance = {}

initKaleido = (img, src) ->
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
    archive: document.getElementById 'archive-image'

  instance.kaleidoscope
  .outputArchive src, 0
  .setCurrentArchiveNum 0

  instance.kaleidoscope.on 'archive:click', (ev) ->
    target = ev.target
    if Kaleidoscope.isRun() and
    target.tagName.toLowerCase() is 'img'
      img = document.createElement 'img'
      img.src = target.src

      instance.kaleidoscope
      .updateImage img
      .setCurrentArchiveNum parseInt target.attributes[1].value, 10

addImage = (img, src, num) ->
  instance.kaleidoscope
  .updateImage img
  .outputArchive src, num
  .setCurrentArchiveNum num

changeNextImage = ->
  img = document.createElement 'img'
  srcs = fileRead.getLoadedSrcs()
  current = instance.kaleidoscope.getCurrentArchiveNum()

  if current is srcs.length - 1
    next = 0
  else
    next = current + 1

  img.src = srcs[next]

  instance.kaleidoscope
  .updateImage img
  .setCurrentArchiveNum next



fileRead.on 'input:change', (ev) ->
  fileRead
  .read ev
  .then (evArr) ->
    img = document.createElement 'img'
    src = evArr[0].target.result
    img.src = src

    len = fileRead.getLoadedSrcs().length

    # todo -----------------------------
    if Kaleidoscope.isRun()
      addImage img, src, len - 1
    else
      initKaleido img, src

range.on 'input:change', (ev) ->
  # todo -----------------------------
  if Kaleidoscope.isRun()
    instance.kaleidoscope.updateSlices range.getVal()

window.addEventListener 'shake', changeNextImage
