my %names ;
    
my %names2 = (
    A20 => 1,
    CCD => 1,
    CCO => 1,
    CCS => 1,
    CPL => 1,
    CR0 => 1,
    CR2 => 1,
    CR3 => 1,
    CR4 => 1,
    DPL => 1,
    DR0 => 1,
    DR1 => 1,
    DR2 => 1,
    DR3 => 1,
    DR6 => 1,
    DR7 => 1,
    EAX => 1,
    EBP => 1,
    EBX => 1,
    ECX => 1,
    EDI => 1,
    EDX => 1,
    EFER => 1,
    EFL => 1,
    EIP => 1,
    ESI => 1,
    ESP => 1,
    FER => 1,
    GDT => 1,
    HLT => 1,
    IDT => 1,
    LDT => 1,
    R10 => 1,
    R11 => 1,
    R12 => 1,
    R13 => 1,
    R14 => 1,
    R15 => 1,
    RAX => 1,
    RBP => 1,
    RBX => 1,
    RCX => 1,
    RDI => 1,
    RDX => 1,
    RFL => 1,
    RIP => 1,
    RSI => 1,
    RSP => 1,
    SMM => 1,
    iobase => 1,
    iosize => 1,
    obase => 1,
    osize => 1,
    );

sub rec {
    my $d = shift;
    while ($d =~ /(\w+\s?)=(.+)/g){
	print '\s'. "${1}=(\$hex+)";
	rec($2);
    }
}
my $hex = '[a-f0-9]';

while(<>){
    chomp;
    #print "CHECK INPUT:'$_'\n";
    
    if(/^EAX=($hex+) EBX=($hex+) ECX=($hex+) EDX=($hex+)$/){
    }
    
    elsif(/^([GECSDF])S\s=($hex+)\s($hex+)\s($hex+)\s($hex+)\sDPL=($hex+)\s[CSDEFG]S(16|32)?\s+\[(.+)\]$/){}
    elsif(/^CCS=($hex+)\sCCD=($hex+)\sCCO=(\w+)\s+$/){}
    elsif(/^CR0=($hex+)\sCR2=($hex+)\sCR3=($hex+)\sCR4=($hex+)$/){}
    elsif(/^DR0=($hex+)\sDR1=($hex+)\sDR2=($hex+)\sDR3=($hex+)\s$/){}
    elsif(/^DR6=($hex+)\sDR7=($hex+)$/){}
    elsif(/^EFER=($hex+)/){    }
    elsif(/^EIP=(.+)EFL=(.+)CPL=(.+)II=(.+)A20=(.+)SMM=(.+)HLT=(.+)$/){    }
    elsif(/^ESI=(.+)EDI=(.+)EBP=(.+)ESP=(.+)$/){    }
    elsif(/^LDT=($hex+) ($hex+) ($hex+) ($hex+)$/){}
    elsif(/^LDT=($hex+)\s($hex+)\s($hex+)\s($hex+)\sDPL=($hex+)\sLDT$/){}
    elsif(/^R8\s=($hex+)\sR9\s=($hex+)\sR10=($hex+)\sR11=($hex+)$/){}
    elsif(/^R12=($hex+)\sR13=($hex+)\sR14=($hex+)\sR15=($hex+)/){}
    elsif(/^RAX=($hex+)\sRBX=($hex+)\sRCX=($hex+)\sRDX=($hex+)/){    }
    elsif(/^RIP=($hex+)\sRFL=($hex+)\sCPL=($hex+)\sII=($hex+)\sA20=($hex+)\sSMM=($hex+)\sHLT=($hex+)/) {}
    elsif(/^RSI=($hex+)\sRDI=($hex+)\sRBP=($hex+)\sRSP=($hex+)/){}
    elsif(/^TR\s=($hex+) ($hex+) ($hex+) ($hex+)$/){}
    elsif(/^TR\s=($hex+)\s($hex+)\s($hex+)\s($hex+)\sDPL=($hex+)\s(TSS(32|64))\-(busy|avl)$/){}
    elsif(/^[CSEDFG]S\s=($hex+) ($hex+) ($hex+) ($hex+)$/){ }
    elsif(/^CS\s=($hex+)\s($hex+)\s($hex+)\s($hex+)\sDPL=($hex+)\sCS(64|32)\s(.+)$/){}
    elsif(/^[GI]DT=\s+($hex+) ($hex+)$/){}
    elsif(/^RIP=($hex+)\sRFL=($hex+)\s\[([\-ZACSP]+)\]\sCPL=($hex+)\sII=($hex+)\sA20=($hex+)\sSMM=($hex+)\sHLT=($hex+)$/){}
#    elsif(/^RIP=($hex+)\sRFL=($hex+)\sCPL=($hex+)\sII=($hex+)\sA20=($hex+)\sSMM=($hex+)\sHLT=($hex+)$/){}
    else {
	print "elsif(/";
	while (/^(\w+)\s?=(.+)/g){
	    if (!$names{$1}) {	   
		print "^$1=(\$hex+)";
		rec($2);
	    }
	    $names{$1}++;
	    #my @parts = split('=');
	    #warn join("|",@parts);
	}
	print "\$/){}\n";
	
	die "BAD:'$_'";
    }

    
}
