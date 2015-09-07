###!
 * @license kaleidoscope
 * (c) sugarshin
 * License: MIT
###

"use strict"

require('insert-css') require '../index.styl'

{ Promise } = require 'es6-promise'
Shake = require 'shake.js'
debounce = require 'lodash.debounce'

FileRead = require './fileread'
Range = require './range'
Kaleidoscope = require './kaleidoscope'
Instagram = require './instagram'
{
  querySelector
  addListener
  remove
  toggleClass
} = require './util'

inputFile = querySelector '#file'
fileRead = new FileRead inputFile

inputRange = querySelector '#range'
range = new Range inputRange, text: querySelector '#result-range'

inputSearch = querySelector '#search'
button = querySelector '#search-instagram'
instagram = new Instagram inputSearch, button

toggleAuto = querySelector '#toggle-auto'

download = querySelector '#download'

shake = new Shake# threshold: 15
shake.start()



# todo ---------------------------------
instance = {}

wait = (time) ->
  return new Promise (resolve, reject) ->
    setTimeout ->
      resolve()
    , time

getSizeRadius = ->
  if window.ontouchstart isnt undefined
    w = window.screen.availWidth
    h = window.screen.availHeight
  else
    w = window.innerWidth
    h = window.innerHeight
  return Math.sqrt( (Math.max(w, h) ** 2) + (Math.min(w, h) ** 2) ) / 2

initKaleido = (img, src) ->
  instance.kaleidoscope = new Kaleidoscope
    output: querySelector '#kaleidoscope'
    image: img
    slices: range.getVal()
    # sqrt(縦 ** 2 + 横 ** 2) / 2 -> 半径
    radius: getSizeRadius()
    archive: querySelector '#archive-image'
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
    wait(1000).then ->
      setDownloadHref instance.kaleidoscope.getDataURL()

  wait(1000).then ->
    setDownloadHref instance.kaleidoscope.getDataURL()

addImage = (img, src, num) ->
  instance.kaleidoscope
    .updateImage img
    .outputArchive src, num
    .setCurrentArchiveNum num

setDownloadHref = (url) -> download.setAttribute 'href', url



# todo
# 初回画像セット
do ->
  img = document.createElement 'img'
  src = 'example.png'
  img.src = src
  fileRead.setLoadedSrcs src
  len = fileRead.getLoadedSrcs().length

  # todo -----------------------------
  if Kaleidoscope.isRun()
    addImage img, src, len - 1
  else
    initKaleido img, src



fileRead.on 'input:change', (ev) ->
  fileRead
    .read ev.target.files
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

        if download? then remove download



toggleText = (el) ->
  text = el.textContent
  if text is 'On auto play'
    el.textContent = 'Off auto play'
  else
    el.textContent = 'On auto play'

toggleDataAuto = (el) ->
  data = el.getAttribute 'data-auto'
  if data is 'true'
    el.setAttribute 'data-auto', 'false'
  else
    el.setAttribute 'data-auto', 'true'

addListener toggleAuto, 'click', (ev) ->
  ev.preventDefault()
  instance.kaleidoscope?.toggleAutoPlay()
  toggleDataAuto toggleAuto
  toggleText toggleAuto

addListener window, 'shake', ->
  instance.kaleidoscope?.toggleAutoPlay()
  toggleDataAuto toggleAuto
  toggleText toggleAuto

menu = querySelector '#open-menu-button'
addListener menu, 'click', (ev) ->
  ev.preventDefault()
  control = querySelector '.control'
  toggleClass control, 'opened'



onWindowResize = -> instance.kaleidoscope?.updateRadius getSizeRadius()
addListener window, 'resize.kaleidoscope', debounce onWindowResize, 300

# todo: for canvas click
addListener querySelector('#kaleidoscope'), 'click', ->
  clickEvent = document.createEvent 'HTMLEvents'
  clickEvent.initEvent 'click', true, false
  inputFile.dispatchEvent clickEvent
