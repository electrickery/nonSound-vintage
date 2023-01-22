#!/usr/bin/perl
# 
# p11Disas.pl - a simple octal-text based disassembler for PDP-11 code. V0.1
#               fjkraan@xs4all.nl, 2014-07-01
# usage: perl p11Disas.pl octal-code.txt
#
# supported formats: "aaaaaa / nnnnnn" or "nnnnnn" where aaaaaa is an address,
#                    and "nnnnnn" is an octal opcode. After an initial address
#                    subsequent addresses are calculated. Branch labels have
#                    the format "Laaaaaa".


use strict;

my $debug = 0;

my ($inFile, $addrStr) = @ARGV;
my $instructions = &getInstructions();
my $addr = oct($addrStr);
my $oct_str;

print hex($addr) . "/" . $addr . "/". oct($addr)."\n";

open (INF, "<$inFile") or die "$0: Error opening input file $inFile";

my ($line, $address, $data, $numAddress);
my $lineCount = 0;
my %instrMap = %{&fillInstrMapFromString($instructions)};

#    my ($key, $value);
#    while (($key,$value) = each %instrMap) {
#        print "$key=$value\n";
#    }

$address = '';

while ($line = <INF>) {
    $lineCount++;
    $data = '';
    if ($line =~ m/^\s*$/) { next; }
    if ($line =~ m/^[#;]/) { next; }
    chomp $line;
    
    $data = getOpcode($line);
    if ($debug) {$address = getAddress($line, $address);}

    my ($octOpcode, $asmOpcode, $key, $value); 
    $asmOpcode = "";   
    while (($key,$value) = each %instrMap) {
        $key =~ m/^([0-7]+)/;
        if ($data =~ m/^$1/) {
            $asmOpcode = $value;
        }
    }
    if ($debug) {print "found: ($asmOpcode)  ";}
    my $instrType;
    my ($modeStr1, $mode1, $dir1, $dest1, $modeStr2, $mode2, $dir2, $dest2, $offset);
    my ($operandStr1, $operandStr2);
    if ($asmOpcode =~ m|([A-Z]+)/([A-Z]+)|) {
        $asmOpcode = $1;
        $instrType = $2;
    }
#    print "$address: ";
    if ("$instrType" eq "SOI") {
        $mode1 = substr($data, -2, 1);
        $dest1 = substr($data, -1, 1);
        $operandStr1 = &gramFormatter($mode1, $dest1);
        if ($debug) { print "S "; }
        print $address . " $asmOpcode $operandStr1";
        
    } elsif ("$instrType" eq "DOI") {
        $mode1 = substr($data, -4, 1);
        $dest1 = substr($data, -3, 1);
        $operandStr1 = &operandFormatter($mode1, $dest1);
        $mode2 = substr($data, -2, 1);
        $dest2 = substr($data, -1, 1);
        $operandStr2 = &operandFormatter($mode2, $dest2);
        
        if ($debug) { print "D "; }
        print $address . " $asmOpcode $operandStr1, $operandStr2";
        
    } elsif ("$instrType" eq "BI") {
        my $octStr = substr($data, -4, 4);
        $offset = oct($octStr) & 0xFF;
        $offset = (($offset > 127) ? $offset - 255 : $offset + 1) * 2;
        my $jmpAddr = &toOct(oct($address) + $offset);
        my $jmpStr = substr("00000" . $jmpAddr, -6, 6);
        if ($debug) { print "B "; }
        print $address . " $asmOpcode L$jmpStr     ; PC ". 
            (substr($offset,0,1) ne '-' ? ("+" . $offset) : $offset);
    } elsif ("$instrType" eq "SO") {
        my $octStr = substr($data, -1, 1);
        if ($debug) { print "O "; }
        print $address . " $asmOpcode $octStr";
    } elsif ("$instrType" eq "N") {
        if ($debug) { print "N "; }
        print $address . " $asmOpcode";       
    } else {
        if ($debug) { print "? "; }
        print $address . " $asmOpcode";
    }
    if ($debug) { print oct($address) . "      ($data)";}
    print "\n";
}

close INF;

sub toOct() {
    my ($numAddress) = (@_);
    
    return sprintf("%o", $numAddress);
}

sub fillInstrMap() {
    my ($instructionsFile) = (@_);
    my %instrMap;
    my ($line, $code, $opcode, $instrType);
    open (INSF, "<$instructionsFile") or die "$0: Error opening instructions file file $instructionsFile";
    
    while ($line = <INSF>) {
        chomp $line;
        if ($line =~ m/^\s*$/ or $line =~ m/^#/) { next; }
        $line =~ m/([0-7DRNSX?]+)\s+(.+)/;
        
        if ($1 ne '') {$instrMap{$1} = "$2";}
        
    }
    close INSF;
    
    return \%instrMap;
}

sub fillInstrMapFromString() {
    my ($instructions) = (@_);
    my %instrMap;
    my @lines = split /\n/, $instructions;
    foreach my $line (@lines) {
        chomp $line;
        if ($line =~ m/^\s*$/ or $line =~ m/^#/) { next; }
        $line =~ m/([0-7DRNSX?]+)\s+(.+)/;
        
        if ($1 ne '') {$instrMap{$1} = "$2";}
    }
    
#    my ($key, $value);
#    while (($key,$value) = each %instrMap) {
#        print "  $key = $value\n";
#    }

    return \%instrMap;
}

sub formatOctal() {
    my ($data) = @_;
    
    return substr("00000" . $data, -6,6);
}

sub getOpcode() {
    my ($line) = @_;
    my $data;
    if ($line =~ m|([0-7]+)\s*/\s*([0-7]+)|) {
        $data = $2;
    } elsif ($line =~ m/\s*([0-7]+)\s*/) {
        $data = $1;
    } else {
        return "?data?";
    }
    $data = &formatOctal($data);
    return $data;
}

sub getAddress() {
    my ($line, $oldAddress) = @_;
    my $address;
    if ($line =~ m|([0-7]+)\s*/\s*([0-7]+)|) {
        $address = $1;
    } elsif ($line =~ m/\s*([0-7]+)\s*/) {
        $address = &incrAddress($oldAddress);
    } else {
        print "?address?";
    }
    return &formatOctal($address);
}

sub incrAddress() {
    my ($address) = @_;
    my $newAddress = oct($address) + 2;
    return &toOct($newAddress);
}

sub operandFormatter() {
    my ($mode, $dest) = @_;
    my $operandStr;
    my ($line, $data);
    if ($dest eq 7) {
        $line = <INF>;
        $data = &getOpcode($line);
        $operandStr = &pcamFormatter($mode, $data);
    } else {
        $operandStr = &gramFormatter($mode, $dest);
    }
    return $operandStr;
}

sub gramFormatter() {
    my ($mode, $dest) = @_;
    
    if ($mode == 0) { return "R$dest"; }
    if ($mode == 1) { return "(R$dest)"; }
    if ($mode == 2) { return "(R$dest)+"; }
    if ($mode == 3) { return "\@(R$dest)+"; }
    if ($mode == 4) { return "-(R$dest)"; }
    if ($mode == 5) { return "\@_(R$dest)"; }
    if ($mode == 6) { 
        my $line = <INF>;
        my $data = &getOpcode($line);
        return "$data(R$dest)"; 
    }
    if ($mode == 7) {         
        my $line = <INF>;
        my $data = &getOpcode($line);
        return "\@$data(R$dest)"; 
    }
    return "???";
}

sub pcamFormatter() {
    my ($mode, $dest) = @_;

    if ($mode == 2) { return "#$dest"; }
    if ($mode == 3) { return "\@#$dest"; }
    if ($mode == 6) { return "$dest"; }
    if ($mode == 7) { return "\@$dest"; }
    return "??$mode";    
}

sub getInstructions() {
    return "# http://pages.cpsc.ucalgary.ca/~dsb/PDP11/InsSumm.html & PDP11_Handbook1979.pdf
#octal  opcode/type
000000  HALT/N
000001  WAIT/N
000002  RTI/N
000003  BPT/N
000004  IOT/N
000005  RESET/N
000006  RTT/N
0001DD  JMP/BI
00020R  RTS/BI
00023N  SPL/SO
000240  NOP/N
000241  CLC/N
000242  CLV/N
000244  CLZ/N
000250  CLN/N
000257  CCC/N
000261  SEC/N
000262  SEV/N
000264  SEZ/N
000270  SEN/N
000277  SCC/N
0003DD  SWAB/SOI
0004XX  BR/BI
0005XX  BR/BI
0006XX  BR/BI
0007XX  BR/BI
0010XX  BNE/BI
0011XX  BNE/BI
0012XX  BNE/BI
0013XX  BNE/BI
0014XX  BEQ/BI
0015XX  BEQ/BI
0016XX  BEQ/BI
0017XX  BEQ/BI
0020XX  BGE/BI
0021XX  BGE/BI
0022XX  BGE/BI
0023XX  BGE/BI
0024XX  BLT/BI
0025XX  BLT/BI
0026XX  BLT/BI
0027XX  BLT/BI
0034XX  BLE/BI
0035XX  BLE/BI
0036XX  BLE/BI
0037XX  BLE/BI
004RDD  JSR/BI
0050DD  CLR/SOI
0051DD  COM/SOI
0052DD  INC/SOI
0053DD  DEC/SOI
0054DD  NEG/SOI
0055DD  ADC/SOI
0056DD  SBC/SOI
0057DD  TST/SOI
0060DD  ROR/SOI
0061DD  ROL/SOI
0062DD  ASR/SOI
0063DD  ASL/SOI
006400  MARK/N
0067DD  SXT/SOI
01SSDD  MOV/DOI
02SSDD  CMP/DOI
03SSDD  BIT/DOI
04SSDD  BIC/DOI
05SSDD  BIS/DOI
06SSDD  ADD/DOI
070RSS  MUL/DOI
070RSS  DIV/DOI
072RSS  ASH/DOI
073RSS  ASHC/DOI
074RDD  XOR/DOI
07500R  FADD/F
07501R  FSUB/F
07502R  FMUL/F
07503R  FDIV/F
1000XX  BPL/BI
1001XX  BPL/BI
1002XX  BPL/BI
1003XX  BPL/BI
1004XX  BMI/BI
1005XX  BMI/BI
1006XX  BMI/BI
1007XX  BMI/BI
1010XX  BHI/BI
1011XX  BHI/BI
1012XX  BHI/BI
1013XX  BHI/BI
1014XX  BLOS/BI
1015XX  BLOS/BI
1016XX  BLOS/BI
1017XX  BLOS/BI
1024XX  BVC/BI
1025XX  BVC/BI
1026XX  BVC/BI
1027XX  BVC/BI
1030XX  BCC/BI
1031XX  BCC/BI
1032XX  BCC/BI
1033XX  BCC/BI
1034XX  BCS/BI
1035XX  BCS/BI
1036XX  BCS/BI
1037XX  BCS/BI
104???  EMT-TRAP
1050DD  CLRB/SOI
1051DD  COMB/SOI
1052DD  INCB/SOI
1053DD  DECB/SOI
1054DD  NEGB/SOI
1055DD  ADCB/SOI
1056DD  SBCB/SOI
1057DD  TSTB/SOI
1060DD  RORB/SOI
1061DD  ROLB/SOI
1062DD  ASRB/SOI
1063DD  ASLB/SOI
1067DD  MFPS/SOI
1064SS  MTPS/SOI
11SSDD  MOVB/DOI
12SSDD  CMPB/DOI
13SSDD  BITB/DOI
14SSDD  BICB/DOI
15SSDD  BISB/DOI
16SSDD  SUB/DOI
";
}

# direct & indirect (deferred) addressing modes
# O O  m m @ r r r
# 0 x  0 0 0 x x x   rX      Register
# 1 x  0 0 1 x x x   (rX)    Register deferred
# 2 x  0 1 0 x x x   (rX)+   Autoincrement
# 3 x  0 1 1 x x x   @(rX)+  Autoincrement deferred
# 4 x  1 0 0 x x x   -(rX)   Autodecrement
# 5 x  1 0 1 x x x   @-(rX)  Autodecrement deferred
# 6 x  1 1 0 x x x   X(Rx)   Index
# 7 x  1 1 1 x x x   @X(rX)  Index deferred

# PC addressing modes
# 2 7  0 1 0 1 1 1   #N      Immediate
# 3 7  0 1 1 1 1 1   @#N     Absolute
# 6 7  1 1 0 1 1 1   N       Relative
# 7 7  1 1 1 1 1 1   @N      Relative deferred
