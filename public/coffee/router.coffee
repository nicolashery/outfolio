define ['app', 'views/subnavcards_view', 'views/cards_view', 'views/cardsnew_view', 'views/cardsshare_view', 'views/card_view', 'views/cardedit_view', 'views/cardshare_view', 'views/sharedcards_view', 'views/sharedcard_view'], (App, SubnavCardsView, CardsView, CardsNewView, CardsShareView, CardView, CardEditView, CardShareView, SharedCardsView, SharedCardView) ->

  # The router reacts to certain changes in the URL
  # and creates or updates the app's views accordingly
  class Router extends Backbone.Router

    routes:
      '':                             'index'
      'demo':                         'cards'
      'cards':                        'cards'
      'cards/new':                    'cardsNew'
      'cards/share':                  'cardsShare'
      'card/:id':                     'card'
      'card/:id/edit':                'cardEdit'
      'card/:id/share':               'cardShare'
      'shared/:shareId':              'shared'
      'shared/:shareId/card/:cardId': 'sharedCard'

    initialize: ->
      console.debug 'Router#initialize'

    # Function for views to bind to 'click' events on elements
    # with a 'href' attribute that allows router to follow that route
    follow: (e) =>
      e.preventDefault()
      # Grab 'href' attribute of whatever was clicked on 
      # and format it to use in router's 'navigate' function
      # Note: we use 'currentTarget' vs 'target' to make sure we grab
      # closest element that fired the event
      $el = $(e.currentTarget)
      fragment = $el.attr('href').replace(Backbone.history.routeStripper, '')
      @navigate fragment, trigger: true

    # Routes
    # ------

    index: ->
      console.debug '----- Router#index ------'
      @cards()

    cards: ->
      console.debug '----- Router#cards -----'
      # Create views
      App.subnavCardsView = App.subnavCardsView or new SubnavCardsView()
      App.cardsView = App.cardsView or new CardsView()
      # Update views
      App.navigationView.cards()
      App.subnavView.show App.subnavCardsView.cards()
      App.contentView.show App.cardsView

    cardsNew: ->
      console.debug '----- Router#cardsNew -----'
      # Create views
      App.subnavCardsView = App.subnavCardsView or new SubnavCardsView()
      App.cardsNewView = App.cardsNewView or new CardsNewView()
      # Update views
      App.navigationView.cards()
      App.subnavView.show App.subnavCardsView.new()
      App.contentView.show App.cardsNewView

    cardsShare: ->
      console.debug '----- Router#cardsShare -----'
      # Create views
      App.subnavCardsView = App.subnavCardsView or new SubnavCardsView()
      App.cardsShareView = App.cardsShareView or new CardsShareView()
      # Update views
      App.navigationView.cards()
      App.subnavView.show App.subnavCardsView.share()
      # Always re-render this view, in case user modified the link in textbox
      App.contentView.show App.cardsShareView.render()

    card: (id) ->
      console.debug "----- Router#card/#{id} -----"
      # Create views
      App.subnavCardsView = App.subnavCardsView or new SubnavCardsView()
      App.cardView = App.cardView or new CardView(id)
      # Update views
      App.navigationView.cards()
      # Subnav will update asynchronously, once card is ready
      App.subnavView.show App.subnavCardsView
      App.contentView.show App.cardView.index(id)

    cardEdit: (id) ->
      console.debug "----- Router#card/#{id}/edit -----"
      # Create views
      App.subnavCardsView = App.subnavCardsView or new SubnavCardsView()
      App.cardEditView = App.cardEditView or new CardEditView(id)
      # Update views
      App.navigationView.cards()
      # Subnav will update asynchronously, once card is ready
      App.subnavView.show App.subnavCardsView
      App.contentView.show App.cardEditView.index(id)

    cardShare: (id) ->
      console.debug "----- Router#card/#{id}/share -----"
      # Create views
      App.subnavCardsView = App.subnavCardsView or new SubnavCardsView()
      App.cardShareView = App.cardShareView or new CardShareView(id)
      # Update views
      App.navigationView.cards()
      # Subnav will update asynchronously, once card is ready
      App.subnavView.show App.subnavCardsView
      App.contentView.show App.cardShareView.index(id)

    shared: (shareId) ->
      console.debug "----- Router#shared/#{shareId} -----"
      # Create views
      App.subnavCardsView = App.subnavCardsView or new SubnavCardsView()
      App.sharedCardsView = App.sharedCardsView or new SharedCardsView(shareId)
      # Update views
      App.navigationView.cards()
      App.subnavView.show App.subnavCardsView.shared(shareId)
      App.contentView.show App.sharedCardsView.index(shareId)

    sharedCard: (shareId, cardId) ->
      console.debug "----- Router#shared/#{shareId}/card/#{cardId} -----"
      # Create views
      App.subnavCardsView = App.subnavCardsView or new SubnavCardsView()
      App.sharedCardView = App.sharedCardView or new SharedCardView()
      # Update views
      App.navigationView.cards()
      # Subnav will update asynchronously, once card is ready
      App.subnavView.show App.subnavCardsView
      App.contentView.show App.sharedCardView.index(shareId, cardId)
