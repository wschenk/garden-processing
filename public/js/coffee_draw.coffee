class Canvas
  mouseX = 10
  constructor: (@id) ->
    @canvas_element = $("#" + @id )
    @canvas_element.width( $(window).width() )
    @canvas_element.height( $(window).height() )
    @c = @canvas_element[0].getContext '2d'
    @width = @c.width
    @height = @c.height
    window.c = @c
    @mouseX = 10
    @mouseY = 10
    @canvas_element.mousemove (e) =>
      @mouseX = e.pageX
      @mouseY = e.pageY
    @canvas_element.click (e) => @click()

  fullScreen: ->
    @set_dimensions( $(window).width(), $(window).height() )

  set_dimensions: (w,h) => 
    console.log( "Setting full screen" )
    @canvas_element[0].width = w
    @canvas_element[0].height = h
    @canvas_element.width( w ).height( h )
    @width = @c.canvas.width
    @height = @c.canvas.height

  center: ->
    new Vector( @width/2, @height/2 )

  clear: ->
    @c.clearRect( 0, 0, @width, @height )

  click: ->
  
  circle: (v,r) ->
    @c.beginPath()
    @c.arc v.x, v.yy, r, 0, Math.PI * 2
    # @c.closePath()
    @c.stroke()

  halfCircle: (v,r,angle) ->
    angle += Math.PI/2
    @c.beginPath()
    @c.arc v.x, v.y, r, angle, Math.PI + angle
    @c.closePath()
    @c.stroke()

  drawVector: (v1, v2) ->
    @c.beginPath()
    @c.moveTo( v1.x, v1.y )
    @c.lineTo( v2.x, v2.y )
    @c.stroke()

  drawChildVector: (v1, v2) ->
    @c.beginPath()
    @c.moveTo( v1.x, v1.y )
    @c.lineTo( v1.x + v2.x, v1.y + v2.y )
    @c.stroke()


class Vector
  constructor: (@x, @y) ->

  add: (v) ->
    @x += v.x
    @y += v.y

  @add: (v1, v2) ->
    new Vector( v1.x + v2.x, v1.y + v2.y )

  mult: (s) ->
    @x *= s
    @y *= s

  @mult: (v,s) ->
    new Vector( v.x*s, v.y*s )

  normalize: (scale=1)->
    mag = @mag()
    @x  = @x / mag * scale
    @y  = @y / mag * scale

  mag: ->
    Math.sqrt( @x*@x + @y*@y )

  limit: (size)->
    if @mag() > size
      @normalize( size )

  @random: (width, height) ->
    new Vector( Math.floor( Math.random() *  width ), Math.floor( Math.random() * height ) )

  @mouse: (canvas) ->
    new Vector( canvas.mouseX, canvas.mouseY )

  @sub: (v1, v2) ->
    new Vector( v1.x - v2.x, v1.y - v2.y )

  angle: ->
    Math.atan2( @y, @x )

  @angle: (v1, v2 ) ->
    a = @sub( v1, v2 )

    # angle = Math.acos( a.x / a.mag() )
    angle = Math.atan2( a.y, a.x )
    # log( a, angle * 180 / Math.PI )

    angle

class MouseWatcher
  constructor: (@canvas) ->
    @mouseVector = new Vector( 0, 0 )
    @center = @canvas.center()
    @canvas.canvas_element.mousemove (e) =>
      @mouseVector.x = e.pageX
      @mouseVector.y = e.pageY

  watch: =>
    @canvas.clear()

    @canvas.halfCircle @center, 20, Vector.angle( @center, @mouseVector )
    @canvas.drawVector @center, @mouseVector

    requestAnimationFrame @watch

class Mover
  @mass = 1

  constructor: (@canvas) ->
    @location = Vector.random( @canvas.width, @canvas.height )
    @velocity = new Vector(0,0)
    @acceleration = new Vector( .01, .1 )

  reset: ->
    @location = Vector.random( @canvas.width, @canvas.height )
    @velocity = Vector.random( 10, 10 )    
    @velocity.x -= 5
    @velocity.y -= 5
    @mass = Math.random() * 10 + 1
    @velocity

  adjust_acceleration: ->

  check_location: ->

  move: ->
    @adjust_acceleration()
    @velocity.add( Vector.mult( @acceleration, 1/@mass ) )
    @location.add( @velocity )
    @check_location()

  draw: ->
    @canvas.drawChildVector( @location, @velocity )
    # @canvas.drawChildVector( Vector.add( @location, @velocity ), @acceleration )
    @canvas.halfCircle( @location, 10, @velocity.angle() )

class Mover1 extends Mover
  @count = 0
  constructor: (@canvas) ->
    super( @canvas )
  
  adjust_acceleration: ->
    mouse = Vector.mouse( @canvas )
    # console.log( mouse )
    @acceleration = Vector.sub( mouse, @location )
    @acceleration.normalize( -1 ) if( @acceleration.mag() < 5 )
    @acceleration.normalize( .1 )
    @velocity.limit( 20 )
    @velocity.mult(.99)
    # console.log( @acceleration.x )
    # @acceleration.y = @canvas.noise( @count*100) - .5

  check_location: ->
    if( @location.x > @canvas.width )
      @location.x = 0

    if( @location.x < 0 )
      @location.x = @canvas.width

    if( @location.y > @canvas.height )
      @location.y = 0

    if( location.y < 0 )
      @location.y = @canvas.height

class Simulation
  constructor: (@canvas, @ticksize=6) ->
    @actors = (new Mover1( @canvas ) for [0..10] )
    @canvas.click = =>
      actor.reset() for actor in @actors

  start: ->
    @lastrender = new Date() / @ticksize
    @run()

  run: =>
    @render = new Date() / @ticksize

    dif = Math.floor( @render - @lastrender )

    if dif > 0

      while dif > 0
        actor.move() for actor in @actors
        dif -= 1

      @lastrender = @render

      @canvas.clear()

      actor.draw() for actor in @actors

    requestAnimationFrame @run

$(document).ready ->
  canvas = new Canvas 'processing'
  window.canvas = canvas

  canvas.fullScreen()

  window.sim = new Simulation( canvas )
  window.sim.start()

  # v = new Vector( 50, 50 )
  # canvas.circle( v, 20 )

  # v1 = Vector.random( canvas.width, canvas.height )
  # v2 = Vector.random( canvas.width, canvas.height )
  # v2.limit( 10 )

  # canvas.drawChildVector( v1, v2 )
  # canvas.halfCircle( v1, 20, Vector.angle( v1, v2 ) )

  # console.log v1
  # console.log v2
  # console.log Vector.angle( v1, v2 ) * 180 / Math.PI

  # window.watcher = new MouseWatcher( canvas )
  # watcher.watch()


