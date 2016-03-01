Touch Canvas
============

A canvas you can TOUCH!

Demo
----

>     #! demo
>     paint = (position) ->
>       x = position.x * canvas.width()
>       y = position.y * canvas.height()
>
>       canvas.drawCircle
>         radius: 10
>         color: "red"
>         position:
>           x: x
>           y: y
>
>     canvas.on "touch", (p) ->
>       paint(p)
>
>     canvas.on "move", (p) ->
>       paint(p)

----

Implementation
--------------

A canvas element that reports mouse and touch events. The events
are scaled to the size of the canvas with [0, 0] being in the top
left and a number close to 1 being in the bottom right.

We track movement outside of the element so the positions are not
clamped and return their true value if the canvas were to extend.
This means that it is possible to receive negative numbers and
numbers >= 1 for positions.

    Bindable = require "bindable"
    Core = require "core"
    PixieCanvas = require "pixie-canvas"

    TouchCanvas = (I={}) ->
      self = PixieCanvas I

      Core(I, self)

      self.include Bindable

      element = self.element()

      # Keep track of if the mouse is active in the element
      active = false

When we click within the canvas set the value for the position we clicked at.

      listen element, "mousedown", (e) ->
        e.preventDefault()
        active = true

        self.trigger "touch", localPosition(e)

Handle touch starts

      listen element, "touchstart", (e) ->
        # Global `event`
        processTouches event, (touch) ->
          self.trigger "touch", localPosition(touch)

When the mouse moves trigger an event with the current position.

      listen element, "mousemove", (e) ->
        e.preventDefault()
        if active
          self.trigger "move", localPosition(e)

Handle moves outside of the element if the action was initiated within the element.

      listen document, "mousemove", (e) ->
        if active
          self.trigger "move", localPosition(e)

Handle touch moves.

      listen element, "touchmove", (e) ->
        # Global `event`
        processTouches event, (touch) ->
          self.trigger "move", localPosition(touch)

Handle releases.

      listen element, "mouseup", (e) ->
        self.trigger "release", localPosition(e)
        active = false

        return

Handle touch ends.

      listen element, "touchend", (e) ->
        # Global `event`
        processTouches event, (touch) ->
          self.trigger "release", localPosition(touch)

Whenever the mouse button is released from anywhere, deactivate. Be sure to
trigger the release event if the mousedown started within the element.

      listen document, "mouseup", (e) ->
        if active
          self.trigger "release", localPosition(e)

        active = false

        return

Helpers
-------

Process touches

      processTouches = (event, fn) ->
        event.preventDefault()

        if event.type is "touchend"
          # touchend doesn't have any touches, but does have changed touches
          touches = event.changedTouches
        else
          touches = event.touches

        self.debug? Array::map.call touches, ({identifier, pageX, pageY}) ->
          "[#{identifier}: #{pageX}, #{pageY} (#{event.type})]\n"

        Array::forEach.call touches, fn

Local event position.

      localPosition = (e) ->
        rect = element.getBoundingClientRect()

        point =
          x: (e.pageX - rect.left) / rect.width
          y: (e.pageY - rect.top) / rect.height

        # Add mouse into touch identifiers as 0
        point.identifier = (e.identifier + 1) or 0

        return point

Return self

      return self

Attach an event listener to an element

    listen = (element, event, handler) ->
      element.addEventListener(event, handler, false)

Export

    module.exports = TouchCanvas

Interactive Examples
--------------------

This is what is used to set up the demo at the beginning of this document.

>     #! setup
>     TouchCanvas = require "/touch_canvas"
>
>     Interactive.register "demo", ({source, runtimeElement}) ->
>       canvas = TouchCanvas
>         width: 400
>         height: 200
>
>       code = CoffeeScript.compile(source)
>
>       runtimeElement.empty().append canvas.element()
>       Function("canvas", code)(canvas)
