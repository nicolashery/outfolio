define ->

  class Card extends Backbone.Model

    # Using MongoDB
    idAttribute: '_id'

    urlRoot: '/api/cards'
    
    # Helpers to shorten the representation of this model
    # It might be best to put this in a view, but for now it's here

    # Length of short version of text attributes
    shortenLengths:
      'name': 30
      'address': 50
      'city': 30
      'notes': 140

    # Shorten an attribute (if necessary) to predeifined length
    shorten: (attr) ->
      shortenLength = @shortenLengths[attr]
      originalValue = @get(attr)
      # Make sure attribute exists and has a shorten length
      if shortenLength and originalValue
        # If needed, shorten and add '...'
        if shortenLength < originalValue.length
          originalValue.substr(0, shortenLength - 3) + '...'
        # If not, just return original value
        else
          originalValue
      else
        undefined
