configuration DummyTaskC {    
}  
implementation {  
  components MainC, DummyTaskP, LedsC, TinySchedulerC, RandomC;
  components new TimerMilliC() as Timer0;

  DummyTaskP -> MainC.Boot;
  DummyTaskP.Timer0 -> Timer0;
  DummyTaskP.Leds -> LedsC;
  DummyTaskP.Random -> RandomC;
  DummyTaskP.toggle -> TinySchedulerC.TaskPriority[unique("TinySchedulerC.TaskPriority")];
} 
