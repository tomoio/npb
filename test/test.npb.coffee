NPB = require('../src/npb')
chai = require('chai')
should = chai.should()
path = require('path')
rimraf = require('rimraf')
fs = require('fs')
async = require('async')
describe('NPB', ->
  PROJECT = "#{__dirname}/testProject"
  afterEach((done)->
    rimraf(PROJECT,->
      done()
    )
  )
  it('should create a project', (done) ->
    new NPB(
      PROJECT,
      {
        bin:true,
        assets:true,
        author:'Tomo I/O',
        email:'711@tomo.io',
        url:'http://tomo.io/',
        description: 'A boilerplate to build a node package upon.',
        projectTitle:'Node Package Boilerplate'
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
