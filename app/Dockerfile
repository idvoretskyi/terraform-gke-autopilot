# Multi-stage build for a minimal, secure image

# Stage 1: build
FROM golang:1.24-alpine AS builder

ARG VERSION=dev

WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY *.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-X main.Version=${VERSION} -w -s" -o app .

# Stage 2: minimal runtime image
FROM alpine:3.21

RUN apk --no-cache add ca-certificates && \
    addgroup -S appgroup && \
    adduser -S appuser -G appgroup

WORKDIR /app
COPY --from=builder /app/app .

USER appuser

EXPOSE 8080
ENV PORT=8080
CMD ["./app"]
