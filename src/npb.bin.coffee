#!/usr/bin/env coffee
program = require('commander')
NPB = require('../lib/npb')

program
  .option('-b --bin', 'true if the project should contain a bin script')
  .option('--assets', 'true if the project should contain an "assets" directory')
  .option('-n --name <name>', 'the project name')
  .option('-d --desc <description>', 'the project description')
  .option('-a --author <name>', 'the name of the project author')
  .option('-e --email <email>', 'the email address of the project author')
  .option('-u --url <url>', 'the url of the project author')
  .option('-g --github <name>', 'your github username')
  .option('-c --config <path>', 'a path to a config file')

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
    description : program.desc,
    name : program.name,
    githubName : program.github,
    configFile : program.config
  }
)