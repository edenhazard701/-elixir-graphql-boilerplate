#!/bin/bash

set -e

source ./setenv.sh

# Ensure the app's dependencies are installed
mix deps.get

# Potentially Set up the database
mix ecto.create
mix ecto.migrate

echo "Launching Phoenix web server..."
# Start the phoenix web server
mix phx.server
