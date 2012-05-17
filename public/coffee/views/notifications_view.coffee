define ['app'], (App) ->

  class NotificationsView extends Backbone.View

    id: 'js-notifications'

    template: jade.templates.notifications

    initialize: ->
      console.debug 'NotificationsView#initialize'
      # Grab notifications collection
      @collection = App.notifications

      # Bind collection events
      @collection.on 'add remove', @render

      # Bind AJAX events
      $('body').ajaxError @error

    render: =>
      console.debug 'NotificationsView#render'
      # Show latest notification only
      data = @collection.current()?.toJSON()
      @$el.html @template({notification: data})
      @

    # Function called when AJAX error occurs
    error: (e, xhr) =>
      # If this is a 'Not Found' error, redirect to index
      if xhr?.status == 404
        console.debug 'NotificationsView#error 404 Not Found'
        router.navigate '', trigger: true
      # All other errors, display error notification
      else
        console.debug 'NotificationsView#error'
        message = "<strong>Oops!</strong> An error occured. It's not your fault, it's ours. Please try refreshing the page. <a href='#{window.location}'>Refresh</a>"
        # Make error notification stay with no timeout
        @collection.new
          message: message
          timeout: false
          type: 'notification-error'
        @collection.error = true

