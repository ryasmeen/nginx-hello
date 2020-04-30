# use  nginx image
FROM nginx:1.17.10-alpine

# set maintainer
LABEL maintainer "yasmeen.arif1@gmail.com"

# create a directory to work in
RUN mkdir /goss
COPY goss.yaml /goss/.

# use html file
ADD code.tar.gz /usr/share/nginx/html

# tell docker what port to expose
EXPOSE 80
