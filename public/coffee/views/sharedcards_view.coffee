define ['app', 'models/sharedcards', 'views/sharedcardsmall_view'], (App, SharedCards, SharedCardSmallView) ->

  class SharedCardsView extends Backbone.View

    id: 'js-sharedcards'

    template: jade.templates.sharedcards

    events:
      # Follow links with router
      'click a.js-show': 'routerFollow'

    # Keep track of the last loaded share id, to reload only if changed
    shareId: null

    initialize: (shareId) ->
      #console.debug 'SharedCardsView#initialize'
      # Create collection if doesn't exist already
      @collection = App.sharedCards = App.sharedCards or new SharedCards()

      # Bind events
      @collection.on 'reset', @addAll

      # Render template without any cards (we will add them after)
      @$el.html @template()

      # Cache the list element, and the no cards message
      @$list = @$('#js-cardslist')
      @$noCards = @$('#js-nocards')

      # Check if data is bootstrapped in DOM
      sharedCardsJson = $('#sharedcards-json').remove().text()
      if sharedCardsJson
        # Set share id
        @shareId = shareId
        # Reset collection with bootstrapped data
        @collection.reset JSON.parse(sharedCardsJson)

    # Helper to delegate click events to router
    routerFollow: (e) ->
      App.router.follow e

    # Add one card to DOM list
    addOne: (card, addMethod) =>
      #console.debug 'SharedCardsView#addOne', card.get('name')
      # Create card DOM element
      el = new SharedCardSmallView({model: card}).render().$el
      # By default add element to top of list
      unless addMethod == 'append'
        @$list.prepend el
      else
        @$list.append el

    # Add all cards in collection to DOM list
    addAll: =>
      #console.debug 'SharedCardsView#addAll'
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
      #console.debug '----- SharedCardsView#refresh -----'
      # Fetch fresh data from server, and view will update itself 
      if App.demo.active
        # We would actually construct url with share id, 
        # but for demo just fetch demo user cards
        loader = App.notifications.newLoader()
        @collection.demo.fetch
          complete: ->
            App.notifications.remove loader
      else
        # Set collection's share id
        @collection.shareId = @shareId
        loader = App.notifications.newLoader()
        # Get data from server
        @collection.fetch
          complete: ->
            App.notifications.remove loader

    # Load cards from a share id
    index: (shareId) ->
      #console.debug 'SharedCardsView#index', shareId
      # Check if we are not alread displaying this share id
      unless @shareId == shareId
        # Set new share id and refresh
        @shareId = shareId
        @refresh()
      @







