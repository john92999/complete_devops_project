# Stage 1 — Build
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Compile to a static binary
RUN CGO_ENABLED=0 GOOS=linux go build -o user-service .

# Stage 2 — Run (only the binary, no Go tools)
FROM alpine:3.18

WORKDIR /app
COPY --from=builder /app/user-service .

EXPOSE 8080
CMD ["./user-service"]