from TOSSIM import *
import sys

t = Tossim([])
m = t.getNode(32)
m.bootAtTime(45654)

t.addChannel("Boot", sys.stdout)
t.addChannel("PrioPop", sys.stdout)
t.addChannel("PrioPush", sys.stdout)
t.addChannel("PopCount", sys.stdout)
t.addChannel("DeadLine", sys.stdout)
for i in range(5000):
    t.runNextEvent()
