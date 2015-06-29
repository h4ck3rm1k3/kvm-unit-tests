#ifndef _ASMARM64_SPINLOCK_H_
#define _ASMARM64_SPINLOCK_H_

struct spinlock {
	int v;
};

static inline void spin_lock_init(struct spinlock *lock)
{
	lock->v = 0;
}

extern void spin_lock(struct spinlock *lock);
extern void spin_unlock(struct spinlock *lock);

#endif /* _ASMARM64_SPINLOCK_H_ */
