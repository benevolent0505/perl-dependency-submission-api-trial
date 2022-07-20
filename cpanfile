requires 'Plack';
requires 'Module::CPANfile';
requires 'Carton';
requires 'Carmel';
requires 'JSON::XS';
requires 'URI::Escape';
requires 'Search::Elasticsearch';
requires 'Search::Elasticsearch::Client::2_0';
requires 'IO::Socket::SSL';

on 'develop' => sub {
    requires 'Data::Printer';
};
