#
#===============================================================================
#
#         FILE: console.pm
#
#  DESCRIPTION: main class for console
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Sarcophagidae 
# ORGANIZATION: 
#      VERSION: 0.01
#      CREATED: 08.04.2015 14:40:00
#     REVISION: ---
#===============================================================================

package console;

use strict;
use warnings;
 
our $version = '0.01';

sub new{
	my $class = shift;
	my $self = bless({}, $class);
	$self->{'input'} = '';
	$self->{'subs'} = {};
	$self->{'bool_vars'} = {};

	return $self;
}

sub set_input{
	my $self = shift;
	$self->{'input'} = shift;
}
	my $self = shift;
	
sub get_input{
	my $self = shift;
	$self->{'input'};
}

sub input{
	# can be derived
	# by default take data from stdin
	
	my $self = shift;
	my $raw_input='';

	$_ = <STDIN>;
	if (defined){
		chomp;
		$raw_input = $_;
	} else {
		$raw_input = '';
	}
	$self->set_input($raw_input);
}

sub parse_input{
	my $self = shift;
	return '' if ($self->get_input() eq '');
	
	$_ = $self->get_input();
	s/^\s+//;
	s/\s+$//;
	s/\t/ /g;
	s/\s+/ /g;
	
	split / /;	
}

sub set_sub{
	my $self = shift;
	my $sub_link = shift;
	my $sub_name = shift;
	
	unless (defined($sub_link) && (defined($sub_name))){
			return 0;
	} 
	
	$self->{'subs'}->{$sub_name}=$sub_link;
	
	1;
}


sub get_sub{
	my $self = shift;
	my $sub_name = shift;

	unless (defined($sub_name)){	
		return 0;
	}	

	if (exists $self->{'subs'}->{$sub_name}){	
		return $self->{'subs'}->{$sub_name};
	}
	
	0;
}

sub call{
	my $self 		= shift;
	my $sub_name	= shift; 	
	my @params		= ();
	if (scalar @_>0) {
		@params = @_;
	}

	my $sub_link = $self->get_sub($sub_name);
	if ($sub_link == 0) {
		return 0;
	}
	$sub_link->($self, @params);
	return 1;
}

sub set_bool_var {
	my $self 		= shift;
	my $bool_name	= shift; 	
	
    unless (defined($bool_name)){
        return 0;
    }
	
	$self->{'subs'}->{$bool_name} = 1;
	return 1;
}

sub unset_bool_var {
    my $self        = shift;
    my $bool_name   = shift;
    
    unless (defined($bool_name)){
        return 0;
    }
    
    $self->{'subs'}->{$bool_name} = 0;
    return 1;

}

sub get_bool_var {
    my $self        = shift;
    my $bool_name   = shift;

    unless (defined($bool_name)){
        return undef;
    }

    if (exists $self->{'subs'}->{$bool_name}){
        return $self->{'subs'}->{$bool_name};
    } else {
		return undef;
	}
}

sub use_default_command{
	my $self        = shift;
	
	my $exit_sub 	= sub { $self->unset_bool_var('EXIT_FLAG');};

	my $set_sub 	= sub {
			my $self 	  = shift;
			my $bool_name = shift;
			$self->set_bool_var($bool_name);
		};

	my $unset_sub 	= sub {
			my $self 	  = shift;
			my $bool_name = shift;
			$self->unset_bool_var($bool_name);
		};

	my $show_var_sub= sub{
			my $self 	  = shift;
			my $bool_name = shift;

			my $val = $self->get_bool_var($bool_name);
			if (defined $val) {
				if ($val == 1){
					$self->echo("True");
				} else {
					$self->echo("False");
				}
			} else { $self->echo("Variable is not defined");}
		}; 
	my $version_sub = sub {
			my $self 	  = shift;
			$self->echo($self->version);
		};
	
	$self->set_sub($exit_sub,'exit');
	$self->set_sub($show_var_sub,'show');
	$self->set_sub($set_sub,'set');
	$self->set_sub($unset_sub,'unset');
}

sub echo{
	# This function provide printing for console module
	# Its necessary for loging all printing data
	# Need to realise system flag for changing logining style
	# for example binary set: (infile)(invar)(inscreen)
	# default value 0
	# max value 7
	#
	my $self 			= shift;
	my $what_to_print	= shift;
	print $what_to_print."\n";
}

sub main{
	# Minimal main sub
	# may be derived 
	my $self        = shift;

	$self->set_bool_var('EXIT_FLAG');
	while ($self->get_bool_var('EXIT_FLAG')){
		$self->input();	
		$self->call($self->parse_input);
	}
}

1;
