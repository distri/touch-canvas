TouchCanvas = require "../touch_canvas"

describe "TouchCanvas", ->
  it "should be creatable", ->
    c = TouchCanvas()
    assert c

    document.body.appendChild(c.element())

  it "should fire events", (done) ->
    canvas = TouchCanvas()

    canvas.on "touch", (e) ->
      done()

    e = new Event("mousedown")
    canvas.element().dispatchEvent e
