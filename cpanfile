requires 'perl', '5.008001';
requires 'Mojo::Pg';
requires 'Mojolicious';
requires 'Time::HiRes';
requires 'UUID::Tiny';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

