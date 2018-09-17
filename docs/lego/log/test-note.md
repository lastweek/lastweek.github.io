# Scripts

Scripts used to run OSDI'18 LegoOS experiments.

## CPU Freq

For fair comparision, we disable cpu freq tuning (because lego does not have it. shame!):

Add this to boot kernel command parameter:
```
intel_pstate=disable
```

## swap-to-ssd

Please remember to clear the page cache!
```
echo 3 > /proc/sys/vm/drop_caches
rm -rf /tmp/mnist_model/
lxc-execute -n test -s lxc.cgroup.memory.limit_in_bytes=128M -- python mnist.py
```

## swap-to-ramdisk

Please note we are using BLK_DEV_RAM, a block device based on RAM. We are NOT using tmpfs or ramfs. The difference is:.
```
modprobe brd rd_size=16777216
dd if=/dev/zero of=/dev/ram0 bs=4K
mkswap /dev/ram0
swapon /dev/ram0
swapoff others
```

## Accelio and nbdX

Follow [this](https://community.mellanox.com/docs/DOC-2113), and [this](https://community.mellanox.com/docs/DOC-1528).

At client, don't forget to:
```
modprobe xio_rdma; modprobe xio_tcp
modprobe nbdx
```

Side note, at nbdX server side, the block device created for client, can not be raw disk/SSD. I created a file from SSD
```c
Server:
    touch /mnt/ssd/swap
    truncate -s +4G /mnt/ssd/swap

Client:
    nbdxadm -o create_device -i 0 -d 0 -f "/mnt/ssd/swap"
```

## Infiniswap

What a crap kernel module. Kill machine randomly?

Tested with

- `CentOS 7.2`
- `MLNX_OFED_LINUX-3.3-1.0.4.0-rhel7.2-x86_64`
- `kernel 3.13.1`

Note

1.
At server side, use server ib0's IP address:

```c
# ifconfig
ib0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 2044
        inet 10.0.0.67  netmask 255.255.255.0  broadcast 10.0.0.255

./infiniswap-daemon 10.0.0.67 9400
```

At client side, use server ib0's IP in portal.list:
```
1
10.0.0.67:9400
```

2.
At client side, change the `BACKUP_DISK` to an unused disk, and use a CORRECT one! Otherwise, wait for kernel panic, ugh.