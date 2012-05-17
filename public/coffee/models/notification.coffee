define ->

  class Notification extends Backbone.Model

    # Message is what the user will see (can contain HTML)
    # Timeout in milliseconds is when the notification will disappear
    # Type of notification is a CSS class (without the '.')
    defaults:
      'message': 'Empty notification'
      'timeout': 2000
      'type': ''
