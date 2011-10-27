use inc::Module::Install;

name 'ConcurrentRev';
all_from 'lib/ConcurrentRev.pm';

requires 'parent';
requires 'Attribute::Handlers';
requires 'Coro';
requires 'Devel::GlobalDestruction';
requires 'Devel::Refcount';
requires 'Mo';
requires 'Try::Tiny';

test_requires 'Test::More';
test_requires 'Test::Fatal';

WriteAll;
