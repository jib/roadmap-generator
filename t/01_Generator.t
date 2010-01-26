use strict;
use warnings;
use Test::More 'no_plan';
use File::Spec;

BEGIN { chdir 't' if -d 't'; use lib '../lib' }

my $JSON  = File::Spec->rel2abs( File::Spec->catfile( qw[src test.json] ) );

my $Class = 'Canonical::Roadmap::Generator';
use_ok( $Class );

my $CRG;
### object creation
{   $CRG = eval { $Class->new };
    ok( !$CRG,                  "->new requires arguments" );
    like( $@, qr/Required option/i,         
                                "   Missing required option" );
    ok( -e $JSON,               "   JSON file $JSON exists" );
    
    $CRG = $Class->new( uri => 'file://'.$JSON );
    ok( $CRG,                   "Created new $Class object" );
    isa_ok( $CRG, $Class,       "   Object" );
}

### fetching
{   my $href = $CRG->fetch;
    ok( $href,                  "Fetched " . $CRG->uri );
    isa_ok( $href,              'HASH' );
}

### generation
{   my $html = $CRG->generate_html;
    diag $html;
}
