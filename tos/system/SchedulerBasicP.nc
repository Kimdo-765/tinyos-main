// $Id: SchedulerBasicP.nc,v 1.11 2010-06-29 22:07:56 scipio Exp $

/*
 * Copyright (c) 2000-2003 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the University of California nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Copyright (c) 2002-2003 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */

/**
 * SchedulerBasicP implements the default TinyOS scheduler sequence, as
 * documented in TEP 106.
 *
 * @author Philip Levis
 * @author Cory Sharp
 * @date   January 19 2005
 */

#include <hardware.h>

module SchedulerBasicP @safe() {
  provides interface Scheduler;
  provides interface TaskBasic[uint8_t id];
  provides interface TaskPriority[uint8_t id];
  uses interface McuSleep;
}
implementation
{
  enum
  {
    NUM_TASKS = uniqueCount("TinySchedulerC.TaskBasic"),
    NUM_TASKS_P = uniqueCount("TinySchedulerC.TaskPriority"),
    NO_TASK = 255,
  };

  uint8_t m_head;
  uint8_t m_tail;
  uint8_t m_next[NUM_TASKS];

  uint8_t m_p_head;
  uint8_t m_p_tail;
  uint8_t m_p_next[NUM_TASKS];
  uint8_t m_p_prio[NUM_TASKS];

  // Helper functions (internal functions) intentionally do not have atomic
  // sections.  It is left as the duty of the exported interface functions to
  // manage atomicity to minimize chances for binary code bloat.

  // move the head forward
  // if the head is at the end, mark the tail at the end, too
  // mark the task as not in the queue
  inline uint8_t popTask()
  {
    if( m_head != NO_TASK )
    {
      uint8_t id = m_head;
      m_head = m_next[m_head];
      if( m_head == NO_TASK )
      {
	m_tail = NO_TASK;
      }
      m_next[id] = NO_TASK;
      return id;
    }
    else
    {
      return NO_TASK;
    }
  }
  
  inline uint8_t popPTask()
  {
    if( m_p_head != NO_TASK )
    {
      uint8_t id = m_p_head;
      m_p_head = m_p_next[m_p_head];
      if( m_p_head == NO_TASK )
      {
        m_p_tail = NO_TASK;
      }
      m_p_next[id] = NO_TASK;
      m_p_prio[id] = NO_TASK;
      return id;
    }
    else
    {
      return NO_TASK;
    }
  }
  
  bool isWaiting( uint8_t id )
  {
    return (m_next[id] != NO_TASK) || (m_tail == id);
  }

  bool isPWaiting( uint8_t id )
  {
    return (m_p_next[id] != NO_TASK) || (m_p_tail == id);
  }

  bool pushTask( uint8_t id )
  {
    if( !isWaiting(id) )
    {
      if( m_head == NO_TASK )
      {
      	m_head = id;
	      m_tail = id;
      }
      else
      {
	      m_next[m_tail] = id;
	      m_tail = id;
      }
      return TRUE;
    }
    else
    {
      return FALSE;
    }
  }
  
  bool pushPTask( uint8_t id, uint8_t prio)
  {
    if( !isPWaiting(id) )
    {
      if( m_p_head == NO_TASK )
      {
	      m_head = id;
      	m_tail = id;
        m_p_prio[id] = prio;
      }
      else
      {
        uint8_t q = m_p_head;
        while(m_p_next[q] != NO_TASK && m_p_prio[m_p_next[q]] <= prio)
          q = m_p_next[q];
        if(q == m_tail)
          m_tail = id;
        m_p_next[id] = m_p_next[q];
        m_p_next[q] = id;
      }
      return TRUE;
    }
    else
    {
      return FALSE;
    }
  }

  command void Scheduler.init()
  {
    atomic
    {
      memset( (void *)m_next, NO_TASK, sizeof(m_next) );
      m_head = NO_TASK;
      m_tail = NO_TASK;

      memset( (void *)m_p_next, NO_TASK, sizeof(m_p_next) );
      memset( (void *)m_p_prio, NO_TASK, sizeof(m_p_prio) );
      m_p_head = NO_TASK;
      m_p_tail = NO_TASK;
    }
  }
  
  command bool Scheduler.runNextTask()
  {
    uint8_t nextTask;
    atomic
    {
      nextTask = popTask();
      if( nextTask == NO_TASK )
      {
        nextTask = popPTask();
        if( nextTask == NO_TASK )
	        return FALSE;
        signal TaskPriority.runTask[nextTask]();
        return TRUE;
      }
    }
    signal TaskBasic.runTask[nextTask]();
    return TRUE;
  }

  command void Scheduler.taskLoop()
  {
    for (;;)
    {
      uint8_t nextTask;
      uint8_t nextPTask;

      atomic
      {
      	while ((nextTask = popTask()) == NO_TASK &&
               (nextPTask = popPTask()) == NO_TASK)
	      {
	        call McuSleep.sleep();
	      }
      }
      if ( nextTask != NO_TASK){
        signal TaskBasic.runTask[nextTask]();
      }
      else if( nextPTask != NO_TASK){
        signal TaskPriority.runTask[nextPTask]();
      }
    }
  }

  /**
   * Return SUCCESS if the post succeeded, EBUSY if it was already posted.
   */
  
  async command error_t TaskBasic.postTask[uint8_t id]()
  {
    atomic { return pushTask(id) ? SUCCESS : EBUSY; }
  }

  async command error_t TaskPriority.postTask[uint8_t id](uint8_t prio)
  {
    atomic { return pushPTask(id, prio) ? SUCCESS : EBUSY; }
  }

  default event void TaskBasic.runTask[uint8_t id]()
  {
  }

  default event void TaskPriority.runTask[uint8_t id]()
  {
  }
}

