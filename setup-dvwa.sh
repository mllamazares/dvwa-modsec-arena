#!/bin/sh

echo "Waiting for DVWA to be ready..."
until curl -s -o /dev/null -w "%{http_code}" http://dvwa:80/setup.php | grep -q "200"; do
    echo "Waiting for DVWA..."
    sleep 2
done

echo "DVWA is ready. Initializing database..."

attempts=0
max_attempts=15

while [ "$attempts" -lt "$max_attempts" ]; do
    attempts=$((attempts + 1))

    # Fetch the setup page to get the CSRF token and cookies
    curl -c /tmp/cookies.txt -s http://dvwa:80/setup.php > /tmp/setup_page.html

    # Extract the user_token
    token=$(grep "user_token" /tmp/setup_page.html | sed "s/.*value='\([a-f0-9]*\)'.*/\1/")

    if [ -z "$token" ]; then
        echo "Attempt $attempts/$max_attempts: Failed to extract CSRF token. Retrying..."
        sleep 3
        continue
    fi

    echo "Found token: $token"

    # The setup page requires a POST request to create the database with the token
    result=$(curl -b /tmp/cookies.txt -c /tmp/cookies.txt -s -L -X POST \
        -d "create_db=Create+%2F+Reset+Database&user_token=$token" \
        http://dvwa:80/setup.php)

    if echo "$result" | grep -q "Setup successful"; then
        echo "Database initialized successfully."
        exit 0
    fi

    echo "Attempt $attempts/$max_attempts: DB creation failed (MariaDB may not be ready). Retrying..."
    sleep 3
done

echo "Failed to initialize database after $max_attempts attempts."
exit 1
