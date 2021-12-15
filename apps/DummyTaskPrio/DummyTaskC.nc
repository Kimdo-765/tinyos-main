configuration DummyTaskC {    
}  
implementation {  
  components MainC, DummyTaskP, LedsC, TinySchedulerC, RandomC;
  components new TimerMilliC() as Timer0;
  components new TimerMilliC() as Timer1;
  components new TimerMilliC() as Timer2;
  components new TimerMilliC() as Timer3;
  components new TimerMilliC() as Timer4;


  DummyTaskP -> MainC.Boot;
  DummyTaskP.Timer0 -> Timer0;
  DummyTaskP.Timer1 -> Timer1;
  DummyTaskP.Timer2 -> Timer2;
  DummyTaskP.Timer3 -> Timer3;
  DummyTaskP.Timer4 -> Timer4;
  DummyTaskP.Leds -> LedsC;
  DummyTaskP.Random -> RandomC;
  DummyTaskP.toggle0 -> TinySchedulerC.TaskPriority[unique("TinySchedulerC.TaskPriority")];
  DummyTaskP.toggle1 -> TinySchedulerC.TaskPriority[unique("TinySchedulerC.TaskPriority")];
  DummyTaskP.toggle2 -> TinySchedulerC.TaskPriority[unique("TinySchedulerC.TaskPriority")];
  DummyTaskP.toggle3 -> TinySchedulerC.TaskPriority[unique("TinySchedulerC.TaskPriority")];
  DummyTaskP.toggle4 -> TinySchedulerC.TaskPriority[unique("TinySchedulerC.TaskPriority")];
} 
