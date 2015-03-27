"use strict"

{ EventEmitter } = require 'events'
objectAssign = require 'object-assign'

module.exports =
class Kaleidoscope extends EventEmitter

  _anyRun = false
  @isRun: -> _anyRun

  _requestAnimeFrame = do ->
    return (
      window.requestAnimationFrame or
      window.webkitRequestAnimationFrame or
      window.mozRequestAnimationFrame or
      window.msRequestAnimationFrame or
      window.oRequestAnimationFrame or
      (callback) ->
        window.setTimeout callback, 1000 / 60
    )

  _cancelAnimeFrame = do ->
    return (
      window.cancelAnimationFrame or
      window.webkitCancelAnimationFrame or
      window.mozCancelAnimationFrame or
      window.msCancelAnimationFrame or
      window.oCancelAnimationFrame or
      (id) ->
        window.clearTimeout id
    )

  HALF_PI: Math.PI / 2
  TWO_PI: Math.PI * 2

  _getRandomInt: (min, max) ->
    return Math.floor(Math.random() * (max - min + 1)) + min

  _defaults:
    output: null
    image: null
    offsetRotation: 0.0
    offsetScale: 1.0
    offsetX: 0.0
    offsetY: 0.0
    radius: 320
    slices: 10
    zoom: 1.0
    interactive: true
    ease: 0.1
    fps: 60
    archive: null
    startAutoPlay: null

  constructor: (opts) ->
    EventEmitter.call @
    @opts = objectAssign {}, @_defaults, opts

    @canvas = document.createElement 'canvas'
    @context = @canvas.getContext '2d'

    @_currentArchiveNum = 0

    @setStyle()
    @render()

    @draw()

    @events()

    if @opts.startAutoPlay is 'true'
      @startAutoPlay()
      @_isAutoPlaying = true
    else
      @addMouseEvent()
      @addRotateEvent()
      @_isAutoPlaying = false

    _anyRun = true

  setStyle: ->
    @canvas.style.cssText = "
      position: absolute;
      margin-top: #{-@opts.radius}px;
      margin-left: #{-@opts.radius}px;
      top: 50%;
      left: 50%;
    "
    return this

  getDataURL: -> @canvas.toDataURL()

  render: ->
    @opts.output.appendChild @canvas
    return this

  updateImage: (el) ->
    @opts.image = el
    @emit 'updateimage'
    return this

  updateSlices: (num) ->
    @opts.slices = num
    @emit 'updateslices'
    return this

  updateRadius: (val) ->
    @opts.radius = val
    @setStyle()
    @emit 'updateradius'
    return this

  setCurrentArchiveNum: (num) ->
    @_currentArchiveNum = num
    return this

  getCurrentArchiveNum: -> @_currentArchiveNum

  outputArchive: (src, num) ->
    div = document.createElement 'div'
    div.className = 'result-file-image'

    img = document.createElement 'img'
    img.src = src
    img.setAttribute 'data-num', num

    div.appendChild img

    @opts.archive.appendChild div
    return this

  draw: ->
    @canvas.width = @canvas.height = @opts.radius * 2
    @context.fillStyle = @context.createPattern @opts.image, 'repeat'

    scale = @opts.zoom * (@opts.radius / Math.min(@opts.image.width, @opts.image.height))
    step = @TWO_PI / @opts.slices
    cx = @opts.image.width / 2

    for i in [0..@opts.slices]
      @context.save()
      @context.translate @opts.radius, @opts.radius
      @context.rotate i * step

      @context.beginPath()
      @context.moveTo -0.5, -0.5
      @context.arc 0, 0, @opts.radius, step * -0.51, step * 0.51
      @context.lineTo 0.5, 0.5
      @context.closePath()

      @context.rotate @HALF_PI
      @context.scale scale, scale
      @context.scale [-1, 1][i % 2], 1
      @context.translate @opts.offsetX - cx, @opts.offsetY
      @context.rotate @opts.offsetRotation
      @context.scale @opts.offsetScale, @opts.offsetScale

      @context.fill()
      @context.restore()
    return this

  update: ->
    start = new Date().getTime()
    do update = =>
      _requestAnimeFrame update
      last = new Date().getTime()
      if last - start >= 1000 / @opts.fps
        delta = @opts.tr - @opts.offsetRotation
        theta = Math.atan2(Math.sin(delta), Math.cos(delta))

        @opts.offsetX += (@opts.tx - @opts.offsetX) * @opts.ease
        @opts.offsetY += (@opts.ty - @opts.offsetY) * @opts.ease
        @opts.offsetRotation += (theta - @opts.offsetRotation) * @opts.ease

        @draw()
        start = new Date().getTime()
    return this

  setPos: (x, y) ->
    @opts.tx = x * @opts.radius * -2
    @opts.ty = y * @opts.radius * 2
    @opts.tr = Math.atan2 y, x
    return this

  stopPlay: ->
    _cancelAnimeFrame @_autoPlayID
    return this

  autoPlay: ->
    start = new Date().getTime()
    posList = [
      [-.2, -.2] # top lef
      [.2, -.2] # top right
      [.2, .2] # bottom right
      [-.2, .2] # bottom left
    ]
    i = 0
    do autoPlay = =>
      @_autoPlayID = _requestAnimeFrame autoPlay
      last = new Date().getTime()
      if last - start >= 800 + @_getRandomInt(0, 500)
        @setPos posList[i][0], posList[i][1]
        if i is posList.length - 1
          i = 0
        else
          i++
        start = new Date().getTime()
    return this

  _onMouseMoved: (ev) =>
    dx = ev.pageX / window.innerWidth
    dy = ev.pageY / window.innerHeight
    hx = dx - 0.5
    hy = dy - 0.5
    @setPos hx, hy
    return this

  addMouseEvent: ->
    window.addEventListener 'mousemove', @_onMouseMoved
    return this

  rmMouseEvent: ->
    window.removeEventListener 'mousemove', @_onMouseMoved
    return this

  # todo ---------------------------
  _onRotation: (ev) =>
    a = ev.alpha
    dx = a / 100
    dy = a / 100

    hx = dx - 0.5
    hy = dy - 0.5
    @setPos hx, hy
    return this

  addRotateEvent: ->
    window.addEventListener 'deviceorientation', @_onRotation
    return this

  rmRotateEvent: ->
    window.removeEventListener 'deviceorientation', @_onRotation
    return this

  startAutoPlay: ->
    @rmMouseEvent()
    @rmRotateEvent()
    @autoPlay()
    @_isAutoPlaying = true
    return this

  stopAutoPlay: ->
    @stopPlay()
    @addMouseEvent()
    @addRotateEvent()
    @_isAutoPlaying = false
    return this

  toggleAutoPlay: ->
    if @_isAutoPlaying
      @stopAutoPlay()
    else
      @startAutoPlay()
    return this

  events: ->
    @opts.tx = @opts.offsetX
    @opts.ty = @opts.offsetY
    @opts.tr = @opts.offsetRotation

    @update() if @opts.interactive

    @opts.archive.addEventListener 'click', (ev) =>
      @emit 'archive:click', ev
      # @trigger 'archive:click', ev
    return this
