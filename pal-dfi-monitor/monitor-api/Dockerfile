FROM golang:1.22-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git

COPY . .

RUN go mod tidy
RUN go build -o monitor-api .

FROM docker:27-cli

WORKDIR /root/

COPY --from=builder /app/monitor-api .

EXPOSE 8091

CMD ["./monitor-api"]