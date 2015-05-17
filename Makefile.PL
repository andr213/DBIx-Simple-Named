

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'DBIx::Simple::Named',
    VERSION_FROM => 'lib/DBIx/Simple/Named.pm', # finds \$VERSION
    AUTHOR       => 'Andrey Yanov (andr213@gmail.com)',
    ABSTRACT     => 'named and numbered placeholders in DB',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                     'DBIx::Simple' => 1.35,
                     'SQL::Tokenizer' => 0.24,
                    },
);
