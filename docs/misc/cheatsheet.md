# cheatsheet

## virsh
* Pass commands to QEMU in the virsh bash:
```
# qemu-monitor-command guest_os_id --hmp "info cpus"
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

## Markdown
* [Emoji cheatsheet](https://www.webpagefx.com/tools/emoji-cheat-sheet/)
