import multiprocessing

# The number of worker processes for handling requests
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "gevent"
worker_connections = 1000
# The socket to bind
bind = "0.0.0.0:9000"

# Define logging level
loglevel = "info"
# Enable access log and format
accesslog = "-"  # '-' means log to stdout
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'