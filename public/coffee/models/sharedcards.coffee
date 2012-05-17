define ['models/sharedcard', 'models/cards'], (SharedCard, Cards) ->

  # Same as Cards
  class SharedCards extends Cards

    # Just change the model
    model: SharedCard

    # Add a property
    shareId: null

    # And override the url
    url: ->
      "/api/shared/#{@shareId}/cards"
