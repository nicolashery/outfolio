define ['app', 'models/user', 'models/cards', 'models/card', 'models/owner', 'models/sharedcards', 'models/sharedcard'], (App, User, Cards, Card, Owner, SharedCards, SharedCard) ->

  # This is a class that holds demo data and 'fake' demo functions 
  # to emulate models' server functions fetch, save, etc.
  class Demo

    # Indicates if we are currently in demo or not
    active: false

    # Simulate server response time (in milliseconds)
    responseDelay: 0

    constructor: ->
      console.debug 'Demo#initialize'
      # If active is already set to true, load demo
      @load() if @active

    # Load demo data and create demo functions on models
    load: ->
      console.debug 'Demo#load'

      # Create app models if they don't exist yet
      App.user = App.user or new User()
      App.cards = App.cards or new Cards()
      App.card = App.card or new Card()
      App.sharedCards = App.sharedCards or new SharedCards()
      App.sharedCard = App.sharedCard or new SharedCard()
      App.owner = App.owner or new Owner()

      # Add empty demo object to models
      App.user.demo = {}
      App.cards.demo = {}
      App.card.demo = {}
      App.sharedCards.demo = {}
      App.sharedCard.demo = {}
      App.owner.demo = {}

      # Demo data
      demoUser =
        _id: '1'
        name: 'Don Draper'
        email: 'dondraper@example.com'

      demoCards = [
          _id: '1'
          name: 'The Dead Poet'
          address: '450 Amsterdam Ave (& 81st St)'
          city: 'New York'
          notes: 'Irish pub, small room, good beer selection, music jukebox'
          owner: {_id: '1', name: 'Don Draper'}
        ,
          _id: '2'
          name: 'Solas'
          address: '232 E 9th Street (& 2nd Ave)'
          city: 'New York'
          notes: 'Dancing bar, mainstream music, large room, usually not a long line to get in'
          owner: {_id: '1', name: 'Don Draper'}
        ,
          _id: '3'
          name: 'Sweet Leaf'
          address: '10-93 Jackson Avenue (& 49th Ave), Long Island City'
          city: 'New York'
          notes: 'Great little coffee shop in Long Island City, very good coffee, nice decor with leather seats & vinyl records'
          owner: {_id: '1', name: 'Don Draper'}
        ,
          _id: '4'
          name: 'Cloister Cafe'
          address: '238 East 9th Street (& 2nd Ave)'
          city: 'New York'
          notes: 'Hookah bar, nice decor & outside seating, great hookah, decent food too'
          owner: {_id: '1', name: 'Don Draper'}
        ,
          _id: '5'
          name: 'The 55 Bar'
          address: '55 Christopher Street (& 7th Ave)'
          city: 'New York'
          notes: 'Small jazz bar, 2 shows usually 7pm & 10pm, arrive early, good atmosphere'
          owner: {_id: '1', name: 'Don Draper'}
        ,
          _id: '6'
          name: 'Piccolo Cafe'
          address: '238 Madison Ave (& 37th St)'
          city: 'New York'
          notes: 'Small italian, great for lunch, good pasta & sandwiches, not expensive'
          owner: {_id: '1', name: 'Don Draper'}
        ,
          _id: '7'
          name: 'Dominie\'s Hoek'
          address: '48-17 Vernon Boulevard (& 49th Ave), Long Island City'
          city: 'New York'
          notes: 'Bar, outdoor sitting area, cheaper than Manhattan bars, kitchen with your usual bar food'
          owner: {_id: '1', name: 'Don Draper'}
        ,
          _id: '8'
          name: '230 Fifth'
          address: '230 5th Ave (& 27th St)'
          city: 'New York'
          notes: 'Rooftop bar, amazing view of Empire State, a little expensive, arrive early for a good seat'
          owner: {_id: '1', name: 'Don Draper'}
        ]

      # Add demo functions
      App.user.demo.load = ->
        console.debug 'user#demo#load'
        App.user.set demoUser

      App.cards.demo.fetch = (options) =>
        console.debug 'cards#demo#fetch loading'
        # Indicate for the demo that data has already been fetched
        App.cards.demo.fetched = true
        triggerError = false
        options = if options then options else {}
        success = options.success
        error = options.error
        complete = options.complete
        setTimeout =>
          if triggerError
            console.debug 'cards#demo#fetch error'
            $('body').trigger('ajaxError')
            error() if error
            complete() if complete
            false
          else
            console.debug 'cards#demo#fetch success'
            App.cards.reset demoCards
            $('body').trigger('ajaxSuccess')
            success() if success
            complete() if complete
            true
        , @responseDelay

      App.cards.demo.create = (card, options) =>
        console.debug "cards#demo#create loading"
        triggerError = false
        options = if options then options else {}
        success = options.success
        error = options.error
        complete = options.complete
        silent  = if options.silent then options.silent else false
        at = options.at
        # Generate demo card id
        card._id = (parseInt(_.max(App.cards.models, (model) -> model.id).id) + 1).toString()
        # Immediately add card to collection, then sync with server
        App.cards.add card, {at: at, silent: silent}
        setTimeout =>
          if triggerError
            console.debug "cards#demo#create error"
            $('body').trigger('ajaxError')
            error() if error
            complete() if complete
            false
          else
            console.debug "cards#demo#create success"
            $('body').trigger('ajaxSuccess')
            success() if success
            complete() if complete
            true
        @responseDelay

      App.card.demo.fetch = (options) =>
        console.debug 'card#demo#fetch loading'
        # Indicate for the demo that data has already been fetched
        App.card.demo.fetched = true
        # Grab the id of the card we are trying to fetch
        id = App.card.id
        triggerError = false
        options = if options then options else {}
        success = options.success
        error = options.error
        complete = options.complete
        setTimeout =>
          if triggerError
            console.debug 'card#demo#fetch error'
            $('body').trigger('ajaxError')
            error() if error
            complete() if complete
            false
          else
            console.debug 'card#demo#fetch success'
            App.card.set _.filter(demoCards, (card) -> card.id == id)[0]
            $('body').trigger('ajaxSuccess')
            success() if success
            complete() if complete
            true
        , @responseDelay

      App.sharedCards.demo.fetch = (options) =>
        console.debug 'sharedCards#demo#fetch loading'
        triggerError = false
        options = if options then options else {}
        success = options.success
        error = options.error
        complete = options.complete
        setTimeout =>
          if triggerError
            console.debug 'sharedCards#demo#fetch error'
            $('body').trigger('ajaxError')
            error() if error
            complete() if complete
            false
          else
            console.debug 'sharedCards#demo#fetch success'
            App.sharedCards.reset demoCards
            $('body').trigger('ajaxSuccess')
            success() if success
            complete() if complete
            true
        , @responseDelay

      App.sharedCard.demo.fetch = (options) =>
        console.debug 'sharedCard#demo#fetch loading'
        # Indicate for the demo that data has already been fetched
        App.sharedCard.demo.fetched = true
        # Grab the id of the card we are trying to fetch
        id = App.sharedCard.id
        triggerError = false
        options = if options then options else {}
        success = options.success
        error = options.error
        complete = options.complete
        setTimeout =>
          if triggerError
            console.debug 'sharedCard#demo#fetch error'
            $('body').trigger('ajaxError')
            error() if error
            complete() if complete
            false
          else
            console.debug 'sharedCard#demo#fetch success'
            App.sharedCard.set _.filter(demoCards, (card) -> card.id == id)[0]
            $('body').trigger('ajaxSuccess')
            success() if success
            complete() if complete
            true
        , @responseDelay

      App.owner.demo.fetch = (options) =>
        console.debug 'owner#demo#fetch loading'
        triggerError = false
        options = if options then options else {}
        success = options.success
        error = options.error
        complete = options.complete
        setTimeout =>
          if triggerError
            console.debug 'owner#demo#fetch error'
            $('body').trigger('ajaxError')
            error() if error
            complete() if complete
            false
          else
            console.debug 'owner#demo#fetch success'
            App.owner.set demoUser
            $('body').trigger('ajaxSuccess')
            success() if success
            complete() if complete
            true
        , @responseDelay/2

      # Indicate that we are in demo mode
      @active = true

    # Helper function to delete a model
    destroy: (model, options) ->
      # Send destroy event to model and collection
      model.trigger('destroy', model, model.collection, options)

    # Remove demo functions and switch off demo mode
    unload: ->
      console.debug 'Demo#unload'
      App.user.demo = null
      App.cards.demo = null
      App.card.demo = null
      App.sharedCards.demo = null
      App.sharedCard.demo = null
      App.owner.demo = null
      @active = false

