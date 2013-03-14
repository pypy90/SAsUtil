#!/usr/bin/perl

use File::Find::Rule;

my @all = File::Find::Rule
    ->file()
    ->name('*.pl')
    ->executable()
    ->uid(0,0)
    ->size('<1M')
    ->in('.');


print "$_ " for @all;

my $rule = File::Find::Rule->new();

# 相当于是一个对象调用类中的各种静态方法
my @files = $rule->any(File::Find::Rule->file(),
                File::Find::Rule->name('*.pl'),
                File::Find::Rule->executable(),
                File::Find::Rule->uid(0,0),
                File::Find::Rule->size('<1M'),
                )
            # in()是较为特殊的方法,并不是判断条件
            ->in('.');

print "$_ " for @files;
