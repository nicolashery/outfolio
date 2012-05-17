define ['app'], (App) ->

  class CardSmallView extends Backbone.View

    # List item view
    tagName: 'li'

    template: jade.templates.cardsmall

    initialize: ->
      # Whenever the card changes, re-render
      @model.on 'change', @render
      # When model is detroyed, remove element from DOM 
      @model.on 'destroy', @destroy

    render: =>
      # Shorten the attributes for this list view
      data = 
        _id: @model.id
        name: @model.shorten('name')
        address: @model.shorten('address')
        city: @model.shorten('city')
        notes: @model.shorten('notes')
      @$el.html @template(data)
      @

    destroy: =>
      @$el.remove()
