define ['app'], (App) ->

  # Region view for content
  # Has multiple sub-views, but only shows one at a time
  class SubnavView extends Backbone.View

    id: 'js-subnav'

    # View that is currently shown
    currentView: null

    initialize: ->
      console.debug 'SubnavView#initialize'

    # Show a view, closing the current one if any
    show: (view) ->
      # First check if we are not already showing the view
      unless view is @currentView
        # Close the current view
        @close()
        # Re-bind DOM events to view
        view.delegateEvents()
        # Show the new view's element and update current view
        console.debug 'SubnavView#show'
        @$el.html view.$el
        @currentView = view
      @

    # Close current view: remove from DOM and unbind DOM events
    close: ->
      # Don't try to close if no views 
      # (ex: there is no current view showing yet)
      if @currentView
        console.debug 'SubnavView#close'
        @currentView.undelegateEvents()
        @currentView.remove()
        @currentView = null
      @