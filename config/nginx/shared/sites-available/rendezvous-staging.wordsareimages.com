# Staging Rendezvous
# rendezvous-staging.wordsareimages.com
#
server {
  listen 443 ssl;
  http2 on;

  server_name rendezvous-staging.wordsareimages.com;

  access_log /var/www/rendezvous/shared/log/nginx.access.log;
  error_log /var/www/rendezvous/shared/log/nginx.error.log info;

  root /var/www/rendezvous/current/public;

  # Set canonical domain name and https
  # rewrite ^ https://citroenrendezvous.org$request_uri? permanent;

  # Get rid of double slashes
  merge_slashes off;
  rewrite ^(.*?)//+(.*?)$ $1/$2 permanent;

  if (-f $document_root/files/show_maintenance.txt) {
    return 503;
    break;
  }

  error_page 503 @maintenance;
  location @maintenance {
    rewrite ^(.*)$ /files/maintenance.html break;
  }

  # Asset files
  location ~ ^/(assets|packs|files|uploads)/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
    try_files $uri =404;
    error_page 404 /404.html;
  }

  # Other static files
  location ~ ^(?!/rails/).+\.(jpg|jpeg|gif|png|ico|json|txt|xml|csv|pdf)$ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
    try_files $uri =404;
    error_page 404 /404.html;
  }

  location / {
    proxy_pass http://rendezvous_app;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_redirect off;
  }

  ssl_certificate /etc/nginx/ssl/rendezvous_staging.crt;
  ssl_certificate_key /etc/nginx/ssl/rendezvous_staging.private.key;

  ssl_dhparam /etc/nginx/ssl/dhparams.pem;

  ssl_session_cache shared:SSL:1m;
  ssl_session_timeout 5m;

  # ssl_ciphers  HIGH:!aNULL:!MD5;
  # Update from SSL analysis
  ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305;


  ssl_prefer_server_ciphers on;

  ssl_protocols TLSv1.3 TLSv1.2 TLSv1.1;

  ## OCSP STapling
  #  (see https://support.comodo.com/index.php?/Default/Knowledgebase/Article/View/1091/37/certificate-installation--nginx)

  # resolver 127.0.0.1;
  # ssl_stapling on;
  # ssl_stapling_verify on;
  # ssl_trusted_certificate /etc/ssl/certs/2017/ssl-bundle.crt;

}

