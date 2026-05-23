FROM alpine:3.20

WORKDIR /app

RUN apk add --no-cache busybox-extras

EXPOSE 8080

CMD sh -c "while true; do echo -e 'HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n{\"service\":\"pma\",\"status\":\"ok\"}' | nc -l -p 8080; done"