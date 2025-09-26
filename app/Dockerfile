# Multi-stage build for minimal image size
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY main.go .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o app main.go

# Final stage - minimal image
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /
COPY --from=builder /app/app .
EXPOSE 8080
ENV PORT=8080
CMD ["./app"]