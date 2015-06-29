#ifndef __ASM_SPINLOCK_H
#define __ASM_SPINLOCK_H

struct spinlock {
    int v;
};

static inline void spin_lock_init(struct spinlock *lock)
{
	lock->v = 0;
}

void spin_lock(struct spinlock *lock);
void spin_unlock(struct spinlock *lock);

#endif
