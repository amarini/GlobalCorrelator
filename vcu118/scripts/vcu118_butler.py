import os, time, sys
import uhal

uhal.setLogLevelTo( uhal.LogLevel.WARNING )
manager = uhal.ConnectionManager("file://%s/etc/mp7/connections-test.xml" % os.environ['MP7_TESTS'])

from optparse import OptionParser
parser = OptionParser("usage: %prog command card_id [ options ]")
parser.add_option("--inject", dest="inject", help="source of data to inject", metavar="URI")
parser.add_option("--outputpath", dest="outputpath", help="output directory to save capture data", metavar="DIR", default=".")
parser.add_option("--clksrc", dest="clksrc", help="source of clock (dummy option for the moment, for mp7butler compatibility)", metavar="")
parser.add_option("-e", "--enablechans", dest="enablechans", help="list of channels", default="0-76", metavar="C0-CN")
parser.add_option("--hard", dest="hardrst", help="do a hard reset", action="store_true", default=False)
parser.add_option("-N", "--nframes", dest="nframes", help="number of frames to capture", default=1024, type="int")
parser.add_option("-F", "--firstframe", dest="firstframe", help="first frame to capture", default=0, type="int")

(options, args) = parser.parse_args()


if len(args) <= 1:
    parser.print_help()
    print """
Example for an inject & capture workflow: 
    vcu118_butler.py connect card_id 
    vcu118_butler.py reset card_id [ --clksrc=internal ]
    vcu118_butler.py xbuffers card_id rx PlayOnce --inject file://path/to/rx_file.txt
    vcu118_butler.py xbuffers card_id tx Capture
    vcu118_butler.py capture card_id --outputpath=[target directory]
"""
    exit()


command, device = args[0], args[1]
cmdargs = args[2:]
hw = manager.getDevice(args[1])

MAX_QUADS=19

c0,cn = map(int,options.enablechans.split("-"))
selchans = range(c0,cn+1) 
selquads = [ q for q in xrange(MAX_QUADS) if (4*q <= cn and 4*q+3 >= c0) ]

def loadPatterns(filename):
    patterns = []
    for line in open(filename, "r"):
        if not line.startswith("Frame"): continue
        fields = line.strip().split()
        frameno = int(fields[1])
        fdata = []
        for x in fields[3:(3+cn-c0+1)]:
            (valid,word) = x.split("v")
            fdata.append((int(valid), int(word,16)))
        if patterns:
            if patterns[-1][0] != frameno-1:
                print "Error, non-consecutive patterns in %s at frame %s!" % (txt, frameno)
                exit(2)
            if len(patterns[-1][1]) != len(fdata):
                print "Error, column mismatch in %s at frame %s!" % (txt, frameno)
                exit(2)
        patterns.append((frameno,fdata))
    return patterns
def printPatterns(patterns,out):
    for frameno, data in patterns:
        out.write("Frame %04d :" % frameno)
        for valid, word in data:
            out.write(" %1dv%08x" % (valid, word))
        out.write("\n")

def patterns2buffers(patterns):
    buffs = [[] for d in patterns[0][1]]
    for frameno, data in patterns:
        for i,(valid, word) in enumerate(data):
            buffs[i].append(word & 0xffff)
            buffs[i].append(((word >> 16) & 0xffff) + (valid << 16))
    return buffs
def buffers2patterns(buffers,frame0):
    patterns = []
    for i in xrange(len(buffers[0])/2):
        frameno = frame0 + i
        fdata = []
        for b in buffers:
            lo, hi = b[2*i:2*i+2]
            valid = (1 if (hi & 0x10000) else 0)
            word  = (lo & 0xffff) + ((hi & 0xffff) << 16)
            fdata.append((valid,word))
        patterns.append((frameno,fdata))
    return patterns
            
if command in ("connect", "reset"):
    print "Connecting ....",

    reg = hw.getNode("system").getNode("infra").getNode("stat_reg")
    val = reg.read()
    hw.dispatch()

    print "Status register = ", hex(val)

    if command == "reset":

        print "Issuing reset statement"
        reg = hw.getNode("system").getNode("infra").getNode("ctrl_reg")
        val = reg.write(0x80000000 if options.hardrst else 0x40000000)
        hw.dispatch()

        print "Waiting: ",
        for i in xrange(15 if options.hardrst else 3):
            print ".",

        print "\nRe-connecting ....",
        reg = hw.getNode("system").getNode("infra").getNode("stat_reg")
        val = reg.read()
        hw.dispatch()

        print "done. Status register = ", hex(val)

elif command == "xbuffers":
    if len(cmdargs) != 2: 
        print "xbuffers requires two arguments"
        exit(1)
    if cmdargs[0] == "rx":
        if cmdargs[1] not in ("Play","PlayOnce"): 
            print "vcu118_butler can only configure the rx channel to play injected patterns for now (using Play or PlayOnce)"
            exit(1)
        if not options.inject or not options.inject.startswith("file://"):
            print "Missing patterns to inject, or not a file:// uri"
            exit(1)
        patterns = loadPatterns(options.inject.replace("file://",""))
        buffers = patterns2buffers(patterns)
        firstframe = patterns[0][0]
        dtop = hw.getNode("system").getNode("data")
        for q in selquads:
            quadnode = dtop.getNode("quad%02X" % q)
            for c in xrange(4):
                if 4*q+c not in selchans: continue
                rxbuff = quadnode.getNode("buffers").getNode("rx%1d" % c)
                buff_a = rxbuff.getNode("addr")
                buff_d = rxbuff.getNode("data")
                buff_a.write(2*firstframe)
                buff_d.writeBlock(buffers[4*q+c-c0])
                hw.dispatch()
                print "debug: writing %d ipbus words into channel %d starting at offset %d" % (len(buffers[4*q+c-c0]),4*q+c,2*firstframe)
            regval = 0
            for c in xrange(4):
                if 4*q+c not in selchans: continue
                regval += 2**(2*c)
            ctrlreg  = quadnode.getNode("ctrl").getNode("ctrl_reg")
            ctrlreg.write(regval)
            print "debug: ctrlreg of quad %d is set to %04x" % (q,regval)
            hw.dispatch()
    elif cmdargs[0] == "tx":
        if cmdargs[1] not in ("Capture",): 
            print "vcu118_butler can only configure the tx channel to capture for now (using Capture)"
            exit(1)
        dtop = hw.getNode("system").getNode("data")
        for q in selquads:
            regval = 0
            for c in xrange(4):
                if 4*q+c not in selchans: continue
                regval += 2**(2*c) + 2**(2*c+1)
                print "debug: enable channel %d (quad %d, ch %d)" % (4*q+c,q,c)
            ctrlreg  = dtop.getNode("quad%02X" % q).getNode("ctrl").getNode("ctrl_reg")
            ctrlreg.write(regval)
            print "debug: ctrlreg of quad %d is set to %04x" % (q,regval)
            hw.dispatch()
    else:
        print "first argument of xbuffers must be tx or rx"
        exit(1)

elif command == "capture":
    dtop = hw.getNode("system").getNode("data")
    if not os.path.isdir(options.outputpath):
        os.system("mkdir "+options.outputpath)
    for kind in "rx", "tx":
        buffers = []
        for q in selquads:
            quadnode = dtop.getNode("quad%02X" % q)
            ctrlreg  = quadnode.getNode("ctrl").getNode("ctrl_reg")
            ctrlval = ctrlreg.read()
            hw.dispatch()
            ctrlval = int(ctrlval)
            for c in xrange(4):
                if 4*q+c not in selchans: continue
                if ctrlval & (2**(2*c+1)) == 0:
                    #print "debug: channel %d has capture flag 0, will not capture" % (4*q+c)
                    continue
                buff = quadnode.getNode("buffers").getNode("%s%1d" % (kind,c))
                buff_a = buff.getNode("addr")
                buff_d = buff.getNode("data")
                buff_a.write(2*options.firstframe)
                data = buff_d.readBlock(2*options.nframes)
                hw.dispatch()
                print "debug: reading %d ipbus words from %s channel %d starting at offset %d" % (2*options.nframes,kind,4*q+c,2*options.firstframe)
                buffers.append([v for v in data])
        patterns = buffers2patterns(buffers,options.firstframe)
        fname = "%s/%s_summary.txt" % (options.outputpath,kind)
        fout = open(fname, "w")
        printPatterns(patterns, fout)
        print "Wrote %d %s patterns to %s" % (len(patterns), kind, fname)
