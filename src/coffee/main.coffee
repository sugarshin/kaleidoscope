Promise = require 'bluebird'
Shake = require 'shake.js'

FileRead = require './fileread'
Range = require './range'
Kaleidoscope = require './kaleidoscope'
Instagram = require './instagram'

inputFile = document.getElementById 'file'
fileRead = new FileRead inputFile

inputRange = document.getElementById 'range'
range = new Range inputRange, text: document.getElementById 'result-range'

inputSearch = document.getElementById 'search'
button = document.getElementById 'search-instagram'

instagram = new Instagram inputSearch, button

toggleAuto = document.getElementById 'toggle-auto'

download = document.getElementById 'download'

shake = new Shake# threshold: 15
shake.start()



# todo ---------------------------------
instance = {}

wait = (time) ->
  new Promise (resolve, reject) ->
    setTimeout ->
      resolve()
    , time

remove = (el) -> el.parentNode.removeChild el

initKaleido = (img, src) ->
  if window.ontouchstart isnt undefined
    w = window.screen.availWidth / 2
    h = window.screen.availHeight / 2
  else
    w = window.innerWidth / 2
    h = window.innerHeight / 2

  instance.kaleidoscope = new Kaleidoscope
    output: document.getElementById 'kaleidoscope'
    image: img
    slices: range.getVal()
    radius: Math.min w, h
    archive: document.getElementById 'archive-image'
    startAutoPlay: toggleAuto.getAttribute 'data-auto'

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

  instance.kaleidoscope.on 'updateimage', ->
    wait(1000).then (_self) ->
      setDownloadHref instance.kaleidoscope.getDataURL()

  wait(1000).then (_self) ->
    setDownloadHref instance.kaleidoscope.getDataURL()

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

setDownloadHref = (url) ->
  download.setAttribute 'href', url



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

instagram.on 'search:submit', (ev, url) ->
  instagram
    .get url
    .then (data) ->
      # todo -----------------------------
      if data.data.length is 0
        alert 'そんな画像はありませんでした'
        return
      else
        img = document.createElement 'img'
        src = instagram.getRandomImage(data).url
        img.src = src

        fileRead.setLoadedSrcs src
        len = fileRead.getLoadedSrcs().length

        # todo -----------------------------
        if Kaleidoscope.isRun()
          addImage img, src, len - 1
        else
          initKaleido img, src

        if download?
          remove download



changeText = (el) ->
  text = el.textContent
  if text is 'On auto play'
    el.textContent = 'Off auto play'
  else
    el.textContent = 'On auto play'

toggleData = (el) ->
  data = el.getAttribute 'data-auto'
  if data is 'true'
    el.setAttribute 'data-auto', 'false'
  else
    el.setAttribute 'data-auto', 'true'

toggleAuto.addEventListener 'click', (ev) ->
  ev.preventDefault()
  instance.kaleidoscope?.toggleAutoPlay()
  toggleData this
  changeText this

window.addEventListener 'shake', ->
  instance.kaleidoscope?.toggleAutoPlay()
  toggleData toggleAuto
  changeText toggleAuto

menu = document.getElementById 'open-menu-button'
menu.addEventListener 'click', (ev) ->
  ev.preventDefault()
  control = document.querySelector '.control'
  control.classList.toggle 'opened'