FROM python:3.8-alpine
WORKDIR /tmp/buildit
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY . .
RUN pelican


FROM nginx:1.19.1
COPY --from=0 /tmp/buildit/output /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
