requires 'perl', '5.008001';

requires 'DBIx::Simple', '0';
requires 'SQL::Tokenizer', '0';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

