define ['app', 'models/owner'], (App, Owner) ->

  class SubnavCardsView extends Backbone.View

    id: 'js-subnavcards'

    template: jade.templates.subnavcards

    events:
      # Follow links with router
      'click .js-cards a': 'routerFollow'
      'click .js-new a': 'routerFollow'
      'click .js-share a': 'routerFollow'
      'click .js-card a': 'routerFollow'
      'click .js-edit a': 'routerFollow'
      'click .js-card-share a': 'routerFollow'
      'click .js-shared a': 'routerFollow'
      'click .js-shared-card a': 'routerFollow'
      # Bind these events to view's methods
      'click .js-refresh a': 'refresh'
      'click .js-delete a': 'destroy'

    initialize: ->
      #console.debug 'SubnavCardsView#initialize'
      # This view uses more than one models, and not all at the same time
      # so initialize a 'data' object to attach them when needed
      @data =
        # To hide parts when not authenticated
        authenticated: null
        # To generate correct links when viewing single card
        card: null
        # To display owner name 
        # when viewing set of cards from sharing user
        owner: null 
      # Add a 'toJSON' helper function to data 
      # to convert the models for the template
      @data.toJSON = ->
        res = {}
        # Add authenticated directly here
        res.authenticated = App.session.authenticated
        res.card = @card?.toJSON()
        res.owner = @owner?.toJSON()
        res

      # Create model unique for this view
      App.owner = App.owner or new Owner()

      # Some routes need to fire asynchronously
      App.dispatcher.on 'card:ready', @card
      App.dispatcher.on 'card:edit:ready', @edit
      App.dispatcher.on 'card:share:ready', @cardShare
      App.dispatcher.on 'shared:card:ready', @sharedCard

      # Check if owner data is bootstrapped in DOM
      ownerJson = $('#owner-json').remove().text()
      if ownerJson
        App.owner.set JSON.parse(ownerJson)

    render: =>
      #console.debug 'SubnavCardsView#render'
      @$el.html @template(@data.toJSON())
      @

    # Helper to delegate click events to router
    routerFollow: (e) ->
      App.router.follow e

    # Helper to update DOM with currently active subnav link
    activateLink: (selector) ->
      # Remove active from all links
      @$('li').each (index, element) ->
        $(element).removeClass('active')
      # Add active to current link
      @$(selector).addClass('active')

    # Toggles the delete link between delete and confirm delete states
    # and returns true if it was a confirm delete,
    # false if it was just delete
    confirmDelete: () ->
      # Cache the link
      $delete = @$('.js-delete a')
      if $delete.hasClass('js-confirm-delete')
        $delete.removeClass('js-confirm-delete')
        $delete.text('Delete')
        true
      else
        $delete.addClass('js-confirm-delete')
        $delete.text('Delete?')
        false

    # Ask for a content refresh by triggering appropriate event
    refresh: (e) ->
      e.preventDefault()
      App.dispatcher.trigger 'content:refresh'

    # Delete a card
    destroy: (e) ->
      #console.debug 'SubnavCardsView#destroy'
      e.preventDefault()
      # First check that user confirmed delete
      if @confirmDelete()
        # Grab current card and delete
        # Card small view will take care of removing list element from DOM
        card = App.card
        if App.demo.active
          App.demo.destroy card
        else
          card.destroy()
        # Navigate back to card list
        App.router.navigate 'cards', trigger: true
        $(window).scrollTop(0)

    # Routes
    # ------

    cards: ->
      #console.debug 'SubnavCardsView#cards'
      # Update data object
      @data.card = null
      @data.owner = null
      # Render template
      @render()
      # Activate current link
      @activateLink '.js-cards'
      @

    new: ->
      #console.debug 'SubnavCardsView#new'
      # Update data object
      @data.card = null
      @data.owner = null
      # Render template
      @render()
      # Activate current link
      @activateLink '.js-new'
      @

    share: ->
      #console.debug 'SubnavCardsView#share'
      # Update data object
      @data.card = null
      @data.owner = null
      # Render template
      @render()
      # Activate current link
      @activateLink '.js-share'
      @

    card: =>
      #console.debug 'SubnavCardsView#card'
      # This route fires asynchronously, once card is ready
      # Update data object
      @data.card = App.card
      @data.owner = null
      # Render template
      @render()
      # Activate current link
      @activateLink '.js-card'
      @

    edit: =>
      #console.debug 'SubnavCardsView#edit'
      # This route fires asynchronously, once card is ready
      # Update data object
      @data.card = App.card
      @data.owner = null
      # Render template
      @render()
      # Activate current link
      @activateLink '.js-edit'
      @

    cardShare: =>
      #console.debug 'SubnavCardsView#cardShare'
      # This route fires asynchronously, once card is ready
      # Update data object
      @data.card = App.card
      @data.owner = null
      # Render template
      @render()
      # Activate current link
      @activateLink '.js-card-share'
      @

    shared: (shareId) ->
      #console.debug 'SubnavCardsView#shared', shareId
      # Update data object
      @data.card = null
      @data.owner = App.owner
      # If we already have correct owner, just render
      if App.owner.id == shareId
        @render()
        @activateLink '.js-shared'
      # If not, fetch owner and update view asynchronously upon success
      else
        if App.demo.active
          # Normally we would construct url with share id
          # But for demo we can just fetch demo user
          App.owner.demo.fetch
            success: =>
              @render()
              @activateLink '.js-shared'
        else
          # Set owner id
          App.owner.set '_id', shareId
          # Get owner from server and render once received
          App.owner.fetch
            success: =>
              @render()
              @activateLink '.js-shared'
      @

    sharedCard: =>
      #console.debug 'SubnavCardsView#sharedCard'
      # This route fires asynchronously, once card is ready
      # Update data object
      @data.card = App.sharedCard
      # Set owner object with card owner
      App.owner.set App.sharedCard.get('owner')
      @data.owner = App.owner
      # Render and activate link
      @render()
      @activateLink '.js-shared-card'
      @

