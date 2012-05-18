define ->

  # The Dispatcher is used to coordinate events 
  # between different areas of the application
  class Dispatcher

    _(Dispatcher.prototype).defaults Backbone.Events

    constructor: ->
      #console.debug 'Dispatcher#initialize'
