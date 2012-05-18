define ['app'], (App) ->

  # Region view for content
  # Has multiple sub-views, but only shows one at a time
  class ContentView extends Backbone.View

    id: 'js-content'

    # View that is currently shown
    currentView: null

    initialize: ->
      #console.debug 'ContentView#initialize'
      # Bind application events
      App.dispatcher.on 'content:refresh', @refresh

    # Show a view, closing the current one if any
    show: (view) ->
      # First check if we are not already showing the view
      unless view is @currentView
        # Close the current view
        @close()
        # Re-bind DOM events to view
        view.delegateEvents()
        # Show the new view's element and update current view
        #console.debug 'ContentView#show'
        @$el.html view.$el
        @currentView = view
      @

    # Close current view: remove from DOM and unbind DOM events
    close: ->
      # Don't try to close if no views 
      # (ex: there is no current view showing yet)
      if @currentView
        #console.debug 'ContentView#close'
        @currentView.undelegateEvents()
        @currentView.remove()
        @currentView = null
      @

    # Refresh current content with fresh data from server
    refresh: =>
      # Make sure there is an active content view 
      # with a refresh method
      if @currentView?.refresh
        @currentView.refresh()


