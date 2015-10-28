/*
 * Test the ARM Performance Monitors Unit (PMU).
 *
 * Copyright 2015 The Linux Foundation. All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License version 2.1 and
 * only version 2.1 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
 * for more details.
 */
#include "libcflat.h"

#define NR_SAMPLES 10

#if defined(__arm__)
static inline uint32_t get_pmcr(void)
{
	uint32_t ret;

	asm volatile("mrc p15, 0, %0, c9, c12, 0" : "=r" (ret));
	return ret;
}

static inline void set_pmcr(uint32_t pmcr)
{
	asm volatile("mcr p15, 0, %0, c9, c12, 0" : : "r" (pmcr));
}

/*
 * While PMCCNTR can be accessed as a 64 bit coprocessor register, returning 64
 * bits doesn't seem worth the trouble when differential usage of the result is
 * expected (with differences that can easily fit in 32 bits). So just return
 * the lower 32 bits of the cycle count in AArch32.
 */
static inline unsigned long get_pmccntr(void)
{
	unsigned long cycles;

	asm volatile("mrc p15, 0, %0, c9, c13, 0" : "=r" (cycles));
	return cycles;
}
#elif defined(__aarch64__)
static inline uint32_t get_pmcr(void)
{
	uint32_t ret;

	asm volatile("mrs %0, pmcr_el0" : "=r" (ret));
	return ret;
}

static inline void set_pmcr(uint32_t pmcr)
{
	asm volatile("msr pmcr_el0, %0" : : "r" (pmcr));
}

static inline unsigned long get_pmccntr(void)
{
	unsigned long cycles;

	asm volatile("mrs %0, pmccntr_el0" : "=r" (cycles));
	return cycles;
}
#endif

struct pmu_data {
	union {
		uint32_t pmcr_el0;
		struct {
			uint32_t enable:1;
			uint32_t event_counter_reset:1;
			uint32_t cycle_counter_reset:1;
			uint32_t cycle_counter_clock_divider:1;
			uint32_t event_counter_export:1;
			uint32_t cycle_counter_disable_when_prohibited:1;
			uint32_t cycle_counter_long:1;
			uint32_t reserved:4;
			uint32_t counters:5;
			uint32_t identification_code:8;
			uint32_t implementer:8;
		};
	};
};

/*
 * As a simple sanity check on the PMCR_EL0, ensure the implementer field isn't
 * null. Also print out a couple other interesting fields for diagnostic
 * purposes. For example, as of fall 2015, QEMU TCG mode doesn't implement
 * event counters and therefore reports zero event counters, but hopefully
 * support for at least the instructions event will be added in the future and
 * the reported number of event counters will become nonzero.
 */
static bool check_pmcr(void)
{
	struct pmu_data pmu;

	pmu.pmcr_el0 = get_pmcr();

	printf("PMU implementer:     %c\n", pmu.implementer);
	printf("Identification code: 0x%x\n", pmu.identification_code);
	printf("Event counters:      %d\n", pmu.counters);

	return pmu.implementer != 0;
}

/*
 * Ensure that the cycle counter progresses between back-to-back reads.
 */
static bool check_cycles_increase(void)
{
	struct pmu_data pmu = {0};

	pmu.enable = 1;
	set_pmcr(pmu.pmcr_el0);

	for (int i = 0; i < NR_SAMPLES; i++) {
		unsigned long a, b;

		a = get_pmccntr();
		b = get_pmccntr();

		if (a >= b) {
			printf("Read %ld then %ld.\n", a, b);
			return false;
		}
	}

	return true;
}

int main(void)
{
	report_prefix_push("pmu");

	report("Control register", check_pmcr());
	report("Monotonically increasing cycle count", check_cycles_increase());

	return report_summary();
}
