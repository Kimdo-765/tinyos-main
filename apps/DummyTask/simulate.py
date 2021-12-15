from TOSSIM import *
import sys

t = Tossim([])
m = t.getNode(32)
m.bootAtTime(45654)

t.addChannel("Boot", sys.stdout)
t.addChannel("Priority", sys.stdout)
t.addChannel("Task", sys.stdout)
while True:
    t.runNextEvent()
