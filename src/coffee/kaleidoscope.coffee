_ = require 'underscore'

Mixin = require '../../coffee-mixin/dest/mixin'
Eventz = require '../../eventz/dest/eventz'

module.exports =
  class Kaleidoscope
    Mixin.include @, Eventz

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

    defaults:
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

    constructor: (opts) ->
      @opts = _.extend {}, @defaults, opts

      @canvas = document.createElement 'canvas'
      @context = @canvas.getContext '2d'

      @_currentArchiveNum = 0

      @initStyle()
      @render()
      @events()

      _anyRun = true

    initStyle: ->
      @canvas.style.cssText = "
        position: absolute;
        margin-top: #{-@opts.radius}px;
        margin-left: #{-@opts.radius}px;
        top: 50%;
        left: 50%;
      "
      return this

    render: ->
      @opts.output.appendChild @canvas
      return this

    updateImage: (el) ->
      @opts.image = el
      return this

    updateSlices: (num) ->
      @opts.slices = num
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

    events: ->
      @opts.tx = @opts.offsetX
      @opts.ty = @opts.offsetY
      @opts.tr = @opts.offsetRotation

      onMouseMoved = (ev) =>
        dx = ev.pageX / window.innerWidth
        dy = ev.pageY / window.innerHeight

        hx = dx - 0.5
        hy = dy - 0.5

        @opts.tx = hx * @opts.radius * -2
        @opts.ty = hy * @opts.radius * 2
        @opts.tr = Math.atan2 hy, hx

      # todo ---------------------------
      onRotation = (ev) =>
        rR = ev.rotationRate
        g = rR.gamma

        if g > 1
          dx = Math.floor g / 10
          dy = Math.floor g / 10

          hx = dx - 0.5
          hy = dy - 0.5

          @opts.tx = hx * @opts.radius * 2
          @opts.ty = hy * @opts.radius * -2
          @opts.tr = Math.atan2 hy, hx

        else if g < -1
          dx = Math.floor g / 10
          dy = Math.floor g / 10

          hx = dx - 0.5
          hy = dy - 0.5

          @opts.tx = hx * @opts.radius * -2
          @opts.ty = hy * @opts.radius * 2
          @opts.tr = Math.atan2 hy, hx

      window.addEventListener 'mousemove', onMouseMoved

      window.addEventListener 'devicemotion', onRotation

      @update() if @opts.interactive

      @opts.archive.addEventListener 'click', (ev) =>
        @trigger 'archive:click', ev

      return this