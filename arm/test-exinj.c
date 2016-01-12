/*
 * Test KVM's exception injection
 *
 * Copyright (C) 2015, Red Hat Inc, Andrew Jones <drjones@redhat.com>
 *
 * This work is licensed under the terms of the GNU LGPL, version 2.
 */
#include <libcflat.h>
#include <alloc.h>
#include <asm/thread_info.h>
#include <asm/processor.h>
#include <asm/ptrace.h>

#define usage() printf("test requires '-append [EL1t-sync|EL1h-sync|EL0t-sync|AArch32-sync]'\n"), exit(1)

static const char *vector_names[] = {
	"EL1t-sync", NULL, NULL, NULL,
	"EL1h-sync", NULL, NULL, NULL,
	"EL0t-sync", NULL, NULL, NULL,
	"AArch32-sync", NULL, NULL, NULL,
};

static enum vector expected_vector;
static unsigned int expected_mode;

static void test_vectors(enum vector v, struct pt_regs *regs, unsigned int esr __unused)
{
	bool pass = false;

	if ((regs->pstate & (PSR_MODE_MASK | PSR_MODE32_BIT)) == expected_mode
			&& v == expected_vector)
		pass = true;

	report("vector-offset=0x%x (%s); pstate=0x%08llx", pass, v << 7,
		vector_names[v], regs->pstate);

	exit(report_summary());
}

static void undef_prep(enum vector v)
{
	switch (v) {
	case EL1T_SYNC:
		expected_mode = PSR_MODE_EL1t;
		break;
	case EL1H_SYNC:
		expected_mode = PSR_MODE_EL1h;
		break;
	case EL0_SYNC_64:
		expected_mode = PSR_MODE_EL0t;
		break;
	case EL0_SYNC_32:
		expected_mode = COMPAT_PSR_MODE_USR;
		break;
	default:
		return;
	}

	expected_vector = v;
	install_vector_handler(v, test_vectors);
}

static void do_undef(void *arg __unused)
{
	asm volatile("smc #0");
}

int main(int argc, char **argv)
{
	if (!argc)
		usage();

	if (strcmp(argv[0], "EL1t-sync") == 0) {

		asm volatile(
			"mov	x0, sp\n"
			"msr	sp_el0, x0\n"
			"isb\n"
			"msr	spsel, xzr\n"
			"isb\n"
			: : : "x0");

		undef_prep(EL1T_SYNC);
		do_undef(NULL);

	} else if (strcmp(argv[0], "EL1h-sync") == 0) {

		undef_prep(EL1H_SYNC);
		do_undef(NULL);

	} else if (strcmp(argv[0], "EL0t-sync") == 0) {

		void *sp = memalign(THREAD_SIZE, THREAD_SIZE);

		undef_prep(EL0_SYNC_64);
		start_usr(do_undef, NULL, (unsigned long)sp + THREAD_START_SP);

	} else if (strcmp(argv[0], "AArch32-sync") == 0) {

		void *sp = memalign(THREAD_SIZE, THREAD_SIZE);

		undef_prep(EL0_SYNC_32);
		start_usr_compat(do_undef, NULL, (unsigned long)sp + THREAD_START_SP);

	} else {
		usage();
	}

	/* unreachable */
	return 0;
}
