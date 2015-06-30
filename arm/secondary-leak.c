#include <libcflat.h>
#include <asm/smp.h>
#include <asm/psci.h>

int main(void)
{
	assert(cpumask_weight(&cpu_present_mask) > 1);
	smp_boot_secondary(1, halt);
	psci_sys_reset();
	return 0;
}
