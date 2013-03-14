#!/usr/bin/perl

use File::Find;
use File::Basename;
use strict;

my %derivations = (
    '.toc' => '.tex',
    '.o'   => '.c',
);

my %types = (
    'emacs' => 'emacs backup files',
    'tex'   => 'La/Tex executed files',
    'doto'  => 'c sources files compiled',
);


my $targets;
my %baseseen;

# $< 代表执行脚本的用户ID
my $homedir = (getpwuid($<))[7];

chdir $homedir or die "can't enter your home: $!\n";

$| = 1;

print "Scanning.....\n";
find(\&wanted, '.');
print "\ndone.\n";

sub wanted {
    # $_为当前处理的文件，是由File::Find模块定义的
    # 遇到一个目录，则打印一个点来提示
    print '.' if (-d $_);
    return unless -f $_;
    
    # 检查core文件
    $_ eq 'core'
        && ($targets->{core}{$File::Find::name} = (stat(_))[7])
        && return;
        
    # 检查可删除的tex衍生文件
    (/\.dvi$/ || /\.aux$/ || /\.toc$/)
        && OriginalExists($File::Find::name)
        && ($targets->{tex}->{$File::Find::name} = (stat(_))[7])
        && return;
    
    # 检查可删除的.o衍生文件
    /\.o$/
        && OriginalExists($File::Find::name)
        && ($targets->{doto}->{$File::Find::name} = (stat(_))[7])
        && return;
}

sub OriginalExists {
    # fileparse函数接收一个或两个参数，一为路径，二为后缀标识的数组
    # 如果匹配到其中的一个模式，则从这之后，就成为文件的后缀
    my ($name, $path, $suffix) = File::Basename::fileparse($_[0], '\..*');
    
    return 0 unless (defined $derivations{$suffix});
        
    return 1 
        if (defined $baseseen{$path . $name . $derivations{$suffix}});
    
    # 利用hash进行缓存操作
    return 1
        if (-s $name . $derivations{$suffix}
        && ++$baseseen{$path . $name . $derivations{$suffix}});
}

foreach my $path (keys %{$targets->{core}}) {
    print 'Found a core file taking up '
    . BytesToMeg($targets->{core}->{path})
    . 'MB in '
    . File::Basename::dirname($path) . "\n";
}
    
foreach my $kind (sort keys %types) {
    ReportDerivFiles($kind, $types{$kind});
}

sub ReportDerivFiles {
    my ($kind, $messages, $tempsize) = (shift, shift, 0);
    
    return unless exists $targets->{$kind};
    
    print "\nThe following are most likely $messages:\n";
    
    foreach my $path (keys %{$targets->{$kind}}) {
        $tempsize += $targets->{$kind}->{$path};
        $path =~ s#^\./#~/#;
        print "$path ($targets->{$kind}->{$path} bytes)\n";
    }
    print "These files take up " . BytesToMeg($tempsize) . " MB total.\n\n";
}
sub BytesToMeg {
    return sprintf("%.2f", ($_[0] / 1024000));
}
