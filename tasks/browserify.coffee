gulp = require 'gulp'
browserify = require 'browserify'
source = require 'vinyl-source-stream'
$ = require('../package.json').projectConf

gulp.task 'browserify', ->
  browserify
    entries: ["./#{$.SRC}/coffee/#{$.MAIN}.coffee"]
    extensions: ['.coffee', '.js']
  .transform 'coffeeify'
  .bundle()
  .pipe source "#{$.MAIN}.js"
  .pipe gulp.dest $.DEST
