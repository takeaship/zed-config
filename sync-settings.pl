use strict;
use warnings;
use File::Temp ();
use FindBin qw($Bin);
use JSON::PP ();

my ($action) = @ARGV;
die "Usage: perl sync-settings.pl Export|Apply\n"
    unless @ARGV == 1 && ($action eq 'Export' || $action eq 'Apply');

my $local_path = "$Bin/settings.json";
my $shared_path = "$Bin/settings.shared.json";
my $json = JSON::PP->new->utf8->relaxed->canonical->pretty
    ->indent_length(2)->space_before(0);

sub read_settings {
    my ($path) = @_;
    open my $file, '<:raw', $path or die "Cannot read $path: $!\n";
    local $/;
    my $contents = readline $file // '';
    close $file or die "Cannot close $path: $!\n";
    $contents =~ s/\A\xEF\xBB\xBF//;
    my $settings = $json->decode($contents);
    die "Expected a JSON object in $path\n" unless ref($settings) eq 'HASH';
    return $settings;
}

my ($settings, $target);
if ($action eq 'Export') {
    $settings = read_settings($local_path);
    delete $settings->{ssh_connections};
    $target = $shared_path;
} else {
    $settings = read_settings($shared_path);
    die "Remove ssh_connections from settings.shared.json before applying.\n"
        if exists $settings->{ssh_connections};
    if (-e $local_path) {
        my $local = read_settings($local_path);
        if (exists $local->{ssh_connections}) {
            $settings->{ssh_connections} = $local->{ssh_connections};
        }
    }
    $target = $local_path;
}

my $contents = $json->encode($settings);
my $temporary = File::Temp->new(
    DIR => $Bin,
    TEMPLATE => '.settings-write-XXXXXXXX',
    SUFFIX => '.tmp',
);
binmode $temporary, ':raw' or die "Cannot set binary mode: $!\n";
print {$temporary} $contents or die "Cannot write temporary settings: $!\n";
close $temporary or die "Cannot close temporary settings: $!\n";
rename $temporary->filename, $target or die "Cannot replace $target: $!\n";
