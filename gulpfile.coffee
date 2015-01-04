gulp = require 'gulp'
browserSync = require 'browser-sync'
sequence = require 'gulp-sequence'
replace = require 'gulp-replace'
requireDir = require 'require-dir'
$ = require './config.json'

requireDir './tasks'

reload = browserSync.reload



gulp.task 'serve', ->
  browserSync
    startPath: '/'
    server:
      baseDir: './'
      index: "#{$.DEST}/"
      routes:
        '/': "#{$.DEST}/"

gulp.task 'replace-min', ->
  gulp.src "./#{$.DEST}/index.html"
    .pipe replace("#{$.MAIN}.js", "#{$.MAIN}.min.js")
    .pipe gulp.dest $.DEST

gulp.task 'replace-normal', ->
  gulp.src "./#{$.DEST}/index.html"
    .pipe replace("#{$.MAIN}.min.js", "#{$.MAIN}.js")
    .pipe gulp.dest $.DEST

gulp.task 'default', ['serve'], ->
  gulp.watch ["./#{$.SRC}/coffee/*.coffee"], ['browserify', reload]
  gulp.watch ["./#{$.SRC}/**/*.jade"], ['jade', reload]
  gulp.watch ["./#{$.SRC}/**/*.styl"], ['stylus', reload]


# After -> 'gh-pages', 'replace-normal'
gulp.task 'build', sequence ['jade', 'stylus'], 'browserify', 'header', 'uglify', 'replace-min'
