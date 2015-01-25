extend = require 'node.extend'
inherits = require 'inherits'
EventEmitter2 = require('eventemitter2').EventEmitter2

module.exports =
  class Range
    "use strict"

    inherits @, EventEmitter2

    defaults:
      text: null

    constructor: (@input, opts) ->
      EventEmitter2.call @
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
