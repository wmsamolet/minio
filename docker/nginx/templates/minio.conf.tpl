
upstream minio_s3 {
    server minio1:${MINIO_S3_PORT};

    # server minio2:9000;
    # server minio3:9000;
    # server minio4:9000;
}

upstream minio_admin {
    server minio1:${MINIO_ADMIN_PORT};

    # server minio2:9001;
    # server minio3:9001;
    # server minio4:9001;
}

server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN_MINIO_S3};

    # To allow special characters in headers
    ignore_invalid_headers off;

    # Allow any size file to be uploaded.
    # Set to a value such as 1000m; to restrict file size to a specific value
    client_max_body_size 0;

    # To disable buffering
    proxy_buffering off;

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Default is HTTP/1, keepalive is only enabled in HTTP/1.1
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_connect_timeout 300;

        chunked_transfer_encoding off;

        proxy_pass http://minio_s3;
    }
}

server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN_MINIO_ADMIN};

    error_log  /var/log/nginx/minio_admin.error.log;
    access_log /var/log/nginx/minio_admin.access.log;

    # To allow special characters in headers
    ignore_invalid_headers off;

    # Allow any size file to be uploaded.
    # Set to a value such as 1000m; to restrict file size to a specific value
    client_max_body_size 0;

    # To disable buffering
    proxy_buffering off;

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-NginX-Proxy true;

        # This is necessary to pass the correct IP to be hashed
        real_ip_header X-Real-IP;

        proxy_connect_timeout 300;

        # To support websocket
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        chunked_transfer_encoding off;

        proxy_pass http://minio_admin;
    }
}
