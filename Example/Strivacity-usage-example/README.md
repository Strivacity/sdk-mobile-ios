# SDK for communicating with Strivacity Authentication APIs - Demo App

This app demonstrates communication with Strivacity Authentication APIs via SDK library.
The configuration contained in project build settings must be modified in order for the app to function.

The following properties can be specified:

- `CLIENT_ID` (required): The OAuth2 client id used to identify the client to the authorization server.

- `CLIENT_SECRET` (required): The OAuth2 client secret is a secret known only to the application and 
  the authorization server. It is essential the application’s own password.

- `DOMAIN`: Domain of Strivacity authentication server.

- `REDIRECT_URI` (required): The URI to use for receiving the authorization response. Applications that uses 
  Strivacity APIs must specify authorized redirect URIs.

The demo application has a button for each of the Strivacity Authentication APIs methods (https://api.strivacity.com/) and
the corresponding label for the id token, access token and auth code.

- `AuthFlow`: Performs "Begin an OIDC Authorization Flow" request.
  The authorization code will be obtained from redirected URI after successful user login in the web form.

  Note: Application must have enabled `Interactive Login and Registration`

- `Request token id`: Performs "Obtain an ID Token from an Authorization Code" request.
  Requires authorization code obtained from `Authorization flow` or `Hybrid flow` APIs. The successful
  response contains access token and id token.

- `Hybrid flow`: Performs "Begin an OIDC Hybrid Flow" request.
  The authorization code and id token will be obtained from redirected URI after successful user 
  login in the web form.
  
  Note: Application must have enabled `Interactive Login and Registration`
  
- `Logout`: Performs "Begin an OIDC Initiated Logout" request.
  Requires valid id token obtained from `Hybrid flow` or `Perform token id` APIs.

- `Request token`: Performs "Obtain an Access Token via Client Credentials" request.
  Successful response contains access token.

  Note: Application must have disabled `Interactive Login and Registration`
  
