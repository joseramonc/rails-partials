S = require 'string'
path = require 'path'

module.exports =
class PromptHelper
  RAILS_VIEWS_PATH = 'app/views'

  constructor: () ->

  # returns the paramters to insert into partial
  # input: "layouts/navbar f user:@user"
  # output: "f:f user:@user"
  @extractParameters: (input) ->
    input = S(input).chompRight(' ').chompLeft(' ').s
    spaceIndex = S(input).indexOf(' ')
    if spaceIndex < 0
      null
    else
      paramInput = input.substr(spaceIndex, input.length) # returns the parameter part of the input
      paramInput = S(paramInput).chompLeft(' ').s # remove the first space of the params
      params = S(paramInput).parseCSV(' ', null)
      paramString = ''
      for param in params
        if S(param).contains(':')
          paramKeyValue = param
        else
          paramKeyValue = "#{param}:#{param}"
        paramString = "#{paramString} #{paramKeyValue}"
        console.log paramString
      return S(paramString).chompLeft(' ').s

  # returns only the file name or the file name
  # input: "/layouts/navbar f user:@user"
  # output: "layouts/navbar"
  @extractNamePath: (input) ->
    input = S(input).chompLeft('/').s
    if S(input).contains(' ')
      spaceIndex = S(input).indexOf(' ')
      S(input).substr(0, spaceIndex).s
    else
      input

  # validate if input is a directory
  @isDirectory: (input) ->
    if input.slice(-1) == '/'
      true
    else
      false

  # returns the full path of the new partial
  @partialFullPath: (input) ->
    directory = @fileDirectory(input)
    fileName = @fileName(input)
    partialName = @partialName(fileName)
    return "#{directory}/#{partialName}"

  @fileDirectory: (input) ->
    if S(input).contains('/')
      # when input is a path we generate the file in
      # the RAILS_VIEWS_PATH direcotry + input
      inputPath = S(input).chompLeft('/').s # remove prefix '/'
      projectPath = atom.project.getPaths(atom.workspace.getActiveTextEditor())[0]
      path.dirname(path.resolve(projectPath, RAILS_VIEWS_PATH, inputPath))
    else
      # generate file on the same directory
      path.dirname(atom.workspace.getActiveTextEditor().getPath())

  # returns only the name
  @fileName: (input) ->
    inputArray = S(input).parseCSV('/', null) # split because input might be a path
    fileName = inputArray.pop() # the last element is the file name

  @partialName: (fileNameWithoutExtensions) ->
    if @editorExtension() in ['.scss', '.sass']
      "_#{fileNameWithoutExtensions}#{@editorExtension()}"
    else
      "_#{fileNameWithoutExtensions}.html#{@editorExtension()}"

  @editorExtension: ->
    fileName = atom.workspace.getActiveTextEditor().getTitle()
    path.extname fileName
