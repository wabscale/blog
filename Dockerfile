FROM python:3.8-alpine

WORKDIR /tmp/buildit
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY . .

RUN pelican 
