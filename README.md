## Arranque del escenario
```bash
sudo vnx -f tutorial_lxc_srlinux.xml --create  # Arranca los host del escenario (h1-h4)
                                               # r1 y r2 no se arrancan por la etiquete <on_boot>no</on_boot>
sudo vnx -f tutorial_lxc_srlinux.xml -x start-www  # Arranque servidores web en h3 y h4
./start_routers.sh   # Arranca los routers, los configura y los conectar a los OVS. Necesario tener instalado containerlab previamente (https://containerlab.dev/install/)

```
## Acceso a consolas de routers
```bash
docker exec -ti clab-nokiasr1-r1 sr_cli    # Acceso a la shell del SR linux
docker exec -ti clab-nokiasr1-r1 bash      # Acceso a una bash del router
```
## Pruebas de conectividad
```bash
sudo lxc-attach h1 ping 10.1.2.2   # ping de h1 a h3 -> OK
sudo lxc-attach h1 curl 10.1.2.2   # Acceso a web h3 -> OK
```

## Parada del escenario 
```bash
./destroy_routers.sh  # Libera los routers
sudo vnx -f tutorial_lxc_srlinux.xml --destroy  # Libera el escenario VNX
```


