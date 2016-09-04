
# test in debug mode
qemu-system-x86_64  -d cpu,exec,page  -device pc-testdev -device isa-debug-exit,iobase=0xf4,iosize=0x4  -serial stdio -device pci-testdev -kernel ./x86/msr.flat
#qemu-system-x86_64  -d cpu  -device pc-testdev -device isa-debug-exit,iobase=0xf4,iosize=0x4  -serial stdio -device pci-testdev -kernel ./x86/msr.flat 
