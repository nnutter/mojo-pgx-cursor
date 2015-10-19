requires 'perl', '5.008001';
requires 'Mojo::Pg';
requires 'namespace::clean';
requires 'UUID::Tiny';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

