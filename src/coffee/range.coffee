"use strict"

EventEmitter = require('events').EventEmitter
objectAssign = require 'object-assign'

module.exports =
class Range extends EventEmitter

  defaults:
    text: null

  constructor: (@input, opts) ->
    EventEmitter.call @
    @opts = objectAssign {}, @defaults, opts
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
