#
# Cakefile to build application
#
# author: Jan Gottschick
#

fs = require 'fs'
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
  buildPegJs 'src/**/*.pegjs'

task 'build:pegcoffee', 'compiling pegcoffee files', ->
  buildPegCoffee 'src/**/*.pegcoffee'

task 'test:jasmine', 'test spec files', ->
  sources = glob.sync 'spec/**/*Spec.+(js|coffee|litcoffee)'
  spawn 'jasmine-node', ['--autotest', '--noStack', '--coffee'].concat(sources), {stdio: "inherit"}

###########################################
#
# utilities
#

removeDir = (path) ->
  spawn 'rm', ['-rf', path], {stdio: "inherit"}
  console.log "Removed directory " + path + "/**/*"

copyToLib = (files) ->
  sources = glob.sync(files)
  for source in sources
    do (source) ->
      if not source.match(/^[\w\/]+Test.\w+$/)
        target = source.replace(/^src\//, 'lib/')
        copyFile source, target
        console.log "Copied " + source

copyFile = (source, target) ->
  targetDir = target.split('/')[...-1].join('/')
  mkdirp.sync targetDir
  fs.writeFileSync target, fs.readFileSync(source)

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

buildPegJs = (sources, dir = 'lib/', cb) ->
  for source in glob.sync(sources)
    do (source) ->
      target = source.replace(/src\//, dir).replace(/.pegjs$/, '.js')
      targetModule = source.replace(/src\//, dir).replace(/.pegjs$/, 'Module.js')
      targetDir = target.split('/')[...-1].join('/')
      targetVar = target.split('/')[-1...][0].replace(/.js$/, '')
      mkdirp.sync targetDir
      peg = spawn 'pegjs', ['--export-var', targetVar, source, target], { stdio: 'inherit' }
      peg.on "uncaughtException", (error) ->
        console.log target + ": " + error
      peg.on "close", (code) ->
        console.log "Compiled " + source + " to " + target
        peg = spawn 'pegjs', [source, targetModule], { stdio: 'inherit' }
        peg.on "uncaughtException", (error) ->
          console.log targetModule + ": " + error
        peg.on "close", (code) ->
          console.log "Compiled " + source + " to " + targetModule
          cb(target) if cb

buildPegCoffee = (sources, dir = 'lib/', cb) ->
  for source in glob.sync(sources)
    do (source) ->
      target = source.replace(/src\//, dir).replace(/.pegcoffee$/, '.js')
      targetModule = source.replace(/src\//, dir).replace(/.pegcoffee$/, 'Module.js')
      targetDir = target.split('/')[...-1].join('/')
      targetVar = target.split('/')[-1...][0].replace(/.js$/, '')
      mkdirp.sync targetDir
      peg = spawn 'pegjs', ['--export-var', targetVar, '--plugin', 'pegjs-coffee-plugin', source, target], { stdio: 'inherit' }
      peg.on "uncaughtException", (error) ->
        console.log error
      peg.on "close", (code) ->
        console.log "Compiled " + source + " to " + target
        peg = spawn 'pegjs', ['--plugin', 'pegjs-coffee-plugin', source, targetModule], { stdio: 'inherit' }
        peg.on "uncaughtException", (error) ->
          console.log error
        peg.on "close", (code) ->
          console.log "Compiled " + source + " to " + targetModule
          cb(target) if cb

buildCoffee = (sources, dir = 'lib/', cb) ->
  for source in glob.sync(sources)
    do (source) ->
      if not source.match(/^[\w\/]+Test.\w+$/)
        target = source.replace(/src\//, dir).replace(/.litcoffee$/, '.js').replace(/.coffee$/, '.js')
        targetDir = target.split('/')[...-1].join('/')
        mkdirp.sync targetDir
        coffee = spawn 'coffee', ['-c', '-o', targetDir, source], { stdio: 'inherit' }
        coffee.on "uncaughtException", (error) ->
          console.log error
        coffee.on "close", (code) ->
          console.log "Compiled " + source
          cb(target) if cb

buildJs = (source) ->
  copyToLib(source)

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
  invoke 'test:jasmine'
