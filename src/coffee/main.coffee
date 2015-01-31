Promise = require 'bluebird'
Shake = require 'shake.js'
td = require 'throttle-debounce'
dom = require 'domquery'
bean = require 'bean'

FileRead = require './fileread'
Range = require './range'
Kaleidoscope = require './kaleidoscope'
Instagram = require './instagram'

$inputFile = dom '#file'
fileRead = new FileRead $inputFile[0]

$inputRange = dom '#range'
range = new Range $inputRange[0], text: dom('#result-range')[0]

$inputSearch = dom '#search'
$button = dom '#search-instagram'
instagram = new Instagram $inputSearch[0], $button[0]

$toggleAuto = dom '#toggle-auto'

$download = dom '#download'

shake = new Shake# threshold: 15
shake.start()



# todo ---------------------------------
instance = {}

wait = (time) ->
  return new Promise (resolve, reject) ->
    setTimeout ->
      resolve()
    , time

# remove = (el) -> el.parentNode.removeChild el

getSizeRadius = ->
  if window.ontouchstart isnt undefined
    w = window.screen.availWidth# / 2
    h = window.screen.availHeight# / 2
  else
    w = window.innerWidth# / 2
    h = window.innerHeight# / 2
  return Math.sqrt( (Math.max(w, h) ** 2) + (Math.min(w, h) ** 2) ) / 2#Math.min w, h

initKaleido = (img, src) ->
  instance.kaleidoscope = new Kaleidoscope
    output: dom('#kaleidoscope')[0]
    image: img
    slices: range.getVal()
    # sqrt(縦 ** 2 + 横 ** 2) / 2 -> 半径
    radius: getSizeRadius()
    archive: dom('#archive-image')[0]
    startAutoPlay: $toggleAuto.attr 'data-auto'

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

setDownloadHref = (url) -> $download.attr 'href', url



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

        if $download? then $download.remove()



changeText = ($el) ->
  text = $el.text()#Content
  if text is 'On auto play'
    $el.text 'Off auto play'
  else
    $el.text 'On auto play'

toggleData = ($el) ->
  data = $el.attr 'data-auto'
  if data is 'true'
    $el.attr 'data-auto', 'false'
  else
    $el.attr 'data-auto', 'true'

$toggleAuto[0].addEventListener 'click', (ev) ->
  ev.preventDefault()
  instance.kaleidoscope?.toggleAutoPlay()
  toggleData $toggleAuto
  changeText $toggleAuto

#-- Bug --
# $toggleAuto.on 'click', (ev) ->
#   ev.preventDefault()
#   instance.kaleidoscope?.toggleAutoPlay()
#   toggleData $toggleAuto
#   changeText $toggleAuto
# #, false

window.addEventListener 'shake', ->
  instance.kaleidoscope?.toggleAutoPlay()
  toggleData toggleAuto
  changeText toggleAuto

menu = dom '#open-menu-button'
menu[0].addEventListener 'click', (ev) ->
  ev.preventDefault()
  control = dom '.control'
  control.toggleClass 'opened'



onWindowResize = -> instance.kaleidoscope?.updateRadius getSizeRadius()
window.addEventListener 'resize', td.debounce 300, onWindowResize

# todo: canvasクリック用
bean.on dom('#kaleidoscope')[0], 'click', ->
  bean.fire $inputFile[0], 'click'
