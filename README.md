# PT03 Frontend and Backend Communication

a Flutter Frontend that communicates with a website backend

## Functions

- Fetches and displays the initial message from https://fordemo-ot4j.onrender.com/
- Allows users to input a username and password and submit to `/users`
- Displays the response (`message`, `code`, `id`) after user creation
- Allows the fetching of user details by code and update the username
- allows fetching the first 5 users from the API
  - only the first 5 users are fetched so that it wouldn't be so slow
