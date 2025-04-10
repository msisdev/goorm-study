# Kernel Module

## Prepare
```
sudo apt install gcc make build-essential libncurses-dev exuberant-ctags
```

## Code
Source code
```c
// dvt-driver.c
#include <linux/init.h>
#include <linux/module.h>
#include <linux/uaccess.h>
#include <linux/fs.h>
#include <linux/proc_fs.h>

// Module metadata
MODULE_AUTHOR("msisdev");
MODULE_DESCRIPTION("Hello world driver");
MODULE_LICENSE("GPL");

// Custom init and exit methods
static int __init custom_init(void) {
  printk(KERN_INFO "Hello world driver loaded.");
  return 0;
}

static void __exit custom_exit(void) {
  printk(KERN_INFO "Goodbye my friend, I shall miss you dearly...");
}

module_init(custom_init);
module_exit(custom_exit);
```

Makefile
```makefile
obj-m += dvt-driver.o

all:
  make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules
clean:
  make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
```

Compile
```
make
```

### makefile:4: *** missing separator. Stop
On VS Code, just click the "Space: 4" on the downright corner and change it to tab when editing your Makefile.



## Create a new kernel module
```
sudo insmod dvt-driver.ko
```

```
$ lsmod
...
dvt_driver             12288  0
...
```

## dmesg
dmesg?
- a command on most Unix-like operating systems that prints the message buffer of the kernel. The output includes messages produced by the device drivers.

Currently 
```
$ sudo dmesg
...
[23138.384537] dvt_driver: loading out-of-tree module taints kernel.
[23138.384542] dvt_driver: module verification failed: signature and/or required key missing - tainting kernel
```

Insert and remove your kernel module twice.
```
sudo insmod dvt-driver.ko
sudo rmmod dvt_driver
sudo insmod dvt-driver.ko
sudo rmmod dvt_driver
```

Then 
```
$ sudo dmesg
...
[23138.384537] dvt_driver: loading out-of-tree module taints kernel.
[23138.384542] dvt_driver: module verification failed: signature and/or required key missing - tainting kernel
[23138.384769] Hello world driver loaded.
[23738.908640] Goodbye my friend, I shall miss you dearly...
[23758.048093] Hello world driver loaded.
```

### module verification failed: signature and/or required key missing - tainting kernel
```
$ sudo dmesg
...
[23138.384537] dvt_driver: loading out-of-tree module taints kernel.
[23138.384542] dvt_driver: module verification failed: signature and/or required key missing - tainting kernel
...
```

The "tainted kernel" message is a warning, not an error, the module should be loaded regardless.



## References

Ruan de Bruyn: [How to write your first Linux Kernel Module](https://medium.com/dvt-engineering/how-to-write-your-first-linux-kernel-module-cf284408beeb)

