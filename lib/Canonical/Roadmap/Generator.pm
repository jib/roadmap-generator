package Canonical::Roadmap::Generator;

use strict;
use warnings;

use Carp;
use File::Fetch;
use Params::Check   qw[check];
use JSON::Any;
use Data::Dumper;

use base 'Object::Accessor';

sub new {
    my $self = shift;
    my %hash = @_;
    my $obj  = $self->SUPER::new;

    my $tmpl = {
        uri         => { required => 1, allow => qr/\S/ },
        _json       => { default => JSON::Any->new , no_override => 1 },
        _ff         => { default => undef, no_override => 1 },
        _content    => { default => undef, no_override => 1 },        
        _data       => { default => undef, no_override => 1 },        
    };
    
    my $args = check( $tmpl, \%hash ) or croak Params::Check::last_error;
    
    ### create the accessors
    $obj->mk_accessors( keys %$tmpl );
    
    ### set them to the arguments
    while( my($k,$v) = each %$args ) {
        $obj->$k( $v );
    }        
    
    ### get the FF object
    my $ff = File::Fetch->new( uri => $obj->uri ) 
                or croak( File::Fetch->error );
    $obj->_ff( $ff );

    return $obj;
}

sub fetch {
    my $self = shift;

    ### get the json content
    $self->_ff->fetch( to => \my $out ) or croak $self->_ff->error;
    $self->_content( $out );
    
    ### decode it
    return $self->_data( $self->_json->decode( $out ) );
}

sub generate_html {
    my $self = shift;
    my $data = $self->_data || $self->fetch;
    my $href = $data->{'specs'} or croak 'No spec data in '. $self->uri;

    my @html;

    ### letting each generator do it's own loop; not the most
    ### efficient, but cleanest and easiest to implement
    push @html, 
        "<head>",
        $self->_generate_html_js( $href ),
        "</head>";

    push @html, 
        "<body>",
        $self->_generate_html_overview( $href ),
        "</body>";
        
        
    return join $/, '<html>', @html, '</html>';
}

sub _generate_html_js {
    my $self = shift;

    return q[
  <script type="text/javascript" src="jquery-1.4.min.js"></script>
  <script type="text/javascript" src="jquery.tablesorter.min.js"></script>    
    
  <script type="text/javascript">
    // documentation at: http://tablesorter.com/
    
    $(document).ready( function() { 
        // add parser through the tablesorter addParser method 
        $.tablesorter.addParser({ 
            // set a unique id 
            id: 'priority', 
            is: function(s) { 
                // return false so this parser is not auto detected 
                return false; 
            }, 
            format: function(s) { 
                // format your data for normalization 
                return s.toLowerCase()
                    .replace(/essential/,5)
                    .replace(/high/,4)
                    .replace(/medium/,3)
                    .replace(/low/,2)
                    .replace(/undefined/,1)
                    .replace(/not/,0);
 
            }, 
            // set type, either numeric or text 
            type: 'numeric' 
        }); 

        $.tablesorter.addParser({ 
            // set a unique id 
            id: 'completion', 
            is: function(s) { 
                // return false so this parser is not auto detected 
                return false; 
            }, 
            format: function(s) { 
                // format your data for normalization 
                return s.replace(/^(\d+).*/,'\1');
 
            }, 
            // set type, either numeric or text 
            type: 'numeric' 
        }); 
        
        // order they appear on the page
        $("#overview").tablesorter({
            // sort on priority, spec ascending
            sortList: [[3,1],[7,0]],
            headers: { 
                3: { sorter:'priority' },
                //6: { sorter:'completion' },                
            }
        }); 

        //$("#byassignee").tablesorter({
        //    // sort on name, ascending
        //    sortList: [[0,0]] 
        //});

        // with the 'todo/done' and assignee not appearing on every
        // row, this does not lend itself well to sorting
        //$("#byworkitem").tablesorter(); 

    }); 
  </script>
    ];  
}

sub _generate_html_overview {
    my $self = shift;
    my $href = shift;

    my @html = ( q|
          <table id="overview">
        
            <thead><tr>
              <th>Team</th>
              <th>Assignee</th>
              <th>Backup</th>
              <th>Priority</th>
              <th>Complexity</th>
              <th>Milestone</th>          
              <th>Completion</th>                        
              <th>Blueprint</th>
              <th>Status</th>          
            </tr></thead> | );

    while( my($name, $d) = each %$href ) {
        my $comp       = $d->{'completion'} || {};
        my $total      = do { my $x = 0; $x += $_ for values %$comp; $x };
        my $percentage = keys %$comp 
            ? int( 100 * $comp->{'done'} / $total ) .'%'
            : 'Unknown';

        push @html, sprintf q[
        <tr>
          <td>%s</td>
          <td>%s</td>
          <td>%s</td>
          <td>%s</td>      
          <td>%s</td>
          <td>%s</td>
          <td>%s</td>          
          <td><a href='%s'>%s</a></td>
          <td>%s</td>          
        </tr>  
        ], $d->{'team'}         || 'Unassigned',
           $d->{'assignee'}     || 'Unassigned',
           "XXX BACKUP TO BE EXTRACTED",
           $d->{'priority'}     || 0,
           "XXX COMPLEXITY TO BE EXTRACTED",
           $d->{'milestone'}    || 'Unassigned',
           $percentage,
           $d->{'url'},         $d->{'name'},
           $d->{'status'}       || 'Not updated',
        ;
    }
    
    push @html, '</table>';

    return @html
}



1;

__END__

    "server-lucid-apport-hooks": {
      "approver": "jib", 
      "assignee": "zulcss", 
      "completion": {
        "done": 2, 
        "postponed": 0, 
        "todo": 7
      }, 
      "definition": "Approved", 
      "details_url": "http://wiki.ubuntu.com/ServerLucidApportHooks", 
      "drafter": "zulcss", 
      "implementation": "Unknown", 
      "meta": [], 
      "milestone": "lucid-alpha-3", 
      "name": "server-lucid-apport-hooks", 
      "priority": "High", 
      "status": "On track", 
      "team": "canonical-server", 
      "url": "https://blueprints.launchpad.net/ubuntu/+spec/server-lucid-apport-hooks", 
      "work_items": [
        {
          "assignee": "zulcss", 
          "date": "2010-01-23", 
          "description": "(1) Extend apport hook for eucalyptus", 
          "milestone": "lucid-alpha-3", 
          "spec": "server-lucid-apport-hooks", 
          "status": "done"
        }, 
        {
          "assignee": "zulcss", 
          "date": "2010-01-23", 
          "description": "(1) Create apport hook for samba to attach debug info", 
          "milestone": "lucid-alpha-3", 
          "spec": "server-lucid-apport-hooks", 
          "status": "todo"
        }, 
        {
          "assignee": "zulcss", 
          "date": "2010-01-23", 
          "description": "(1) Create apport hook for php5", 
          "milestone": "lucid-alpha-3", 
          "spec": "server-lucid-apport-hooks", 
          "status": "done"
        }, 
        {
          "assignee": "zulcss", 
          "date": "2010-01-23", 
          "description": "(1) Create apport hook for vmbuilder", 
          "milestone": "lucid-alpha-3", 
          "spec": "server-lucid-apport-hooks", 
          "status": "todo"
        }, 
        {
          "assignee": "zulcss", 
          "date": "2010-01-23", 
          "description": "Create apport hook for openssh", 
          "milestone": "lucid-alpha-3", 
          "spec": "server-lucid-apport-hooks", 
          "status": "todo"
        }, 
        {
          "assignee": "zulcss", 
          "date": "2010-01-23", 
          "description": "Create apport hook for dhcp3 (client)", 
          "milestone": "lucid-alpha-3", 
          "spec": "server-lucid-apport-hooks", 
          "status": "todo"
        }, 
        {
          "assignee": "zulcss", 
          "date": "2010-01-23", 
          "description": "Create apport hook for dhcp3 (server)", 
          "milestone": "lucid-alpha-3", 
          "spec": "server-lucid-apport-hooks", 
          "status": "todo"
        }, 
        {
          "assignee": "zulcss", 
          "date": "2010-01-23", 
          "description": "Create apport hook for ntp", 
          "milestone": "lucid-alpha-3", 
          "spec": "server-lucid-apport-hooks", 
          "status": "todo"
        }, 
        {
          "assignee": "zulcss", 
          "date": "2010-01-23", 
          "description": "Create interactive apport hook for samba decision tree", 
          "milestone": "lucid-alpha-3", 
          "spec": "server-lucid-apport-hooks", 
          "status": "todo"
        }
      ]
    }, 
