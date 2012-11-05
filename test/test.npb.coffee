NPB = require('../src/npb')
chai = require('chai')
should = chai.should()
path = require('path')
rimraf = require('rimraf')
fs = require('fs')
async = require('async')
describe('NPB', ->
  PROJECT = "#{__dirname}/testProject"
  CONFIG_FILE = "#{__dirname}/.npb"
  CONFIG = {
    bin:true,
    assets:true,
    author:'Tomo I/O',
    email:'711@tomo.io',
    url:'http://tomo.io/',
    description: 'A boilerplate to build a node package upon.',
    projectTitle:'Node Package Boilerplate'
  }
  beforeEach((done)->
    fs.writeFile(CONFIG_FILE, JSON.stringify(CONFIG), (err) ->
      done()
    )  
  )
  afterEach((done)->
    rimraf(PROJECT,->
      rimraf(CONFIG_FILE,->
        done()
      )
    )
  )
  it('should create a project', (done) ->
    new NPB(
      PROJECT,
      CONFIG,
      ->
        async.forEach(
          [
            'bin',
            'src',
            'assets',
            'test',
            'docs',
            'README.md',
            '.gitignore',
            '.bystander',
            'bin/testProject'
          ],
          (v, callback) ->
            fs.exists(path.join(PROJECT,v),(exist)->
              exist.should.be.ok
              callback()
            )
          () ->
            done()
        )
    )
  )
  it('should use a config file', (done) ->
    new NPB(
      PROJECT,
      {
        configFile: CONFIG_FILE
      },
      ->
        async.forEach(
          [
            'bin',
            'src',
            'assets',
            'test',
            'docs',
            'README.md',
            '.gitignore',
            '.bystander',
            'bin/testProject'
          ],
          (v, callback) ->
            fs.exists(path.join(PROJECT,v),(exist)->
              exist.should.be.ok
              callback()
            )
          () ->
            done()
        )
    )
  )
)
