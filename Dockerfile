FROM hashicorp/vault:latest

RUN apk add --no-cache ca-certificates && update-ca-certificates


# COPY ./config/certs/ca.crt /usr/local/share/ca-certificates/myvault.crt

# RUN update-ca-certificates