define ['app'], (App) ->

  class SharedCardSmallView extends Backbone.View

    # List item view
    tagName: 'li'

    template: jade.templates.sharedcardsmall

    render: =>
      # Shorten the attributes for this list view
      data = 
        _id: @model.id
        name: @model.shorten('name')
        address: @model.shorten('address')
        city: @model.shorten('city')
        notes: @model.shorten('notes')
        # Add owner as we need it for the card link
        owner: @model.get('owner')
      @$el.html @template(data)
      @
