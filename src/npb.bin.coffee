#!/usr/bin/env coffee
program = require('commander')
NPB = require('../lib/npb')

program
  .option('-b --bin', 'true if the project should contain a bin script')
  .option('--assets', 'true if the project should contain an "assets" directory')
  .option('-n --name', 'the project name')
  .option('-d --description', 'the project description')
  .option('-a --author', 'the name of the project author')
  .option('-e --email', 'the email address of the project author')
  .option('-u --url', 'the url of the project author')
  .option('-g --github', 'your github username')

program
  .parse(process.argv)

root = program.args[0] ? './'

new NPB(
  root,
  {
    bin : program.bin,
    assets : program.assets,
    author : program.author,
    email : program.email,
    url : program.url,
    description : program.description,
    name : program.name,
    githubName : program.github
  }
)