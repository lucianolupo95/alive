#!/bin/bash
set -e

echo "▶ Updating alive repository"
git fetch origin
git pull origin main

echo "▶ Deploying alive site"
./deploy.sh

echo "✓ Alive updated successfully"
