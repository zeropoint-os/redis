#!/bin/bash

# Simple Redis test script

CONTAINER_NAME=redis-main

# Get the IP address of the redis-main container
REDIS_IP=$(docker inspect $CONTAINER_NAME --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)

if [ -z "$REDIS_IP" ]; then
    echo "Error: $CONTAINER_NAME container not found or not running"
    exit 1
fi

echo "Found $CONTAINER_NAME at IP: $REDIS_IP"
echo "Testing Redis..."
echo ""

echo "Step 1: PING"
redis-cli -h $REDIS_IP ping || true
echo ""

echo "Step 2: SET/GET"
redis-cli -h $REDIS_IP set test-key hello || true
redis-cli -h $REDIS_IP get test-key || true

echo "Test complete!"
