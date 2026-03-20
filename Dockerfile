FROM krakend:2.13

WORKDIR /etc/krakend

COPY krakend.json .

EXPOSE 8000

CMD ["/usr/bin/krakend","run","-d","-c","/etc/krakend/krakend.json"]