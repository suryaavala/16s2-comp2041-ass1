#!/usr/bin/perl -w

# written by Surya Avinash Avala, z0596886
# for COMP9041, 16s2, Assignment 1
my $filename = 'temp.txt';
open(my $fh, '+>', $filename)
  or die "Could not open file '$filename' $!";
while ($line = <>){

  if ($line =~ /<STDIN>/) {
    print "import sys\n";
    print $fh $line;
  } elsif ($line =~ /^#!/ && $. == 1) {

      # translate #! line
      #print "1\n";
      print "#!/usr/local/bin/python3.5 -u\n";
  } else {
    print $fh $line;
  }
}

close $fh;
open($fh, '<', $filename)
  or die "Could not open file '$filename' $!";

while ($line = <$fh>) {
   #handling indentation
   if ($line =~ /}/) {
     #ignore closing braces and move on
     next;
   } else {
   #printing indentation
   $line =~ /^(\s*).*$/g;
   $indent = substr $1,0,-1;
   print "$indent";
   $line =~ s/^\s+|\s+$//g;
   #if ($line =~ /Thank/) { print "indent=$indent.\nline=$line.\n";}
   }
   if ($line =~ /^\s*#/ || $line =~ /^\s*$/) {

        # Blank & comment lines can be passed unchanged
        #print "2\n";
        print $line;
    } elsif ($line =~ /^\s*print\s*"(.*)\\n"[\s;]*$/) {
        # Python's print adds a new-line character by default
        # so we need to delete it from the Perl print statement
        $new_line = $1;
        #$line =~ /^(.*)print.*$/g;
        #$indent = substr $1,0,-1;
        if ($new_line =~ /\$/) {
          #if printing a variable then strip $ and ""
          $new_line =~ tr/\$"//d;
          #print "3\n";
          #print "$indent";
          print "print($new_line)\n";
        }
        else {
        #print "4\n";
        #print "$indent";
        print "print(\"$new_line\")\n";
        }
    } elsif ($line =~ /^\s*print\s*(.*)"\\n"[\s;]*$/) {
      #printing variables
      $new_line = $1;
      #$line =~ /^(.*)print.*$/g;
      #$indent = substr $1,0,-1;
      $new_line =~ tr/\$,//d;
      $new_line =~ s/^\s+|\s+$//g;
      #print "$indent";
      print "print($new_line)\n";
    } elsif ($line =~ /^\s*if\s*\((.*)\)\s*{$/) {
      #dealing with if conditions
      $new_line = $1;
      #$line =~ /^(.*)if.*$/g;
      #$indent = substr $1,0,-1;
      $new_line =~ tr/\$//d;
      $new_line =~ s/eq/==/g;
      #print "$indent";
      print "if $new_line:\n";
    } elsif ($line =~ /^\s*while\s*\((.*)\)\s*{$/){
      #dealing with while loops
      $new_line = $1;
      #$line =~ /^(.*)while.*$/g;
      #$indent = substr $1,0,-1;
      $new_line =~ tr/\$//d;
      $new_line =~ s/eq/==/g;
      #print "$indent";
      print "while $new_line:\n";
    } elsif ($line =~ /\$(.*) = <STDIN>;/) {
      #handling <STDIN>
      print "$1 = sys.stdin.readline()\n";
    } elsif ($line =~ /chomp \$(.*);/) {
      #handing chomp
      print "$1 = $1.rstrip()\n";
    } elsif ($line =~ /^last;$/) {
      $line = "break";
      print "$line\n";

    } elsif ($line =~ /^(\$.*);$/) {
      #python variable assignment and variable manipulation
      $new_line = $1;
      $new_line =~ tr/\$//d;
      print "$new_line\n";
    } else {
        # Lines we can't translate are turned into comments
        #$line =~ /^(\s*)/;
        #$indent = substr $1,0,-1;
        #print "$indent";
        print "$line\n";
    }
}

close $fh;
