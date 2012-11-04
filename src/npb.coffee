[async, path, fs, beautifyjs, touch, hbs] = (
  require(v) for v in [
    'async', 'path', 'fs', 'beautifyjs', 'touch', 'handlebars'
  ]
)

module.exports = class NPB
  constructor: (@root = process.cwd(), @opts = {}, @callback = null) ->
    @bin = @opts.bin
    @basename = path.basename(@root)
    @projectTitle = @opts.projectTitle ? @basename
    @description = @opts.description ? 'A node module.'
    @version = @opts.version ? '0.0.1'
    @author = @opts.author
    @email = @opts.email
    @url = @opts.url
    @githubName = @opts.githubName
    @templates = {}
    fs.mkdir(@root, (err) =>
      @mkdir()
    )

    @GITIGNORE = ['lib-cov', '*.seed', '*.log', '*.csv', '*.dat', '*.out', '*.pid', '*.gz', '', 'pids', 'logs', 'results', '', 'node_modules', 'npm-debug.log']

    @MAKEFILE = [
      "test:",
      "\t./node_modules/.bin/mocha ./test/*.coffee --compilers coffee:coffee-script -R spec",
      ".PHONY: test"
    ]

    @PACKAGE_JSON = {
      "name" : @basename.toLowerCase(),
      "version" : @version,
      "description" : @description,
      "keywords" : [],
      "bugs" : {"url" : "https://github.com/#{@githubName}/#{@basename}/issues"},
      "main" : "./lib/#{@basename}",
      "directories" : {
        "lib" : "./lib",
        "doc" : "./docs"
      },
      "repository": {
        "type": "git",
        "url": "https://github.com/#{@githubName}/#{@basename}"
      },
      "dependencies" : {
      },
      "devDependencies" : {
        "coffee-script" : "",
        "mocha" : "",
        "chai" : ""
      }
    }

    if @opts.author? or @opts.emai? or @opts.url?
      @PACKAGE_JSON.author = {}
      if @opts.author?
        @PACKAGE_JSON.author.name = @opts.author
      if @opts.email?
        @PACKAGE_JSON.author.email = @opts.email
      if @opts.url?
        @PACKAGE_JSON.author.url = @opts.url

    if @bin
      @PACKAGE_JSON.bin = "./bin/#{@basename}"
      @PACKAGE_JSON.directories.bin = "./bin"
      @PACKAGE_JSON.dependencies.commander = "*"

    @BYSTANDER = {
      "ignore" : ["**/node_modules","**/.", "**/assets", "**/test/tmp"],   
      "plugins" : ["by-coffeescript", "by-write2js", "by-coffeelint", "by-docco", "by-mocha"],
      "by" : {
        "coffeescript" : {"noCompile" : ["**/test/*"]
        },
        "write2js" : {
          "bin" : true,
          "mapper" : {
            "**/src/*" : ["/src/", "/lib/"]
          }
        },
        "docco" : {
          "doccoSources" : ["src/*.coffee"]
        },
        "mocha" : {
          "testPaths" : ["test/*.coffee"]
        }
      }
    }

  mkdir : ->
    dirs = ['src', 'docs', 'test', 'lib']
    extra = ['bin','assets']
    for v in extra
      if @opts[v]?
        dirs.push(v)
    async.forEach(
      dirs,
      (v, callback) =>
        fs.mkdir(path.join(@root,v), (err) =>
          callback()
        )
        
      (cb) =>
        @getTemplates()
    )

  write : ->
    files = []
    files.push({body : @GITIGNORE.join('\n'), filename : '.gitignore'})
    files.push({body : @MAKEFILE.join('\n'), filename :'Makefile'})
    files.push({body : beautifyjs.js_beautify(JSON.stringify(@PACKAGE_JSON),{indent_size:2}), filename : 'package.json'})
    files.push({body : beautifyjs.js_beautify(JSON.stringify(@BYSTANDER),{indent_size:2}), filename : '.bystander'})
    files.push({body : @templates['LICENSE']({author:@author, email:@email, url:@url, projectTitle : @projectTitle}), filename : 'LICENSE'})
    bars = []
    for v in @projectTitle
      bars.push('=')
    files.push({body : @templates['README']({description:@description, projectTitle : @projectTitle, bars: bars.join('')}), filename : 'README.md'})

    async.forEach(
      files
      (v, callback) =>
        fs.writeFile(path.join(@root, v.filename), v.body, (err) =>
          callback()
        )
      =>
        @touchFiles()
    )

  getTemplates : ->
    files = ['LICENSE', 'README']
    async.forEach(
      files
      (v, callback) =>
        fs.readFile(path.join(__dirname, "../assets/#{v}.hbs"), 'utf8', (err,body) =>
          @templates[v] = hbs.compile(body)
          callback()
        )
      () =>
        @write()
    )

  touchFiles : ->
    files = [
      path.join(@root, "src/#{@basename}.coffee"),
      path.join(@root, "test/test.#{@basename}.coffee")
    ]
    if @bin
      files.push(path.join(@root, "bin/#{@basename}"))
    async.forEach(
      files
      (v, callback) =>
        touch(v, () =>
          callback()
        )
      () =>
        @chmod()
    )

  chmod : ->
    if @bin
      fs.chmod(path.join(@root, "bin/#{@basename}"), '755',()=>
        @exit()
      )
    else
      @exit()

  exit : ->
    if @callback?
      @callback()
    else
      process.exit()
