define ['app', 'models/user', 'models/notifications'], (App, User, Notifications) ->

  # Class to help manage the current session:
  # current user, sign in, sign out, etc.
  class Session

    # Add event capabilities
    _(Session.prototype).defaults Backbone.Events

    # Indicates if we are currently authenticated
    authenticated: false

    constructor: (user) ->
      #console.debug 'Session#initialize'
      # Create session models
      App.user = new User()
      App.notifications = new Notifications()

    # If server has authenticated, load bootstrapped user in DOM
    load: ->
      #console.debug 'Session#load'
      # Grab user json data from DOM (and remove from DOM when done)
      userJson = $('#user-json').remove().text()
      if userJson
        # Handle demo
        if userJson == 'demo'
          App.demo.load()
          App.user.demo.load()
          @authenticated = true
        # Handle normal user authentication
        else
          App.user.set JSON.parse(userJson)
          @authenticated = true

