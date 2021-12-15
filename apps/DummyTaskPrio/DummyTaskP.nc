#include "Timer.h"

module DummyTaskP
{
  uses interface Timer<TMilli> as Timer0;
  uses interface Timer<TMilli> as Timer1;
  uses interface Timer<TMilli> as Timer2;
  uses interface Timer<TMilli> as Timer3;
  uses interface Timer<TMilli> as Timer4;
  uses interface Leds;
  uses interface Boot;
  uses interface Random;
  uses interface TaskPriority as toggle0;
  uses interface TaskPriority as toggle1;
  uses interface TaskPriority as toggle2;
  uses interface TaskPriority as toggle3;
  uses interface TaskPriority as toggle4;
}
implementation
{
  event void toggle0.runTask()
  {
    call Leds.led0Toggle();
  }

  event void toggle1.runTask()
  {
    call Leds.led1Toggle();
  }

  event void toggle2.runTask()
  {
    call Leds.led2Toggle();
  }

  event void toggle3.runTask()
  {
    call Leds.led0Toggle();
  }

  event void toggle4.runTask()
  {
    call Leds.led1Toggle();
  }

  event void Boot.booted()
  {
    dbg("Boot", "App Booted.\n");
    call Timer0.startPeriodic( 150 );
    call Timer1.startPeriodic( 200 );
    call Timer2.startPeriodic( 300 );
    call Timer3.startPeriodic( 500 );
    call Timer4.startPeriodic( 1000 ); //random priority task
  }

  event void Timer0.fired()
  {
    call toggle0.postTask(0);
  }

  event void Timer1.fired()
  {
    call toggle1.postTask(1);
  }

  event void Timer2.fired()
  {
    call toggle2.postTask(2);
  }

  event void Timer3.fired()
  {
    call toggle3.postTask(3);
  }

  event void Timer4.fired()
  {
    uint16_t i = call Random.rand16();
    call toggle4.postTask(i%5);
  }

}
