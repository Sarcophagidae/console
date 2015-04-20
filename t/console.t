#
#===============================================================================
#
#         FILE: console.t
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 08.04.2015 15:03:59
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 27;  # last test to print


use lib '../';
use_ok('console');

my $cmd = console->new();
isa_ok($cmd,'console');

diag("Input section");

# input testing
open my $stdin, '<', \"test_input\n" or die "cant open STDIN";
local *STDIN = $stdin;
$cmd->input();

# check that input was correct
is($cmd->get_input,		'test_input',	'get_input. Save input correctly');


$stdin = "\cD";
$cmd->input();
is($cmd->get_input,		'',				'input. Testing for Ctrl+D value. Must be ignored');

diag("Subs calling");
# testing set and get subs

# It test sub we will print into variable
my $output_buffer;
open VAR, '>', \$output_buffer;
my $my_anon_func = sub { print VAR "Test sub printing\n"; };
my $my_anon_func_with_params = sub { print VAR $_[1].$_[2].$_[3]; };


is ($cmd->set_sub($my_anon_func),	0,	'set_sub. Dont save incorrect input - wout name');
is ($cmd->set_sub(undef,'ololo'),	0,	'set_sub. Dont save incorrect input - wout sub');
is ($cmd->set_sub(),				0,	'set_sub. Dont save incorrect input - wout all');

is ($cmd->set_sub($my_anon_func, 'print'), 1, 'set_sub. Save correct value');

is ($cmd->get_sub('not_can'), 		0,	'get_sub. Take not exists command');
is ($cmd->get_sub(), 				0,	'get_sub. Take empty command');
isnt ($cmd->get_sub('print'), 		0,	'get_sub. Take saved command');

is ($cmd->call('print'),			1, 	'call. Try to call sub');
is ($output_buffer,					"Test sub printing\n", 'call. Check outputed data');

$cmd->set_sub($my_anon_func_with_params, 'print_param');
$output_buffer = '';
$cmd->call('print_param',1,2,3);
like ($output_buffer,					qr/123/, 'call. Call with params');

diag("Working with var");

is ($cmd->set_bool_var(),			0,	'set_bool_var. No name');
is ($cmd->unset_bool_var(),			0,	'unset_bool_var. No name');
is ($cmd->get_bool_var(),			undef,'get_bool_var. No name');
is ($cmd->get_bool_var('not_exist'),undef,'get_bool_var. Read undefined value');

is ($cmd->set_bool_var('Existence'),1, 	'set_bool_var. Set variable in true');
is ($cmd->get_bool_var('Existence'),1, 	'get_bool_var. Read variable value');
is ($cmd->unset_bool_var('Existence'),1, 	'set_bool_var. Set variable in false');
is ($cmd->get_bool_var('Existence'),0, 	'get_bool_var. Read variable value');

is ($cmd->unset_bool_var('Existence2'),1,'set_bool_var. Check that unset create variable too');
is ($cmd->get_bool_var('Existence2'),0,	'get_bool_var. Check that unset create variable too');

diag("Parse calling");
$cmd->set_input('zeleboba');
is (($cmd->parse_input())[0],			'zeleboba','parse_input. Parsing command without param');

$cmd->set_input("  \t  zeleboba \t   \t ");
is (($cmd->parse_input())[0],			'zeleboba','parse_input. Checking trim function');

$cmd->set_input("  \t  zele\t   bo \t \t  ba \t   \t ");
is (join (' ',$cmd->parse_input()),			'zele bo ba','parse_input. Checking param spliting');





# Finita
