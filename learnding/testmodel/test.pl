use List::MoreUtils;

my @array = qw( Apples Oranges Brains Toes Kiwi);
my $search = "Toes";

my $index = List::MoreUtils::first_index {$_ eq $search} @array;

print "index of $search = $index\n";
