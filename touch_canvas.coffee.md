Touch Canvas
============

A canvas element that reports mouse and touch events in the range [0, 1].

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

      $(element).on "mousedown", (e) ->
        active = true

        self.trigger "touch", localPosition(e)

Handle touch starts

      $(element).on "touchstart", (e) ->
        # Global `event`
        processTouches event, (touch) ->
          self.trigger "touch", localPosition(touch)

When the mouse moves apply a change for each x value in the intervening positions.

      $(element).on "mousemove", (e) ->
        if active
          self.trigger "move", localPosition(e)

Handle moves outside of the element.

      $(document).on "mousemove", (e) ->
        if active
          self.trigger "move", localPosition(e)

Handle touch moves.

      $(element).on "touchmove", (e) ->
        # Global `event`
        processTouches event, (touch) ->
          self.trigger "move", localPosition(touch)

Handle releases.

      $(element).on "mouseup", (e) ->
        self.trigger "release", localPosition(e)
        active = false

        return

Handle touch ends.

      $(element).on "touchend", (e) ->
        # Global `event`
        processTouches event, (touch) ->
          self.trigger "release", localPosition(touch)

Whenever the mouse button is released from anywhere, deactivate. Be sure to
trigger the release event if the mousedown started within the element.

      $(document).on "mouseup", (e) ->
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
        $currentTarget = $(element)
        offset = $currentTarget.offset()

        width = $currentTarget.width()
        height = $currentTarget.height()

        point = Point(
          ((e.pageX - offset.left) / width).clamp(0, MAX)
          ((e.pageY - offset.top) / height).clamp(0, MAX)
        )

        # Add mouse into touch identifiers as 0
        point.identifier = (e.identifier + 1) or 0

        return point

Return self

      return self

Export

    module.exports = TouchCanvas
