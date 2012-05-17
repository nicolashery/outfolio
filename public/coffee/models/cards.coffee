define ['models/card'], (Card) ->

  class Cards extends Backbone.Collection

    model: Card

    url: '/api/cards'
