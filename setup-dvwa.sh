#!/bin/sh

echo "Waiting for DVWA to be ready..."
until curl -s http://dvwa:80/login.php > /dev/null; do
    echo "Waiting for DVWA..."
    sleep 2
done

echo "Initializing database..."
# Fetch the setup page to get the CSRF token and cookies
curl -c /tmp/cookies.txt -s http://dvwa:80/setup.php > /tmp/setup_page.html

# Extract the user_token
token=$(grep "user_token" /tmp/setup_page.html | sed "s/.*value='\([a-f0-9]*\)'.*/\1/")

if [ -z "$token" ]; then
    echo "Failed to extract CSRF token."
    exit 1
fi

echo "Found token: $token"

# The setup page requires a POST request to create the database with the token
curl -b /tmp/cookies.txt -c /tmp/cookies.txt -s -L -X POST -d "create_db=Create+%2F+Reset+Database&user_token=$token" http://dvwa:80/setup.php | grep "Database has been created"

if [ $? -eq 0 ]; then
    echo "Database initialized successfully."
else
    echo "Failed to initialize database."
    # Print the output for debugging if needed
    # cat /tmp/setup_page.html
fi
