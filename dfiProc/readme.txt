This is the readme.txt of the 0.4 version of the DFI-processor.
This tool reads image files produced by the DiscFerret and displays the 
interpreted data on screen. Currently the only output format is JV1,
which is the sector data in the proper order. Only single sided is 
supported in this format. Eventually the output should be written to 
some other diskimage formats like DMK, JV3, D88, IMD, ...
Another extension is data read directly from the DiscFerret.

For now, single and double density are supported. The core-interpreter
supports also MFM, RX02 and M2MFM, but only FM and MFM are tested. Auto detection 
is not working, so mixed density is not supported yet.

Adding more output formats is fairly trival, as the sector data and meta-data is 
collected in a format independent struct first. But more testing and other 
functionality are first priorities.

The output currently prints a histograph for each track, and this can probably 
replace the fixed tresholds currently used.

The main differences between this release and the previous 0.3 are:
- improved logging supporting more levels,
- restructured the code, further reducing the global variables and organizing
  functionality into distinct files,
- the supported output format jv1 is actually tested (and found working).

The core is not programmed by me but from the cw2dmk package by Tim Mann,
http://tim-mann.org/catweasel.html.

THe tool can be started by:
./NetBeansProjects/dfiProcess/dfiProc -d nd80v2_sssd40.dfi -e 1 -v 3 -f test.jv1 -k 5 -i 1


The supported DFI format is version 1.1 (header DFE2). -f is the file name, 
-t the image type. Other options are described in the usage. An attempt is made 
to follow the cw2dmk option convention.

2012-04-09,
Fred Jan Kraan


The cwtool.c files makes a clear distinction between the actual layers catweasel 
or discferret decoding software should have. In the dfiProcess package these
levels are served by these functions:
- L0: catweasel raw counter values
    processed by process_sample(). The resulting values "0" and "1" are passed 
    to process_bit()
- L1: raw bits FM, MFM  
- L2: decoded FM, MFM
    processed by process_bit(). These two layers are combined. The resulting 
    values are put in the track struct to be processed by the output format 
    routine. As the meta-information of the track and sectors is needed for most
    formats, it is stored too.
- L3: sector data bytes only
    processed by jv1Dump(). This one will probably the only one being a true L3
    layer, as most image formats require some form of meta information.

The function of the cwtool program is different from that of cw2dmk in that 
cwtool is there to make the data on the disk available for the user, while 
cw2dmk converts the disk to an image or virtual disk. Making data available to
the user is left to an emulator.

