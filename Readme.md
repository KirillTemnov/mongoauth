# mongoauth

mongodb store backend for oauth tokens

## Install

```bash
npm install mongoauth
```
    
## Usage

```coffee-script
Store = require "mongoauth"
# change connection string
connectionString = "localhost:27017test?auto_reconnect=true"
mStore = new Store.OAuthClientStore connectionString

# call methods
mStore.saveRequestToken "example.com", {
    oauth_token: "foo"
    oauth_token_secret: "bar"
    personId: 2421}, ->
```

## API

`mongoauth` exports single class `OAuthClientStore`, public methods described below
  
`OAuthClientStore` operates token objects, which have fields:
  
  - `oauth_token` - public key
  - `oauth_token_secret` - secret key
  - `oauth_token_refresh` - refresh token (used with OAuth 2)
  - `type` - "access" | "request"
  - `client` - client for app (e.g. "twitter", "foursquare" or whatever)
  - `personId` - person, who owns token
  - `scope` - scope (for access token)
  

### `OAuthClientStore` methods

All callback functions are **requred**, pass an empty function 
if you dont need them.

#### `saveRequestToken(client, requestToken, fn)`

  Save request token.
  
  - `client` - client application name
  - `requestToken` - request token object
  - `fn(err, token)` - Callback function
    - `err` - error or `null`
    - `token` - saved token


#### `saveAccessToken(client, acessToken, fn)`

  Save access token.

  - `client` - client application name
  - `accessToken` - access token object
  - `fn(err, token)` - Callback function
    - `err` - error or `null`
    - `token` - saved token


#### `getRequestToken(client, tokenKey, fn)`

  Get request token.

  - `client` - client application name
  - `tokenKey` -  token public key
  - `fn(token)` - callback function
    - `token` - request token object (if found) or `null`


#### `getAccessToken(client, tokenKey, fn)`

 Get access token.

  - `client` - client application name
  - `tokenKey` -  token public key
  - `fn(token)` - callback function
    - `token` - access token object (if found) or `null`


#### `getPersonAccessToken(personId, client, fn)`

Get access token for specific person.

  - `personId` -  person id
  - `client` - client application name
  - `fn(token)` - callback function
    - `token` - access token object (if found) or `null`


#### `fetchAccessTokens(personIds, client, fn)`

  Fetch access tokens for array of person ids.

  - `personIds` -  array of person ids
  - `client` - client application name
  - `fn(err, tokens)` - callback function
    - `error` - error or `null`
    - `tokens` - array of tokens


#### `replaceToken(oldToken, newOAuthAccessToken, fn)`

  Replace `oldToken.oauth_token` to `newOAuthAccessToken` inside mongo

  - `oldToken` - token object
  - `newOAuthAccessToken` - new value for `oauth_token` in token object
  - `fn(error)` - callback function
    - `error` - error or `null`
    
## History

  (0.6.1) - add Replace token method for OAuth 2.0 clients (google)
    
## Licence

(The MIT License)

Copyright (c) 2012 Temnov Kirill allselead@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
