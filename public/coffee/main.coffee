require.config
  baseUrl: '/js/'

# This is the main entry point: 
# we create the application components, 
# then start the app
require ['app', 'router', 'session', 'dispatcher', 'demo', 'views/application_view'], (App, Router, Session, Dispatcher, Demo, ApplicationView) ->
  
  # Create application components
  App.router = new Router()
  App.session = new Session()
  App.dispatcher = new Dispatcher()
  App.demo = new Demo()

  # Load session and add views when DOM is ready
  $ =>
    App.session.load()
    App.applicationView = new ApplicationView()
    $('body').prepend App.applicationView.$el

  # Start routing
  Backbone.history.start({pushState: true})

  # Attach the app to the window for debugging
  window.App = App
