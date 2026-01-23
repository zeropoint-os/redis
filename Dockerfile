FROM redis:7

# Expose the default Redis port
EXPOSE 6379

# Run Redis server
CMD ["redis-server"]
