use strict;
use warnings;
use Test::More;

my %tests = (
    # attribte name     raw attrib. value   expected parsed value
    predefined =>       ['&quot;',          '"'],       # alawys worked
    numeric =>          ['&#65;',           'A'],       # always worked
    numericampersand => ['&#38;',           '&'],       # a regression
    ampA =>             ['&#38;A',          '&A'],      # a corner case
    Aamp =>             ['A&#38;',          'A&'],      # a corner case
    AampBampC =>        ['A&#38;B&#38;C',   'A&B&C'],   # a corner case
);
plan tests => scalar (keys %tests);

my $input = '<?xml version="1.0"?><root';
for my $test (sort keys %tests) {
    $input .= sprintf(" %s='%s'", $test, $tests{$test}->[0]);
}
$input .= '/>';

diag("Parsing $input");
use XML::LibXML::SAX;

XML::LibXML::SAX->new(Handler => 'Handler')->parse_string($input);


package Handler;
sub start_element {
    my ($self, $node) = @_;
    for my $attribute (sort keys %{$node->{Attributes}}) {
        my $name = $node->{Attributes}->{$attribute}->{Name};
        Test::More::is(
            $node->{Attributes}->{$attribute}->{Value},
            $tests{$name}->[1],
            sprintf("%s='%s' attribute", $name, $tests{$name}->[0])
        );
    }
}

