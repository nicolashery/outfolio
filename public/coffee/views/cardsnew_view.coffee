define ['app', 'models/cards'], (App, Cards) ->

  class CardsNewView extends Backbone.View

    id: 'js-cardsnew'

    template: jade.templates.cardsnew

    events:
      'click .js-add': 'add'
      'click .js-cancel': 'cancel'

    initialize: ->
      #console.debug 'CardsNewView#initialize'

      # Only load cards data from DOM (if exists),
      # we will fetch from server (if needed), at card creation
      cardsJson = $('#cards-json').remove().text()
      # If data is present in DOM
      if cardsJson
        # Create new cards collection and load data
        App.cards = App.cards or new Cards()
        App.cards.reset JSON.parse(cardsJson)

      # No data to fetch, so render immediately
      @render()

    render: ->
      #console.debug 'CardsNewView#render'
      @$el.html @template()
      @

    # Helper method to clear the form
    clearForm: ->
      @$el.find("input[name='name']").val("")
      @$el.find("input[name='address']").val("")
      @$el.find("input[name='city']").val("")
      @$el.find("textarea[name='notes']").val("")

    # Add new card to collection and navigate to card list
    add: (e) =>
      #console.debug 'CardsNewView#add'
      # Stop form from posting data to server
      e.preventDefault()
      # Grab data from form
      card =
        name: @$el.find("input[name='name']").val()
        address: @$el.find("input[name='address']").val()
        city: @$el.find("input[name='city']").val()
        notes: @$el.find("textarea[name='notes']").val()
      # Empty form
      @clearForm()
      # We want to add new card after having fetched collection data 
      # from server, or else we won't know if card is saved to server
      # before or after collection is fetched (paths might cross)
      isNew = (not App.cards) or (App.cards.demo? and not App.cards.demo.fetched)
      unless isNew
        # Collection has already been loaded, go ahead and add new card
        if App.demo.active
          App.cards.demo.create card, at: 0
        else
          App.cards.create card, at: 0
      else
        # Create and load collection first, 
        # and once successfull add new card
        App.cards = App.cards or new Cards()
        if App.demo.active
          loader = App.notifications.newLoader()
          App.cards.demo.fetch
            success: ->
              if App.demo.active
                App.cards.demo.create card, at: 0
            complete: ->
              App.notifications.remove loader
        else
          loader = App.notifications.newLoader()
          App.cards.fetch
            success: ->
              App.cards.create card, at: 0
            complete: ->
              App.notifications.remove loader
      # Finally, navigate to card list
      App.router.navigate 'cards', trigger: true
      # Scroll back to top of window
      $(window).scrollTop(0)

    # Clear form and navigate to card list
    cancel: (e) =>
      #console.debug 'CardsNewView#cancel'
      # Stop form from doing anything
      e.preventDefault()
      @clearForm()
      App.router.navigate 'cards', trigger: true
      # Scroll back to top of window
      $(window).scrollTop(0)

