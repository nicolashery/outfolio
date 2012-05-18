define ['app', 'models/card'], (App, Card) ->

  class CardShareView extends Backbone.View

    id: 'js-cardshare'

    template: jade.templates.cardshare

    initialize: (id) ->
      #console.debug 'CardShareView#initialize'
      # Create model if doesn't exist already
      @model = App.card = App.card or new Card()

      # Whenever the card changes, re-render
      @model.on 'change', @render 

      # If we already have correct model, render
      if id == @model.id
        @render()
      # If not, check if data is bootstrapped in DOM
      else
        cardJson = $('#card-json').remove().text()
        if cardJson
          card = JSON.parse(cardJson)
          # Make sure we have the right card
          if card.owner._id == App.user.id and card._id == id
            # Load the card in the model
            @model.set card

    render: =>
      #console.debug 'CardShareView#render'
      # Build share link for this card
      link = window.location.origin + '/shared/' + @model.get('owner')._id
      link += '/card/' + @model.id
      @$el.html @template({name: @model.get('name'), link: link})
      @

    # Show card share link by id
    index: (id) ->
      #console.debug 'CardShareView#index', id
      # Always check if card is in collection
      card = App.cards?.get(id)
      if card
        # If card is in collection, check if we don't already have it as model
        unless card is @model
          # We don't have it as model, 
          # so set the model to existing card and render
          # We need to re-bind the change event 
          # since we are pointing to different object
          @model.off 'change', @render
          @model = App.card = card
          @model.on 'change', @render 
          @render()
        # If we do already have it as model, then no need to to anything
        # Tell other parts of the app that card is ready
        App.dispatcher.trigger 'card:share:ready'
      else
        # Card was not in collection, 
        # but maybe we already have model set from the edit view
        unless id == @model.id
          # We don't have correct model set already, 
          # fetch a fresh one from server using the id
          # Pass silent when setting id as to not fire the render function
          @model.set({_id: id}, {silent: true})
          if App.demo.active
            loader = App.notifications.newLoader()
            @model.demo.fetch
              complete: ->
                App.notifications.remove loader
              success: ->
                App.dispatcher.trigger 'card:share:ready'
          else
            loader = App.notifications.newLoader()
            @model.fetch
              complete: ->
                App.notifications.remove loader
              success: ->
                App.dispatcher.trigger 'card:share:ready'
        # If we do already have correct model, then no need to do anything
        else
          App.dispatcher.trigger 'card:share:ready'
      # Scroll to top of window
      $(window).scrollTop(0)
      @
