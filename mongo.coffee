#
# Module for manupulate oauth tokens, stored in mongodb
#

mongo = require "mongoskin"


#
# Client tokens store class.
#
# TokenObject consist of:
#   :oauth_token                   - public key
#   :oauth_token_secret            - secret key
#   :type                          - "access" | "request"
#   :client                        - client for app (e.g. "twitter")
#   :personId                      - person, who owns token
#   :scope                         - scope (for access token)
#
#
#
class OAuthClientStore

  #
  # Internal: Create new mongoskin connection
  #
  #
  _createConnection: ->
   mongo.db @connectionString

  #
  # Internal: Save token
  #
  #
  #   TokenObject    - token object save/update
  #   fn(err, token) - Callback function
  #     err          - error or null
  #     token        - saved token
  #
  _saveToken: (tokenToStore, fn) ->
    tokenToStore.time ||= new Date()
    db = @_createConnection()
    db.collection(@collectionName).ensureIndex {oauth_token: 1, client: 1, type: 1, personId: 1}, {unique: yes}, ->
    db.collection(@collectionName).update {oauth_token: tokenToStore.oauth_token, client: tokenToStore.client, type: tokenToStore.type}, tokenToStore, {safe: yes, upsert: yes, new: yes}, (err, token) ->
      db.close()
      fn err, token

  #
  # Public: Save request token.
  #
  #   client         - client application name
  #   requestToken   - request token object
  #   fn(err, token) - Callback function
  #     err          - error or null
  #     token        - saved token
  #
  saveRequestToken: (client, requestToken, fn) ->
    requestToken.type   = "request"
    requestToken.client = client
    @_saveToken requestToken, fn


  #
  # Public: Save access token.
  #
  #   client - client application name
  #   accessToken - access token object
  #   fn(err, token) - Callback function
  #     err          - error or null
  #     token        - saved token
  #
  saveAccessToken: (client, accessToken, fn) ->
    accessToken.time ||= new Date()
    accessToken.type    = "access"
    accessToken.client  = client
    db = @_createConnection()
    db.collection(@collectionName).remove {personId: accessToken.personId, client: client, type: "access"}, {safe: yes}, (err) =>
      unless err
        db.collection(@collectionName).insert accessToken, {safe: yes}, (err, token) ->
          db.close()
          fn err, token
      else
        db.close()
        fn err, token


  #
  # Internal: Fetch token from store.
  #
  #  tokenToFetch - token object to fetch Token to fetch
  #    :oauth_token  - token key
  #    :client       - client application name
  #    :type         - token type
  #                 all above fields are required
  #  fn(token) - callback function
  #    token   - token object (if found) or null
  #
  _fetchToken: (tokenToFetch, fn) ->
    db = @_createConnection()
    db.collection(@collectionName).findOne {oauth_token: tokenToFetch.oauth_token, client: tokenToFetch.client, type: tokenToFetch.type}, (err, token) ->
      db.close()
      fn null is err && token || null

  #
  #   Public: Get request token.
  #
  #   client    - client application name
  #   token_key -  token public key
  #   fn(token) - callback function
  #     token   - request token object (if found) or null
  #
  getRequestToken: (client, token_key, fn) ->
    tok =
      oauth_token : token_key
      client      : client
      type        : "request"
    @_fetchToken tok, fn

  #
  #   Public: Get access token.
  #
  #   client    - client application name
  #   token_key -  token public key
  #   fn(token) - callback function
  #     token   - access token object (if found) or null
  #
  getAccessToken: (client, token_key, fn) ->
    tok =
      oauth_token : token_key
      client      : client
      type        : "access"
    @_fetchToken tok, fn

  #
  #   Public: Get personal access token.
  #
  #   personId -  person id
  #   client - client application name
  #   fn(token) - callback function
  #     token   - access token object (if found) or null
  #
  getPersonAccessToken: (personId, client, fn) ->
    db = @_createConnection()
    db.collection(@collectionName).findOne {personId: personId, client: client, type: "access"}, (err, token) ->
        db.close()
        fn null is err && token || null

  #
  #   Public: Fetch access tokens for `personIds`.
  #
  #   personIds       -  array of person ids
  #   client          - client application name
  #   fn(err, tokens) - callback function
  #     error         - error or null
  #     tokens        - array of tokens
  #
  fetchAccessTokens: (personIds, client, fn) ->
    db = @_createConnection()
    db.collection(@collectionName).find({client: client, type: "access", personId: $in: personIds}).toArray (err, tokens) ->
      db.close()
      fn err, tokens

exports.OAuthClientStore = OAuthClientStore

