<h1>PDP-11 related tools</h1>

<h2>addressReduce.py</h2>

A ODT tool that makes entering programs somewhat simpler. It takes a file in the ODT-dump format and feeds it to the PDP-11 console. It is very simple, and doesn't even checks what the PDP-11 responds. A typical ODT-dump looks like:
<pre>000200/016700
000202/000032
000204/010010
000206/005720
000210/020027
000212/017500
000214/101773
000216/024000
000220/001401
000222/000000
000224/026700
000226/000006
000230/103772
000232/000240
000234/000761
</pre>
Empty lines and lines starting with a '#' are ignored. On dump lines, a trailing comment is also ignored, as long as it is preceded by a #.

<h2>p11Disas.pl</h2>

An early attempt to make a disassembler for PDP-11 programs. It uses the ODT-dump format as input. It isn't very fancy, but it was surprisingly easy to make. A disassembly of the dump above looks like:

<pre>.=001000+LC
MOV #000770, R6  
CLR R0  
MOV #000002, R1  
MOV R1, (R0)+  
CLR (R0)+  
ADD #000004, R1  
CMP R6, R0  
BNE L001012     ; PC -10  
MOV #000100, @#177546  
BR L001034     ; PC +0
</pre>

The in-code option '$listFormat' switches to .lst format.
