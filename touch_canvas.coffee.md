Touch Canvas
============

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

A canvas element that reports mouse and touch events in the range [0, 1].

    Bindable = require "bindable"
    Core = require "core"
    PixieCanvas = require "pixie-canvas"

A number really close to 1. We should never actually return 1, but move events
may get a little fast and loose with exiting the canvas, so let's play it safe.

    MAX = 0.999999999999

    TouchCanvas = (I={}) ->
      self = PixieCanvas I

      Core(I, self)

      self.include Bindable

      element = self.element()

      # Keep track of if the mouse is active in the element
      active = false

When we click within the canvas set the value for the position we clicked at.

      listen element, "mousedown", (e) ->
        active = true

        self.trigger "touch", localPosition(e)

Handle touch starts

      listen element, "touchstart", (e) ->
        # Global `event`
        processTouches event, (touch) ->
          self.trigger "touch", localPosition(touch)

When the mouse moves apply a change for each x value in the intervening positions.

      listen element, "mousemove", (e) ->
        if active
          self.trigger "move", localPosition(e)

Handle moves outside of the element.

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
          x: clamp (e.pageX - rect.left) / rect.width, 0, MAX
          y: clamp (e.pageY - rect.top) / rect.height, 0, MAX

        # Add mouse into touch identifiers as 0
        point.identifier = (e.identifier + 1) or 0

        return point

Return self

      return self

Attach an event listener to an element

    listen = (element, event, handler) ->
      element.addEventListener(event, handler, false)

Clamp a number to be within a range.

    clamp = (number, min, max) ->
      Math.min(Math.max(number, min), max)

Export

    module.exports = TouchCanvas

Interactive Examples
--------------------

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
