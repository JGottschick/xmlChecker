#
# Cakefile to build application
#
# author: Jan Gottschick
#

spawn = require('child_process').spawn
gaze = require 'gaze'
glob = require 'glob'
mkdirp = require 'mkdirp'
path = require 'path'

###########################################
#
# basic tasks
#

task 'build:coffee', 'compiling coffeescript files', ->
  buildCoffee 'src/**/*.+(coffee|litcoffee)'

task 'build:js', 'copying javascript files', ->
  copyToLib 'src/**/*.+(js|map)', 'javascript'

task 'build:pegjs', 'compiling pegjs files', ->
  buildPegCoffee 'src/**/*.pegjs'

task 'build:pegcoffee', 'compiling pegcoffee files', ->
  buildPegCoffee 'src/**/*.pegcoffee'

###########################################
#
# utilities
#

removeDir = (path) ->
  spawn 'rm', ['-rf', path], {stdio: "inherit"}
  console.log "Removed directory " + path + "/**/*"

copyToLib = (files, name) ->
  sources = glob.sync(files)
  for source in sources
    do (source) ->
      if not source.match(/^[\w\/]+Test.\w+$/)
        target = source.replace(/^src\//, 'lib/')
        copyFile source, target
        console.log "Copied " + name + " " + source

###########################################
#
# watcher utilities
#

watcher = (files, f) ->
  console.log 'Watching ' + files
  gaze files, (err, watcher) ->
    @on 'changed', (filepath) ->
        f path.relative(process.cwd(), filepath)
    @on 'added', (filepath) ->
        f path.relative(process.cwd(), filepath)

buildPegJs = (sources, cb) ->
  for source in glob.sync(sources)
    do (source) ->
      target = source.replace(/src\//, 'lib/').replace(/.pegjs$/, '.js')
      targetModule = source.replace(/src\//, 'lib/').replace(/.pegjs$/, 'Module.js')
      targetDir = target.split('/')[...-1].join('/')
      targetVar = target.split('/')[-1].replace(/.pegjs$/, '')
      mkdirp.sync targetDir
      peg = spawn 'pegjs', ['-e', targetVar, source, target], { stdio: 'inherit' }
      peg.on "uncaughtException", (error) ->
        console.log error
      peg.on "close", (code) ->
        peg = spawn 'pegjs', [source, targetModule], { stdio: 'inherit' }
        peg.on "uncaughtException", (error) ->
          console.log error
        peg.on "close", (code) ->
          console.log "Compiled " + source
          cb(target) if cb

buildPegCoffee = (sources, cb) ->
  for source in glob.sync(sources)
    do (source) ->
      target = source.replace(/src\//, 'lib/').replace(/.pegcoffee$/, '.js')
      targetModule = source.replace(/src\//, 'lib/').replace(/.pegcoffee$/, 'Module.js')
      targetDir = target.split('/')[...-1].join('/')
      targetVar = target.split('/')[-1].replace(/.pegcoffee$/, '')
      mkdirp.sync targetDir
      peg = spawn 'pegjs', ['-e', targetVar, '--plugin', 'pegjs-coffee-plugin', source, target], { stdio: 'inherit' }
      peg.on "uncaughtException", (error) ->
        console.log error
      peg.on "close", (code) ->
        peg = spawn 'pegjs', ['--plugin', 'pegjs-coffee-plugin', source, targetModule], { stdio: 'inherit' }
        peg.on "uncaughtException", (error) ->
          console.log error
        peg.on "close", (code) ->
          console.log "Compiled " + source
          cb(target) if cb

buildCoffee = (sources, cb) ->
  for source in glob.sync(sources)
    do (source) ->
      if not source.match(/^[\w\/]+Test.\w+$/)
        target = source.replace(/src\//, 'lib/').replace(/.litcoffee$/, '.js').replace(/.coffee$/, '.js')
        targetDir = target.split('/')[...-1].join('/')
        mkdirp.sync targetDir
        coffee = spawn 'coffee', ['-c', '-o', targetDir, source], { stdio: 'inherit' }
        coffee.on "uncaughtException", (error) ->
          console.log error
        coffee.on "close", (code) ->
          console.log "Compiled " + source
          cb(target) if cb

###########################################
#
# The available main tasks to run
#

task 'clean', 'use this to remove all files from lib', ->
  removeDir('lib')

task 'build', 'use this to build the application from ground up', ->
  invoke 'build:pegcoffee'
  invoke 'build:pegjs'
  invoke 'build:coffee'
  invoke 'build:js'

task 'watch', 'use this to watch changes an update the application', ->
  watcher 'src/**/*.pegcoffee', buildPegCoffee
  watcher 'src/**/*.pegjs', buildPegJs
  watcher 'src/**/*.+(coffee|litcoffee)', buildCoffee
  watcher 'src/**/*.+(js|map)', buildJs

task 'test', 'use this to execute all tests for the application', ->
