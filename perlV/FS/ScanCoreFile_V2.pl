#! /usr/bin/perl -s
    eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
        if 0; #$running_under_some_shell

use strict;
use warnings;
use File::Find ();

# Set the variable $File::Find::dont_use_nlink if you're using AFS,
# since AFS cheats.

# 以下几个变量是该模块生成的特定变量：
use vars qw/*name *dir *prune/;
*name   = *File::Find::name; # 当前文件名（全路径）
*dir    = *File::Find::dir;  # 当前目录名
*prune  = *File::Find::prune;# 目录排除

sub wanted;



# 为每个遇到的文件或者目录调用wanted子例程
File::Find::find({wanted => \&wanted}, '.');

my $r;
sub wanted {
    # 排除零字节，是为了避免删除/dev/null软链接
    /^core\z/s && -s $name && print("$name\n") && defined $r && unlink($name);
}

