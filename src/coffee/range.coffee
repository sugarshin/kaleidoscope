extend = require 'node.extend'

inherits = require 'inherits'
EventEmitter = require('events').EventEmitter



module.exports =
  class Range
    inherits @, EventEmitter
    # Mixin.include @, Eventz

    defaults:
      text: null

    constructor: (@input, opts) ->
      @opts = extend {}, @defaults, opts
      @setVal @input.value
      @changeText @getVal()
      @events()

    changeText: (num) ->
      @opts.text.innerText = num
      return this

    setVal: (val) ->
      @_val = val
      return this

    getVal: -> @_val

    events: ->
      @input.addEventListener 'input', (ev) =>
        @changeText ev.target.value

      @input.addEventListener 'change', (ev) =>
        @setVal parseInt(ev.target.value, 10)
        @emit 'input:change', ev
        # @trigger 'input:change', ev
