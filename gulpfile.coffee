gulp = require 'gulp'
browserSync = require 'browser-sync'
sequence = require 'gulp-sequence'
requireDir = require 'require-dir'
$ = require('./package.json').projectConf

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

gulp.task 'start', sequence ['jade', 'stylus', 'browserify'], 'replace-normal', 'serve'

gulp.task 'default', ['start'], ->
  gulp.watch ["./#{$.SRC}/coffee/*.coffee"], ['browserify', reload]
  gulp.watch ["./#{$.SRC}/**/*.jade"], ['jade', reload]
  gulp.watch ["./#{$.SRC}/**/*.styl"], ['stylus', reload]

# After: git push -> 'npm run deploy'
gulp.task 'build', sequence ['jade', 'stylus', 'browserify'], ['header', 'replace-min'], 'uglify'
