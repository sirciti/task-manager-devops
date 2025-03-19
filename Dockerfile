# custom-nginx/Dockerfile
FROM nginx:alpine
COPY custom-nginx/nginx.conf /etc/nginx/nginx.conf
COPY custom-nginx/html /usr/share/nginx/html
EXPOSE 80
