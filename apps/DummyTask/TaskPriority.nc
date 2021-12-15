#define UQ_TASK_PRIORITY "TinySchedulerC.TaskPriority"

#include "TinyError.h"

interface TaskPriority {
    async command error_t postTask(uint8_t prio);
    event void runTask();
}