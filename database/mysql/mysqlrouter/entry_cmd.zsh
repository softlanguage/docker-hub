#!/bin/bash

# Run database migrations
python manage.py migrate

# Start the web server
python app.py

# Trap SIGTERM signal and gracefully shut down the server
trap 'kill -TERM ${!} && wait' TERM

# Wait for child processes to exit
wait
