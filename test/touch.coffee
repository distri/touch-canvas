TouchCanvas = require "../touch_canvas"

extend = (target, sources...) ->
  for source in sources
    for name of source
      target[name] = source[name]

  return target

fireEvent = (element, type, params={}) ->
  event = document.createEvent("Events")
  event.initEvent type, true, false
  extend event, params
  element.dispatchEvent event

describe "TouchCanvas", ->
  it "should be creatable", ->
    c = TouchCanvas()
    assert c

    document.body.appendChild(c.element())

  it "should fire events", (done) ->
    canvas = TouchCanvas()

    canvas.on "touch", (e) ->
      done()

    fireEvent canvas.element(), "mousedown"
