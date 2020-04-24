# use  nginx image
FROM nginx:1.17.10-alpine

# set maintainer
LABEL maintainer "yasmeen.arif1@gmail.com"

# use html file
COPY index.html  /usr/share/nginx/html 

# tell docker what port to expose
EXPOSE 80
