define ['app', 'models/cards', 'views/cardsmall_view'], (App, Cards, CardSmallView) ->

  class CardsView extends Backbone.View

    id: 'js-cards'

    template: jade.templates.cards

    events:
      # Follow links with router
      'click a.js-show': 'routerFollow'

    initialize: ->
      console.debug 'CardsView#initialize'
      # Create collection if doesn't exist already
      isNew = (not App.cards) or (App.cards.demo? and not App.cards.demo.fetched)
      @collection = App.cards = App.cards or new Cards()

      # Bind events
      @collection.on 'reset', @addAll
      @collection.on 'add', @addOne
      @collection.on 'add', @showHideNoCards
      @collection.on 'remove', @showHideNoCards

      # Render template without any cards (we will add them after)
      @$el.html @template()

      # Cache the list element, and the no cards message
      @$list = @$('#js-cardslist')
      @$noCards = @$('#js-nocards')

      # Fetch data if new collection
      if isNew
        if App.demo.active
          loader = App.notifications.newLoader()
          @collection.demo.fetch
            complete: ->
              App.notifications.remove loader
        else
          # Check if data is bootstrapped in DOM
          cardsJson = $('#cards-json').remove().text()
          if cardsJson
            @collection.reset JSON.parse(cardsJson)
          # If not, fetch from server
          else
            loader = App.notifications.newLoader()
            @collection.fetch
              complete: ->
                App.notifications.remove loader
      # If not a new collection, add all cards manually for the first time
      else
        @addAll()


    # Helper to delegate click events to router
    routerFollow: (e) ->
      App.router.follow e

    # Add one card to DOM list
    addOne: (card, addMethod) =>
      console.debug 'CardsView#addOne', card.get('name')
      # Create card DOM element
      el = new CardSmallView({model: card}).render().$el
      # By default add element to top of list
      unless addMethod == 'append'
        @$list.prepend el
      else
        @$list.append el

    # Add all cards in collection to DOM list
    addAll: =>
      console.debug 'CardsView#addAll'
      # Show or hide the no cards message (depending on the collection length)
      @showHideNoCards()
      # First remove all cards currently in list
      @$list.children().remove()
      # Then loop through collection and add each card to bottom of list
      @collection.each (card) => @addOne card, 'append'

    # Show or hide the no cards message (depending on the collection length)
    showHideNoCards: =>
      if @collection.length
        @$noCards.hide()
      else
        @$noCards.show()

    # Method called when content refresh is requested
    refresh: ->
      console.debug '----- CardsView#refresh -----'
      # Fetch fresh data from server, and view will update itself 
      if App.demo.active
        loader = App.notifications.newLoader()
        @collection.demo.fetch
          complete: ->
            App.notifications.remove loader
      else
        loader = App.notifications.newLoader()
        @collection.fetch
          complete: ->
            App.notifications.remove loader
