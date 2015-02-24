gulp        = require 'gulp'
gutil       = require 'gulp-util'
uglify      = require 'gulp-uglify'
sourcemaps  = require 'gulp-sourcemaps'
notify      = require 'gulp-notify'
browserify  = require 'browserify'
babelify    = require 'babelify'
source      = require 'vinyl-source-stream'
buffer      = require 'vinyl-buffer'
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
  .transform babelify
  .require $.main, entry: true
  .bundle()
  .on 'error', (err) ->
    # see http://qiita.com/tanshio/items/b546b4b3eb2c648cb340
    args = Array.prototype.slice.call arguments
    notify
      .onError
        title: 'Browsefify Error'
        message: '<%= error %>'
      .apply this, args
    this.emit 'end'
  .pipe source 'main.js'
  .pipe buffer()
  .pipe sourcemaps.init loadMaps: true
  .pipe uglify()
  .pipe sourcemaps.write './'
  .pipe gulp.dest $.dist

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

gulp.task 'server', [
  'clean'
  'browserify'
  'watch'
]
