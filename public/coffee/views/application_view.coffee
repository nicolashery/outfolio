define ['app', 'views/navigation_view', 'views/notifications_view', 'views/subnav_view', 'views/content_view'], (App, NavigationView, NotificationsView, SubnavView, ContentView) ->

  # Main view for the application
  # Holds sub-views for different regions of the app
  # Responds to application-wide events such as login, logout
  class ApplicationView extends Backbone.View

    id: 'js-application'

    initialize: ->
      #console.debug 'ApplicationView#initialize'

      # Construct sub-views
      App.navigationView = new NavigationView()
      App.notificationsView = new NotificationsView()
      App.subnavView = new SubnavView()
      App.contentView = new ContentView()

      # Add sub-view elements to this one
      @$el.append App.navigationView.$el
      @$el.append App.notificationsView.$el
      @$el.append App.subnavView.$el
      @$el.append App.contentView.$el
