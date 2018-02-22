# cheatsheet

## virsh
* Pass commands to QEMU in the virsh bash:
```
# qemu-monitor-command guest_os_id --hmp "info cpus"
```

## Markdown
* [Emoji cheatsheet](https://www.webpagefx.com/tools/emoji-cheat-sheet/)

## tmux
* Install [tmux-plugins](https://github.com/tmux-plugins), it makes your terminal bling bling.

## bash

* Show current git branch in PS1:
```bash
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ git:(\1)/'
}

PS1="\[\e[32m\][\u@\h: \W\e[33m\]\$(parse_git_branch)\[\033[32m\]]\[\e[00m\] $ "
```

## QEMU

* Run standalone kernel:
```bash
# Create a new directory to store the serial output from printk().
OUTPUT_DIR="test-output"
if [ -e $OUTPUT_DIR ]; then
        if [ -f $OUTPUT_DIR ]; then
                echo "ERROR: $OUTPUT_DIR is not a directly"
                exit 1
        fi
else
        mkdir -p $OUTPUT_DIR
fi

KERNEL="arch/x86_64/boot/bzImage"
KERNEL_PARAM="console=ttyS0 earlyprintk=serial,ttyS0,115200"
SERIAL="-serial file:$OUTPUT_DIR/ttyS0 -serial file:$OUTPUT_DIR/ttyS1"

# -cpu Haswell,+tsc,+sse,+xsave,+aes,+avx,+erms,+pdpe1gb,+pge \
# Above -cpu option may not work with some kernels.
qemu-system-x86_64 -s  \
        -nographic \
        -kernel $KERNEL -append "$KERNEL_PARAM" \
        -no-reboot \
        -d int,cpu_reset -D $OUTPUT_DIR/qemu.log \
        $SERIAL \
        -m 16G \
        -monitor stdio \
        -smp cpus=24,cores=12,threads=2,sockets=2 \
        -numa node,cpus=0-11,mem=8G,nodeid=0 \
        -numa node,cpus=12-23,mem=8G,nodeid=1
```

## Install CentOS on Dell PowerEdge

- Enable `SR-IOV` for future usage
    - Press `F11 Boot Manager` during boot
    - Find `Integrated Devices`
    - Enable `SR-IOV Global Enable`
- Partition
    - `/boot`: e.g, 50GB
    - `swap`: e.g, 4G
    - `/`: all left
- Don't forget to enable Network during installation.
- Change SSH port
    - Disable `firewalld`
        - `systemctl stop firewalld`
        - `systemctl disable firewalld`
    - If SELinux is enabled
        - `yum install policycoreutils-python`
        - `semanage port -a -t ssh_port_t -p tcp #PORTNUMBER`
    - Change `/etc/ssh/sshd_config`
    - `systemctl restart sshd`

## Avoid Typing SSH Password

- Generate keys: `ssh-keygen -t rsa`
- Copy to remote: `ssh-copy-id -i ~/.ssh/id_rsa.pub username@remotehost -p 22`
