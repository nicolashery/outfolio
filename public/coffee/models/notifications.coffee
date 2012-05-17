define ['models/notification'], (Notification) ->

  class Notifications extends Backbone.Collection

    model: Notification

    # Indicates that an error notification occured
    error: false

    # Function to add notifications,
    # we use this in place of the default 'Collection.add'
    new: (attributes) =>
      # Don't add any more notifications if an error occured
      if @error
        null
      else
        notification = new Notification(attributes)
        # Notifications stack on top of each other
        @add notification, at: 0
        timeout = notification.get('timeout')
        # If a timeout is set, schedule notification removal
        if timeout
          setTimeout =>
            @remove(notification)
          , timeout
        notification

    # Helper function to create a 'Loading' notification
    newLoader: =>
      @new
        message: 'Loading'
        timeout: false

    # Return latest notification
    current: =>
      @at 0

