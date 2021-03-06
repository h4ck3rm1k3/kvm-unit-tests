use strict;
use warnings;
use Data::Dumper;


my %names ;
my $hex = '[a-f0-9]';
my %seen;

sub rec {
    my $d = shift;
    while ($d =~ /(\w+\s?)=(.+)/g){
	print '\s'. "${1}=(\$hex+)";
	rec($2);
    }
}

sub emit {

}

sub start {
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

}

sub data {
    my $hash = shift;
    #print Dumper($hash);
    for my $x (keys %{$hash}){
	#next unless $x =~ /IP/;
	my $new = $hash->{$x} || 0;
	my $old = $names {$x} || 0;
	
	if ($new ne $old){
	    my $t = lc($new . $old);
	    if ($t =~ /^[a-f0-9]+$/) {

		$new =~ s/0x//g;
		$old =~ s/0x//g;
		#my $diff = hex($new) - hex($old);
		#print "Update $x from $old to $new  diff $diff\n";

		#if ($seen{$new}){

		#if (!$seen{"$old$new"}++){
		emit "$x \"$old\" -> \"$new\"\n";
		#}
		#}
		$seen{$new}++;
	    }
	}
	$names {$x}=$new;
    }
}
    
sub proc {
    my %d = @_;
    data(\%d) . "\n";
}

sub proc2 {
    my %d = @_;
    data(\%d) . "\n";
}

sub proc4 {
    #my @d = @_;
    my @args;
    my $name =shift;
    for (1..4) {
	push @args, shift;
    }
    my $name2 = shift;

    my $val2 = shift;
    my $name3 = shift;
    data({	$name => join("",@args),	$name2 => $val2,	$name3 =>shift}) . "\n";
}

sub proc4a {
    #my @d = @_;
    my @args;
    my $name =shift;
    for (1..4) {
	push @args, shift;
    }
    data({	$name => join("",@args) }). "\n";
}

sub proc2a {
    #my @d = @_;
    my @args;
    my $name =shift;
    for (1..2) {
	push @args, shift;
    }
    data({	$name => join("",@args) }). "\n";
}

my %errors;

#print "digraph G {\n";
my $state = 'NORMAL';
for my $filename (@ARGV) {
    open IN,$filename;
    while(<IN>){
    chomp;
    #print "CHECK INPUT:'$_'\n";
    my @d;
    
    if(@d =/^(EAX)=($hex+)\s(EBX)=($hex+)\s(ECX)=($hex+)\s(EDX)=($hex+)$/){	proc @d;    }   
    elsif(@d=/^(DR0)=($hex+)\s(DR1)=($hex+)\s(DR2)=($hex+)\s(DR3)=($hex+)\s$/){	proc @d;    }
    elsif(@d=/^(DR6)=($hex+)\s(DR7)=($hex+)$/){	proc @d;    }
    elsif(@d=/^(EFER)=($hex+)/){   	proc @d;    }
    elsif(@d=/^(EIP)=($hex+)\s(EFL)=($hex+)(?<fake>\s)\[([\-ZOACSP]+)\]\s(CPL)=($hex+)\s(II)=($hex+)\s(A20)=($hex+)\s(SMM)=($hex+)\s(HLT)=($hex+)\s*$/){   	proc @d;    }
    elsif(@d=/^(ESI)=($hex+)\s(EDI)=($hex+)\s(EBP)=($hex+)\s(ESP)=($hex+)\s*$/){   	proc @d;    }
    elsif(@d=/^(R12)=($hex+)\s(R13)=($hex+)\s(R14)=($hex+)\s(R15)=($hex+)/){	proc @d;    }
    elsif(@d=/^(R8)\s=($hex+)\s(R9)\s=($hex+)\s(R10)=($hex+)\s(R11)=($hex+)$/){	proc @d;    }
    elsif(@d=/^(RAX)=($hex+)\s(RBX)=($hex+)\s(RCX)=($hex+)\s(RDX)=($hex+)/){   	proc @d;    }
    elsif(@d=/^(CCS)=($hex+)\s(CCD)=($hex+)\s(CCO)=(\w+)\s+$/){	proc @d;    }
    elsif(@d=/^(CR0)=($hex+)\s(CR2)=($hex+)\s(CR3)=($hex+)\s(CR4)=($hex+)$/){	proc @d;    }
    elsif(@d=/^(RIP)=($hex+)\s(RFL)=($hex+)\s(CPL)=($hex+)\s(II)=($hex+)\s(A20)=($hex+)\s(SMM)=($hex+)\s(HLT)=($hex+)/) {	proc @d;    }
    elsif(@d=/^(RIP)=($hex+)\s(RFL)=($hex+)(\s)\[([\-ZACSP]+)\]\s(CPL)=($hex+)\s(II)=($hex+)\s(A20)=($hex+)\s(SMM)=($hex+)\s(HLT)=($hex+)$/){	proc @d;    }
    elsif(@d=/^(RSI)=($hex+)\s(RDI)=($hex+)\s(RBP)=($hex+)\s(RSP)=($hex+)/){	proc @d;    }  
    elsif(@d=/^([GECSDF]S)\s=($hex+)\s($hex+)\s($hex+)\s($hex+)\sDPL=($hex+)\s([CSDEFG]S(?:16|32)?)?\s+\[(.+)\]$/){	proc4 @d;    }
    elsif(@d=/^(TR)\s=($hex+)\s($hex+)\s($hex+)\s($hex+)\s(DPL)=($hex+)\s(TSS(?:32|64))\-(busy|avl)$/){	proc4 @d;    }
    elsif(@d=/^(CS)\s=($hex+)\s($hex+)\s($hex+)\s($hex+)\s(DPL)=($hex+)\s(CS(?:64|32))\s(.+)$/){	proc4 @d;    }
    elsif(@d=/^(LDT)=($hex+)\s($hex+)\s($hex+)\s($hex+)\s(DPL)=($hex+)\s(LDT)$/){	proc4 @d;    }
    elsif(@d=/^([CSEDFG]S)\s*=($hex+) ($hex+) ($hex+) ($hex+)$/){ 	proc4a @d;    }
    elsif(@d=/^(LDT)=($hex+) ($hex+) ($hex+) ($hex+)$/){	proc4a @d;    }
    elsif(@d=/^(TR)\s=($hex+) ($hex+) ($hex+) ($hex+)$/){	proc4a @d;    }
    elsif(@d=/^([GI]DT)=\s+($hex+) ($hex+)$/){proc2a @d; }
    elsif(/\+ qemu-system-x86_64/) {
	# skip the starting command line from bash
    }
    elsif(@d=/Stopped execution of TB chain before 0x($hex+) \[($hex+)\]\s*(.+)?\s*$/){
	$state = "STOP";
	emit "STrace",join("|",map { $_ || "" }@d),"\n";	
    }
    elsif(@d=/Trace 0x($hex+) \[($hex+)\]\s*(.+)?\s*$/){
	# last is function name
	emit "Trace",join("|",map { $_ || "" }@d),"\n";
	$state = "TRACE";
    }
    elsif(@d=/PROLOGUE:/){	$state = "PROLOGUE";    }
    elsif(@d=/IN:/){	$state = "IN";    }
    elsif(@d=/OP:/){	$state = "OP";    }
    elsif(@d=/OP after optimization and liveness analysis/){	$state = "OP2";    }
    elsif(@d=/OUT:/){	$state = "OUT";    }
    elsif(@d=/CPU Reset/){	$state = "CPU Reset";    }
    
    
    
    elsif(@d=/Linking TBs 0x($hex+) \[($hex+)\] index ($hex+) -> 0x($hex+) \[($hex+)\]/){
	emit "Linking",join("|",@d),"\n";
	$state = "LINK";
    }
    else {	
	#if (!($errors{$_}++)) {
	#print join(" ",@ARGV);
	print "BAD: $filename $state '$_'";
	    start();
	#}
    }   
    }
    close IN;
}
