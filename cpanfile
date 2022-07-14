requires 'Plack';
requires 'Module::CPANfile';
requires 'Carton';
requires 'JSON::XS';
requires 'URI::Escape';

on 'develop' => sub {
    requires 'Data::Printer';
};
