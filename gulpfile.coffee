gulp        = require 'gulp'
gutil       = require 'gulp-util'
browserify  = require 'browserify'
reactify    = require 'reactify'
source      = require 'vinyl-source-stream'
buffer      = require 'vinyl-buffer'
uglify      = require 'gulp-uglify'
sourcemaps  = require 'gulp-sourcemaps'
watchify    = require 'watchify'
browserSync = require 'browser-sync'
del         = require 'del'
reload      = browserSync.reload

$ =
  app:  './app'
  dist: './dist'
  main: './app/main.js'
  html: './index.html'
  js:   './app/**/*.js'
  output:
    js:   './dist'
    main: './dist/main.js'

gulp.task 'clean', (cb) ->
  del [$.dist], cb

gulp.task 'browserify', ->
  browserify
    entries: [$.main]
    debug: true
  .transform reactify
  .bundle()
    .pipe source 'main.js'
    .pipe buffer()
    .pipe sourcemaps.init loadMaps: true
    .pipe uglify()
    .pipe sourcemaps.write './'
    .pipe gulp.dest $.dist
  .on 'error', ->
    gutil.log(arguments)

gulp.task 'watch', ->
  browserSync.init
    notify: false,
    server:
      baseDir: './'
  o = debounceDelay: 3000

  gulp.watch [$.js], o, [
    'clean'
    'browserify'
  ]

  gulp.watch [$.output.main, $.html], o, reload
