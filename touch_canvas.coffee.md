Touch Canvas
============

A canvas element that reports mouse and touch events in the range [0, 1].

TODO: Add multi-touch event support.

    PixieCanvas = require "pixie-canvas"

A number really close to 1. We should never actually return 1, but move events
may get a little fast and loose with exiting the canvas, so let's play it safe.

    MAX = 0.999999999999

    TouchCanvas = (I={}) ->
      self = PixieCanvas I

      Core(I, self)

      self.include Bindable

      element = self.element()

      active = false
      lastPosition = null

When we click within the canvas set the value for the position we clicked at.

      $(element).on "mousedown", (e) ->
        active = true

        position = localPosition(e)
        self.trigger "touch", position
        lastPosition = position

Handle touch starts

      $(element).on "touchstart", (e) ->
        # Global `event`
        processTouches event.changedTouches, (touch) ->
          self.trigger "touch", localPosition(touch)

When the mouse moves apply a change for each x value in the intervening positions.

      $(element).on "mousemove", (e) ->
        if active
          position = localPosition(e)
          self.trigger "move", position, lastPosition
          lastPosition = position

Handle moves outside of the element.

      $(document).on "mousemove", (e) ->
        if active
          position = localPosition(e)
          self.trigger "move", position, lastPosition
          lastPosition = position

Handle touch moves.

      $(element).on "touchmove", (e) ->
        # Global `event`
        # TODO: Previous touch positions
        processTouches event.changedTouches, (touch) ->
          position = localPosition(touch)
          self.trigger "move", position, position

Handle releases.

      $(element).on "mouseup", (e) ->
        self.trigger "release", localPosition(e)
        active = false

        return

Handle touch ends.

      $(element).on "touchend", (e) ->
        # Global `event`
        processTouches event.changedTouches, (touch) ->
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

      processTouches = (touches, fn) ->
        self.debug? Array::map.call touches, ({identifier, pageX, pageY}) ->
          "[#{identifier}: #{pageX}, #{pageY}]\n"

        Array::forEach.call touches, fn

Local event position.

      localPosition = (e) ->
        $currentTarget = $(element)
        offset = $currentTarget.offset()
  
        width = $currentTarget.width()
        height = $currentTarget.height()

        Point(
          ((e.pageX - offset.left) / width).clamp(0, MAX)
          ((e.pageY - offset.top) / height).clamp(0, MAX)
        )

Return self

      return self

Export

    module.exports = TouchCanvas
