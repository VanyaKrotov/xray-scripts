# For setup marzban node

### Connect to remote server

```sh
ssh user@your-server-ip
```

### Update packages

```sh
sudo apt update & sudo apt upgrade
```

### Install marzban-node

```sh
sudo bash -c "$(curl -sL https://github.com/Gozargah/Marzban-scripts/raw/master/marzban-node.sh)" @ install
```

### Setup masked via nginx

```sh
sudo bash -c "$(curl -sL https://github.com/VanyaKrotov/xray-scripts/raw/refs/heads/main/setup_masking_nginx.sh)"
```

### Setup cert

```sh
# first setup cert in node 
sudo bash -c "$(curl -sL https://github.com/VanyaKrotov/xray-scripts/raw/refs/heads/main/setup_cert.sh)"

# move archive to main server
scp root@NODE_SERVER_IP:/root/marzban_cert_DOMAIN.tar.gz .

# unpackage archive

sudo bash -c "$(curl -sL https://github.com/VanyaKrotov/xray-scripts/raw/refs/heads/main/unpack_certs.sh)" / DOMAIN PATH_TO_ARCHIVE

# or

sudo bash -c "$(curl -sL https://github.com/VanyaKrotov/xray-scripts/raw/refs/heads/main/load_and_unpack_certs.sh)"
```

### download geo assets

```sh
sudo bash -c "$(curl -sL https://github.com/VanyaKrotov/xray-scripts/raw/refs/heads/main/download_geoassets.sh)"
```
