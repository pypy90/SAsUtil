#!/usr/bin/perl -w

use User::pwent;
use File::stat;
# 这两个模块会重载getpwent()和stat()函数
# 结果是这些函数返回对象而不是简单的列表
# 进而有了以下这些对象属性

use strict;

# ($name, $passwd, $uid, $gid, $quota, $comment, $gcos, $dir, $shell) = getpwent()
while (my $pwent = getpwent()) {
    # 返回一个stat对象
    my $dirinfo = stat($pwent->dir . '/.');
    unless (defined $dirinfo) {
        warn 'Unable to stat ' . $pwent->dir . ": $!\n";
        next;
    }
    warn $pwent->name
        . "'s homedir is not owned by the correct uid ("
        . $dirinfo->uid
        . ' instead '
        . $pwent->uid . ")!\n"
        if ($dirinfo->uid != $pwent->uid);
    warn $pwent->name . "'s homedir is writable!\n"
        if ($dirinfo->mode & 022 and (!$dirinfo->mode & 01000));
}
endpwent();
