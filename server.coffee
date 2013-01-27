express = require 'express'
mongoose = require 'mongoose'
everyauth = require 'everyauth'

# Environment variables for config
port = process.env.PORT or 3000
mongodbUri = process.env.MONGOLAB_URI or 'mongodb://localhost/outfolio'
googleClientId = process.env.GOOGLE_CLIENTID or '484129397477.apps.googleusercontent.com'
googleClientSecret = process.env.GOOGLE_CLIENTSECRET or 'oVZOq-Ad1MNFHw9jNpOgWa0T'

# Some setup
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

app = express()

mongoose.connect mongodbUri

everyauth.debug = false

# MODELS
# ------------------------------

# Card
# ---------------

# Define the card schema and its keys
CardSchema = new Schema
  name: String
  address: String
  city: String
  notes: String
  owner:
    _id: {type: ObjectId, index: true}
    name: String
  created_on: {type: Date, default: Date.now}
  modified_on: {type: Date, default: Date.now}

# Everytime a card is saved, update the 'modified_on' field
CardSchema.pre 'save', (next) ->
  @.modified_on = new Date
  next()

# Helper method to return all cards owned by a user
# sorted by most recently created
CardSchema.statics.allByUserId = (userId, callback) ->
  query = @.find({})
  query.where('owner._id').equals(userId)
  query.sort '-created_on'
  query.exec callback

Card = mongoose.model 'Card', CardSchema

# User
# ---------------

# Base user schema only has a created_on data,
# all other keys will be added by auth plugins
UserSchema = new Schema
  created_on: {type: Date, default: Date.now}

# Add authentication capabilities to user schema
googleAuthPlugin = (schema, options) ->
  # Add all the keys necessary
  schema.add
    google:
      # Google User
      id: String
      email: String
      verified_email: Boolean
      name: String
      given_name: String
      family_name: String
      link: String
      gender: String
      locale: String
      # Access Token
      access_token: String
      # Access Token Extra
      token_type: String
      expires_in: Number
      #id_token: String (not useful)
      # App
      expires: Date

  # Method to create a new user via Google login
  schema.static 'createWithGoogleOAuth', (accessToken, accessTokenExtra, googleUser, callback) ->
    # Convert expires_in (seconds) to an expire date
    expiresDate = new Date
    expiresDate.setSeconds(expiresDate.getSeconds() + accessTokenExtra.expires_in)

    # Set all values to load from Google user data
    params =
      google:
        # Google User
        id: googleUser.id
        email: googleUser.email
        verified_email: googleUser.verified_email
        name: googleUser.name
        given_name: googleUser.given_name
        family_name: googleUser.family_name
        link: googleUser.link
        gender: googleUser.gender
        locale: googleUser.locale
        # Access Token
        access_token: accessToken
        # Access Token Extra
        token_type: accessTokenExtra.token_type
        expires_in: accessTokenExtra.expires_in
        #id_token: accessTokenExtra.id_token
        # App
        expires: expiresDate

    # Create new user
    @create params, callback

# Add Google auth plugin to user schema
UserSchema.plugin googleAuthPlugin

User = mongoose.model 'User', UserSchema


# DEV DATA
# ------------------------------

# WARNING: for dev only, make sure you set to false in production
bootstrapData = false

if bootstrapData

  Card.find().remove()

  new Card
    name: 'The Dead Poet'
    address: '450 Amsterdam Ave (& 81st St)'
    city: 'New York'
    notes: 'Irish pub, small room, good beer selection, music jukebox'
    owner: {_id: '4fae78cd846ebe2204000003', name: 'Nicolas Hery'}
  .save()

  new Card
    name: 'Solas'
    address: '232 E 9th Street (& 2nd Ave)'
    city: 'New York'
    notes: 'Dancing bar, mainstream music, large room, usually not a long line to get in'
    owner: {_id: '4fae78cd846ebe2204000003', name: 'Nicolas Hery'}
  .save()


# AUTHENTICATION
# ------------------------------

# Set Google auth parameters for this app
everyauth.google
  .entryPath('/login') # Since we're only using Google to login
  .callbackPath('/auth/google/callback')
  .appId(googleClientId)
  .appSecret(googleClientSecret)
  # We are just requesting the email address and basic user info from Google
  .scope('https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile')
  .redirectPath('/')

# Set some paths to logout
everyauth.everymodule.logoutPath '/logout'
everyauth.everymodule.logoutRedirectPath '/'

# Have everyauth use mongoose to lookup a user
everyauth.everymodule.findUserById (userId, callback) ->
  User.findById(userId, callback)

# Set everyauth's function to find or create a user from Google, 
# by using mongoose
everyauth.google.findOrCreateUser (session, accessToken, accessTokenExtra, googleUser) ->
  promise = @Promise()
  # TODO Check user in session or request helper first
  #      e.g., req.user or sess.auth.userId
  # (this comment was from mongoose-auth)
  User.findOne {'google.id': googleUser.id}, (err, foundUser) ->
    if foundUser
      promise.fulfill foundUser
    else
      User.createWithGoogleOAuth accessToken, accessTokenExtra, googleUser, (err, createdUser) ->
        if err
          promise.fail err
        else
          promise.fulfill createdUser
  promise


# MIDDLEWARE
# ------------------------------

app.configure ->
  app.use express.bodyParser()
  app.use express.cookieParser('penguin')
  app.use express.session({secret: 'penguin'})
  app.use everyauth.middleware()
  app.use express.methodOverride()
  app.use app.router
  app.set 'view engine', 'jade'
  app.set 'view options', {layout: true}
  app.set 'views', __dirname + '/views'
  app.use express.static(__dirname + '/public')

app.configure 'development', ->
  app.use express.logger('dev')
  app.use express.errorHandler({ dumpExceptions: true, showStack: true })

app.configure 'production', ->
  app.use express.logger()
  app.use express.errorHandler()


# HELPERS
# ------------------------------

# Return basic user info in json data
# to be bootstrapped in DOM
createUserJson = (user) ->
  JSON.stringify
    _id: user._id
    name: user.google.name
    email: user.google.email


# ROUTES
# ------------------------------

# Application
# ---------------
# The user-facing urls of our app
# We either render 'app' template if we are logged in
# or 'home' template if not

app.get '/', (req, res, next) ->
  if req.loggedIn
    Card.allByUserId req.user._id, (err, cards) ->
      return next(err) if err
      # Prepare data to be bootstrapped into DOM
      locals =
        userJson: createUserJson(req.user)
        cardsJson: JSON.stringify(cards)
      res.render 'app', locals
  else
    locals =
      authenticated: false
    res.render 'home', locals

app.get '/home', (req, res) ->
  if req.loggedIn
    locals =
      authenticated: true
      user: {name: req.user.google.name}
    res.render 'home', locals
  else
    locals =
      authenticated: false
    res.render 'home', locals

app.get '/demo', (req, res) ->
  res.render 'app', userJson: 'demo'

app.get '/cards', (req, res) ->
  if req.loggedIn
    Card.allByUserId req.user._id, (err, cards) ->
      return next(err) if err
      locals =
        userJson: createUserJson(req.user)
        cardsJson: JSON.stringify(cards)
      res.render 'app', locals
  else
    res.redirect '/'

app.get '/cards/new', (req, res) ->
  if req.loggedIn
    Card.allByUserId req.user._id, (err, cards) ->
      return next(err) if err
      locals =
        userJson: createUserJson(req.user)
        cardsJson: JSON.stringify(cards)
      res.render 'app', locals
  else
    res.redirect '/'

app.get '/cards/share', (req, res) ->
  if req.loggedIn
    locals =
      userJson: createUserJson(req.user)
    res.render 'app', locals
  else
    res.redirect '/'

app.get '/card/:id', (req, res) ->
  if req.loggedIn
    Card.findById req.params.id, (err, card) ->
      # Error if id is not valid ObjectId, 
      # null card if valid ObjectId but no match,
      # and check card belongs to user
      if err or not card? or 
         card.owner._id.toString() != req.user._id.toString()
        # Not found
        return res.redirect '/'
      locals =
        userJson: createUserJson(req.user)
        cardJson: JSON.stringify(card)
      res.render 'app', locals
  else
    res.redirect '/'

app.get '/card/:id/edit', (req, res) ->
  if req.loggedIn
    Card.findById req.params.id, (err, card) ->
      if err or not card? or 
         card.owner._id.toString() != req.user._id.toString()
        # Not found
        return res.redirect '/'
      locals =
        userJson: createUserJson(req.user)
        cardJson: JSON.stringify(card)
      res.render 'app', locals
  else
    res.redirect '/'

app.get '/card/:id/share', (req, res) ->
  if req.loggedIn
    Card.findById req.params.id, (err, card) ->
      if err or not card? or 
         card.owner._id.toString() != req.user._id.toString()
        # Not found
        return res.redirect '/'
      locals =
        userJson: createUserJson(req.user)
        cardJson: JSON.stringify(card)
      res.render 'app', locals
  else
    res.redirect '/'

app.get '/shared/:shareId', (req, res) ->
  # First look for owner of share id
  User.findById req.params.shareId, (err, owner) ->
    if err or not owner?
      # Not found
      return res.redirect '/'
    # Share id is valid, get owner's cards
    Card.allByUserId req.params.shareId, (err, cards) ->
      return next(err) if err
      # Build bootstrap data
      locals =
        ownerJson: JSON.stringify({_id: owner._id, name: owner.google.name})
        sharedCardsJson: JSON.stringify(cards)
      # Add user if logged in
      if req.loggedIn
        locals.userJson = createUserJson(req.user)
      # Send app
      res.render 'app', locals

app.get '/shared/:shareId/card/:cardId', (req, res) ->
  # First look for owner of share id
  User.findById req.params.shareId, (err, owner) ->
    if err or not owner?
      # Not found
      return res.redirect '/'
    # Share id is valid, look for card
    Card.findById req.params.cardId, (err, card) ->
      # Make sure card belongs to share id
      if err or not card? or 
         card.owner._id.toString() != req.params.shareId
        # Not found
        return res.redirect '/'
      # Build bootstrap data
      locals =
        sharedCardJson: JSON.stringify(card)
      # Add user if logged in
      if req.loggedIn
        locals.userJson = createUserJson(req.user)
      # Send app
      res.render 'app', locals


# API
# ---------------
# JSON API for our models
# 'Cards' has full CRUD methods (given authorization)
# 'Shared' has only some GET methods

app.get '/api/cards', (req, res, next) ->
  if req.loggedIn
    Card.allByUserId req.user._id, (err, cards) ->
      return next(err) if err
      res.send cards
  else
    res.send 'Unauthorized', 401

app.get '/api/cards/:id', (req, res, next) ->
  if req.loggedIn
    Card.findById req.params.id, (err, card) ->
      # Error if id is not valid ObjectId, 
      # null card if valid ObjectId but no match,
      # and check card belongs to user
      if err or not card? or 
         card.owner._id.toString() != req.user._id.toString()
        return res.send 'Not Found', 404
      res.send card
  else
    res.send 'Unauthorized', 401

app.post '/api/cards', (req, res, next) ->
  if req.loggedIn
    # Prepare new card from data in request body
    card = new Card
      name: req.body.name
      address: req.body.address
      city: req.body.city
      notes: req.body.notes
      owner:
        _id: req.user._id
        name: req.user.google.name
    # Save new card to database
    card.save (err) ->
      return next(err) if err
      res.send card
  else
    res.send 'Unauthorized', 401

app.put '/api/cards/:id', (req, res, next) ->
  if req.loggedIn
    Card.findById req.params.id, (err, card) ->
      if err or not card? or 
         card.owner._id.toString() != req.user._id.toString()
        return res.send 'Not Found', 404
      # Set new card attributes
      card.name = req.body.name
      card.address = req.body.address
      card.city = req.body.city
      card.notes = req.body.notes
      # Save changes to database
      card.save (err) ->
        return next(err) if err
        res.send card
  else
    res.send 'Unauthorized', 401

app.del '/api/cards/:id', (req, res, next) ->
  if req.loggedIn
    Card.findById req.params.id, (err, card) ->
      if err or not card? or 
         card.owner._id.toString() != req.user._id.toString()
        return res.send 'Not Found', 404
      # Remove card from database
      card.remove (err) ->
        return next(err) if err
        res.send ''
  else
    res.send 'Unauthorized', 401

app.get '/api/owners/:id', (req, res, next) ->
  # Search users for card owner, but return only subset of data
  User.findById req.params.id, ['google.name'], (err, owner) ->
    if err or not owner?
      return res.send 'Not Found', 404
    # Need to format a bit before sending data
    res.send
      _id: owner._id
      name: owner.google.name

app.get '/api/shared/:shareId/cards', (req, res, next) ->
  # First look for owner of share id
  User.findById req.params.shareId, (err, owner) ->
    if err or not owner?
      return res.send 'Not Found', 404
    # Share id is valid, get owner's cards
    Card.allByUserId req.params.shareId, (err, cards) ->
      return next(err) if err
      res.send cards

app.get '/api/shared/:shareId/cards/:cardId', (req, res, next) ->
  # First look for owner of share id
  User.findById req.params.shareId, (err, owner) ->
    if err or not owner?
      return res.send 'Not Found', 404
    # Share id is valid, look for card
    Card.findById req.params.cardId, (err, card) ->
      # Make sure card belongs to share id
      if err or not card? or 
         card.owner._id.toString() != req.params.shareId
        return res.send 'Not Found', 404
      res.send card


# START
# ------------------------------

app.listen port

console.log "Outfolio listening on port #{port}"
