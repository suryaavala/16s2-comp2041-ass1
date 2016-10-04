#!/usr/bin/perl -w

# written by Surya Avinash Avala, z0596886
# for COMP9041, 16s2, Assignment 1
my $filename = 'temp.txt';
open(my $fh, '+>', $filename)
  or die "Could not open file '$filename' $!";

#loop1 to loop over lines of perl code
  #then import necessary py libraries
  #store the perl code in temp.txt file which will be processed later
while ($line = <>){

  if ($line =~ /<STDIN>/ || $line =~ /ARGV/) {
    print "import sys\n";
    print $fh $line;
  } elsif ($line =~ /^#!/ && $. == 1) {

      # translate #! line
      print "#!/usr/local/bin/python3.5 -u\n";
  } else {
    print $fh $line;
  }
}

close $fh;
open($fh, '<', $filename)
  or die "Could not open file '$filename' $!";

#loop2 actual processing of perl code after printing import statements
while ($line = <$fh>) {

   if ($line =~ /}/) {
     #ignore closing braces and move on
     next;
   }
   if ($line =~/ARGV/)
   {
     #replacing @ARGV by sys.argv[1:] in line
     $line =~ s/\@ARGV/sys.argv[1:]/g;
   }
   if ($line =~ /join\((.*)\)/) {
     #hndling join
     #replacing join (''.list) by ''.join(list)
     $join_statement = $1;
     $join_statement =~ /('.*')/;
     #character used in joining the list strings
     $join_char = $1;
     $join_statement =~ /'.*', (.*)$/;
     #list of strings to be joined
     $join_list = $1;
     $py_join = $join_char.'.'.'join('.''.$join_list.''.')';
     $line =~ s/join.*\)/$py_join/g;
   }
   #printing indentation for this line
   $line =~ /^(\s*).*$/g;
   $indent = substr $1,0,-1;
   print "$indent";
   $line =~ s/^\s+|\s+$//g;

   #processing blank lines, print, print variable, if, while, foreach, variable manipulation statements, <STDIN> and chomp
   if ($line =~ /^\s*#/ || $line =~ /^\s*$/) {

        # Blank & comment lines can be passed unchanged
        #print "2\n";
        print "$line\n";
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
        } else {
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
    } elsif ($line =~ /^foreach.*$/) {
        #handling foreach loop
        $line =~ /^foreach \$(.*) \(.*/g;
        $loop_var = $1;
        if ($line =~ /\(.*\.\..*\)/) {
            #if looping over a range of numbers
          $line =~ /\((.*)\.\..*\)/;
          $starting = $1;
          $line =~ /\(.*\.\.(.*)\)/;
          $ending = $1+1;
          print "for $loop_var in range($starting, $ending):\n"
        } else {
          #looping over a list
          $line =~ /\((.*)\)/;
          $loop_list = $1;
          print "for $loop_var in ($loop_list):\n"
      }
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
        print "$line\n";
    }
}

close $fh;
