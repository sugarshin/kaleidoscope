_ = require 'underscore'

Mixin = require './../../coffee-mixin/dest/mixin'
Eventz = require './../../eventz/dest/eventz'

FileRead = require './fileread'

module.exports =
  class Kaleidoscope

    HALF_PI: Math.PI / 2
    TWO_PI: Math.PI * 2

    defaults:
      offsetRotation: 0.0
      offsetScale: 1.0
      offsetX: 0.0
      offsetY: 0.0
      radius: 320
      slices: 10
      zoom: 1.0
      interactive: true
      ease: 0.1

    constructor: (opts) ->
      @opts = _.extend {}, @defaults, opts

      @canvas = document.createElement 'canvas'
      @context = @canvas.getContext '2d'
      @events()

    initStyle: ->
      @canvas.style.position = 'absolute'
      @canvas.style.marginLeft = -@opts.radius + 'px'
      @canvas.style.marginTop = -@opts.radius + 'px'
      @canvas.style.left = '50%'
      @canvas.style.top = '50%'
      return this

    render: ->
      document.body.appendChild @canvas
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

    events: ->
      @opts.tx = @opts.offsetX
      @opts.ty = @opts.offsetY
      @opts.tr = @opts.offsetRotation

      onMouseMoved = (event) =>
        cx = window.innerWidth / 2
        cy = window.innerHeight / 2

        dx = event.pageX / window.innerWidth
        dy = event.pageY / window.innerHeight

        hx = dx - 0.5
        hy = dy - 0.5

        @opts.tx = hx * @opts.radius * -2
        @opts.ty = hy * @opts.radius * 2
        @opts.tr = Math.atan2 hy, hx

      window.addEventListener 'mousemove', onMouseMoved

      do update = =>
        if @opts.interactive
          delta = @opts.tr - @opts.offsetRotation
          theta = Math.atan2(Math.sin(delta), Math.cos(delta))

          @opts.offsetX += (@opts.tx - @opts.offsetX) * @opts.ease
          @opts.offsetY += (@opts.ty - @opts.offsetY) * @opts.ease
          @opts.offsetRotation += (theta - @opts.offsetRotation) * @opts.ease

          do @draw

        setTimeout update, 1000 / 60

      return this