define ['models/card'], (Card) ->

  # Same as Card
  class SharedCard extends Card

    # Just override the url
    url: ->
      "/api/shared/#{@get('owner')._id}/cards/#{@id}"