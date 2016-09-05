
for x in out_asm in_asm op op_opt int  mmu pcall cpu_reset unimp guest_errors page nochain
do echo $x;
   qemu-system-x86_64    -d cpu,exec,$x -device pc-testdev   -device isa-debug-exit,iobase=0xf4,iosize=0x4   -serial stdio   -device pci-testdev   -kernel $1 > $1.$x.out 2>&1
done
