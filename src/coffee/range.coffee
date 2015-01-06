_ = require 'underscore'

Mixin = require '../../coffee-mixin/dest/mixin'
Eventz = require '../../eventz/dest/eventz'

module.exports =
  class Range
    Mixin.include @, Eventz

    defaults:
      text: null

    constructor: (@input, opts) ->
      @opts = _.extend {}, @defaults, opts
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
        @trigger 'input:change', ev
