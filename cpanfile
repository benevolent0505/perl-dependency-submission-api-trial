requires 'Plack';
requires 'Module::CPANfile';
requires 'Carton';
requires 'JSON::XS';

on 'develop' => sub {
    requires 'Data::Printer';
};
