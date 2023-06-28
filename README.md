# test-webserver

The code you provided looks fine. It includes a new `/api` endpoint that accepts a POST request with JSON data containing a `status` field. 
It then changes the `httpStatusCode` variable, which affects the status code returned by the `/` (home) endpoint.

Here's a summary of the changes made to your code:

1. Introduced a new `Data` struct to represent the JSON data containing the `status` field.
2. Added a global `httpStatusCode` variable to hold the desired HTTP status code.
3. In the `/api` endpoint handler, parse the JSON data and update the `httpStatusCode` variable accordingly.
4. Modified the `/` (home) endpoint handler to use the `httpStatusCode` variable when setting the response status code.

Now, when you send a POST request to the `/api` endpoint with JSON data containing a `status` field, the `httpStatusCode` will be updated accordingly. Subsequent requests to the home page (`/`) will return the updated status code.

Please note that in a production environment, you should consider adding error handling, proper validation, and security measures to the code.