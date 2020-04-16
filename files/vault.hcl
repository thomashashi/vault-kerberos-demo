listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = "true"
}

api_addr     = "http://127.0.0.1:8200"
cluster_addr = "http://127.0.0.1:8201"

storage "file" {
  path = "/srv/vault/data"
}

ui = true
