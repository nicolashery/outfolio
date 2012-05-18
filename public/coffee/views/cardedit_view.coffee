define ['app', 'models/card'], (App, Card) ->

  class CardEditView extends Backbone.View

    id: 'js-cardedit'

    template: jade.templates.cardedit

    events:
      'click .js-save': 'save'
      'click .js-cancel': 'cancel'

    initialize: (id) ->
      #console.debug 'CardEditView#initialize'
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
      #console.debug 'CardEditView#render'
      @$el.html @template(@model.toJSON())
      @

    # Show a card edit form by id
    index: (id) ->
      #console.debug 'CardEditView#index', id
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
        App.dispatcher.trigger 'card:edit:ready'
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
                App.dispatcher.trigger 'card:edit:ready'
          else
            loader = App.notifications.newLoader()
            @model.fetch
              complete: ->
                App.notifications.remove loader
              success: ->
                App.dispatcher.trigger 'card:edit:ready'
        # If we do already have correct model, then no need to do anything
        else
          App.dispatcher.trigger 'card:edit:ready'
      # Scroll to top of window
      $(window).scrollTop(0)
      @

    # Save changes and navigate back to card view
    save: (e) =>
      #console.debug 'CardEditView#save'
      e.preventDefault()
      # Set model attributes with new values and save to server
      if App.demo.active
        @model.set
          name: @$("input[name='name']").val()
          address: @$("input[name='address']").val()
          city: @$("input[name='city']").val()
          notes: @$("textarea[name='notes']").val()
      else
        # Card views will render twice, first as soon as attributes
        # are changed client-side, and second, once server responds
        # since it will change the 'modified_on' attribute
        @model.save
          name: @$("input[name='name']").val()
          address: @$("input[name='address']").val()
          city: @$("input[name='city']").val()
          notes: @$("textarea[name='notes']").val()
      # Navigate back to card view
      App.router.navigate "card/#{@model.id}", trigger: true
     
    # Discard changes and navigate back to card view
    cancel: (e) =>
      #console.debug 'CardEditView#cancel'
      e.preventDefault()
      # Re-render the view to reset inputs to original values
      @render()
      # Navigate back to card view
      App.router.navigate "card/#{@model.id}", trigger: true
        