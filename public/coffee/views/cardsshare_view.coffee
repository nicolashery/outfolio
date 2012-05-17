define ['app'], (App) ->

  class CardsShareView extends Backbone.View

    id: 'js-cardsshare'

    template: jade.templates.cardsshare

    initialize: ->
      console.debug 'CardsShareView#initialize'
      # Don't render on initialization, router re-renders this view everytime

    render: ->
      console.debug 'CardsShareView#render'
      # Build the share link to the user's cards, from current user model
      link = window.location.origin + '/shared/' + App.user.id
      @$el.html @template({link: link})
      @
