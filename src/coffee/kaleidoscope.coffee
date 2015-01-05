# $ = require 'jquery'
# _ = require 'underscore'

Mixin = require './../../coffee-mixin/dest/mixin'
Eventz = require './../../eventz/dest/eventz'

FileRead = require './fileread'

module.exports =
  class Kaleidoscope
    Mixin.include @, Eventz

