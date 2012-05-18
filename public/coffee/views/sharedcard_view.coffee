define ['app', 'models/sharedcard'], (App, SharedCard) ->

  class SharedCardView extends Backbone.View

    id: 'js-sharedcard'

    # Re-use the 'card' template
    template: jade.templates.card

    initialize: ->
      #console.debug 'SharedCardView#initialize'
      # Create model if doesn't exist already
      @model = App.sharedCard = App.sharedCard or new SharedCard()

      # Whenever the card changes, render
      @model.on 'change', @render 

      # Check if data is bootstrapped in DOM
      sharedCardJson = $('#sharedcard-json').remove().text()
      if sharedCardJson
        @model.set JSON.parse(sharedCardJson)

    render: =>
      #console.debug 'SharedCardView#render'
      @$el.html @template(@model.toJSON())
      @

    # Show a card by share id and card id
    index: (shareId, cardId) ->
      #console.debug 'SharedCardView#index', shareId, cardId 
      # Always check if card is in collection
      card = App.sharedCards?.get(cardId)
      if card
        # If card is in collection, check if we don't already have it as model
        unless card is @model
          # We don't have it as model, 
          # so set the model to existing card and render
          # We need to re-bind the change event 
          # since we are pointing to different object
          @model.off 'change', @render
          @model = App.sharedCard = card
          @model.on 'change', @render 
          @render()
        # If we do already have it as model, then no need to to anything
        # Tell other parts of the app that card is ready
        App.dispatcher.trigger 'shared:card:ready'
      else
        # Check if we don't already have the correct card as model
        unless cardId == @model.id
          # We don't have correct model already, fetch it from server
          # Prepare model with share id and card id
          # (pass silent to not trigger render)
          @model.set({id: cardId, owner: {_id: shareId}}, {silent: true})
          if App.demo.active
            loader = App.notifications.newLoader()
            @model.demo.fetch
              complete: ->
                App.notifications.remove loader
              success: ->
                App.dispatcher.trigger 'shared:card:ready'
          else
            loader = App.notifications.newLoader()
            @model.fetch
              complete: ->
                App.notifications.remove loader
              success: ->
                App.dispatcher.trigger 'shared:card:ready'
        # If we do already have correct model, then no need to do anything
        else
          App.dispatcher.trigger 'shared:card:ready'
      # Scroll to top of window
      $(window).scrollTop(0)
      @
        