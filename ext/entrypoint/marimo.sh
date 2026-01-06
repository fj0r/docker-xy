marimo edit --no-token -p $PORT --host $HOST 2>&1 &
echo -n "$! " | sudo tee -a /var/run/services > /dev/null
