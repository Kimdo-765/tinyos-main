#include "Timer.h"

module DummyTaskP
{
  uses interface Timer<TMilli> as Timer0;
  uses interface Leds;
  uses interface Boot;
  uses interface Random;
  uses interface TaskPriority as toggle;
}
implementation
{
  event void toggle.runTask()
  {
    uint16_t k;
    dbg("Task", "Task Started.\n");
    call Leds.led0Toggle();
    for(k=100;k>0;k--)
      call toggle.postTask(k%5);
  }

  event void Boot.booted()
  {
    dbg("Boot", "App Booted.\n");
    call Timer0.startPeriodic( 1000 );
  }

  event void Timer0.fired()
  {
    uint16_t i = call Random.rand16();
    call toggle.postTask(i%5);
    call toggle.postTask(i%4);
    call toggle.postTask(i%3);
    call toggle.postTask(i%2);
    call toggle.postTask(i%1);
  }

}
