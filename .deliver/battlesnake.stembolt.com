// /etc/nginx/sites-enabled/my-app.domain

upstream phoenix {
  server 127.0.0.1:8080 max_fails=5 fail_timeout=60s;
}

server {
  server_name battlesnake.stembolt.com;
  listen 80;

  location / {
    allow all;

    # Proxy Headers
    proxy_http_version 1.1;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_set_header X-Cluster-Client-Ip $remote_addr;

    # The Important Websocket Bits!
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    proxy_pass http://phoenix;
  }
}
