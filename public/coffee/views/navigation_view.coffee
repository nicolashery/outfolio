define ['app'], (App) ->

  class NavigationView extends Backbone.View

    id: 'js-navigation'

    template: jade.templates.navigation

    events:
      # Follow links with router
      'click .js-cards a': 'routerFollow'

    initialize: ->
      #console.debug 'NavigationView#initialize'
      # No data to fetch, so render immediately
      @render()

    render: ->
      #console.debug 'NavigationView#render'
      # We need to construct the data for template a little bit
      data = {}
      data.authenticated = App.session.authenticated
      data.user = App.user.toJSON()
      @$el.html @template(data)
      @

    # Helper to delegate click events to router
    routerFollow: (e) ->
      App.router.follow e

    # Routes
    # ------

    cards: ->
      #console.debug 'NavigationView#cards'
      @$('.js-cards').addClass('active')

