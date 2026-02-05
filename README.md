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
sudo bash -c "$(curl -sL https://github.com/VanyaKrotov/xray-scripts/raw/refs/heads/main/setup_cert.sh)"
```
