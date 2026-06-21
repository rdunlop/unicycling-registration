#!/bin/sh
rm -rf tmp/pids/server.pid
if [ "$ROBOTS_DISALLOW_ALL" = "true" ]; then
  cp public/robots.disallow.txt public/robots.txt
fi
exec "$@"
