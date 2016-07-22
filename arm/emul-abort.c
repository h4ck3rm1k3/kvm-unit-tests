/*
 * Test emulation of guest aborts
 *
 * Copyright (C) 2016, Red Hat Inc, Andrew Jones <drjones@redhat.com>
 *
 * This work is licensed under the terms of the GNU LGPL, version 2.
 */
#include <libcflat.h>
#include <asm/processor.h>
#include <asm/thread_info.h>
#include <asm/setup.h>

#define USAGE "usage: emul-abort <subtest>\n"	\
	"subtests:\n"				\
	"   pabtinj-usr32-mem\n"		\
	"   pabtinj-usr64-mem\n"		\
	"   pabtinj-usr32-io\n"			\
	"   pabtinj-usr64-io"

#define UNMAPPED_MEM		(PHYS_END + 64*1024)
#define UNMAPPED_IO		0xf010000

typedef void (*func_t)(void *arg);

static unsigned long do_pabt, mode, far;
static bool pass;

static void finish_pabt(void)
{
	report("bad_addr=0x%08lx far=0x%08lx", pass, do_pabt, far);
	exit(report_summary());
}

static void handle_pabt(struct pt_regs *regs, unsigned int esr)
{
	bool far_valid;

	if (esr >> ESR_EL1_EC_SHIFT != ESR_EL1_EC_IABT_EL0)
		return;

	far_valid = get_far(esr, &far);

	pass = far_valid && far == do_pabt;
	pass = pass && regs->pc == do_pabt;
	pass = pass && (regs->pstate & (PSR_MODE32_BIT | PSR_MODE_MASK)) == mode;

	regs->pstate &= ~PSR_MODE32_BIT;
	regs->pc = (unsigned long)finish_pabt;
}

static void pabtinj_test(bool is_64)
{
	unsigned long sp = (unsigned long)thread_stack_alloc();

	if (is_64) {
		install_exception_handler(EL0_SYNC_64, ESR_EL1_EC_IABT_EL0, handle_pabt);
		start_usr((func_t)do_pabt, NULL, sp);
	} else {
		mode = PSR_MODE32_BIT;
		install_exception_handler(EL0_SYNC_32, ESR_EL1_EC_IABT_EL0, handle_pabt);
		start_usr32((func_t)do_pabt, NULL, sp);
	}
}

void main(int ac, char **av)
{
	if (ac < 2)
		report_abort(USAGE);

	if (strncmp(av[1], "pabtinj-usr", 11) == 0) {

		char *testname = av[1] + 11;
		bool is_64 = false;

		if (strncmp(testname, "32", 2) == 0)
			is_64 = false;
		else if (strncmp(testname, "64", 2) == 0)
			is_64 = true;
		else
			report_abort(USAGE);

		if (strcmp(testname + 2, "-mem") == 0)
			do_pabt = UNMAPPED_MEM;
		else if (strcmp(testname + 2, "-io") == 0)
			do_pabt = UNMAPPED_IO;
		else
			report_abort(USAGE);

		report_prefix_push(av[1]);
		pabtinj_test(is_64);

	} else {
		report_abort(USAGE);
	}
}
