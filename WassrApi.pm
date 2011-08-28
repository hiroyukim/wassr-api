package WassrApi;
use strict;
use LWP::UserAgent;
use JSON;
use YAML::Syck;
use FindBin;
use Path::Class;
use Carp ();
use Exporter qw(import);

our @EXPORT = qw(
    user_timeline     
    friends_timeline
    replies
    followers
);

my $CONFIG ||= do {
    local $YAML::Syck::ImplicitUnicode = 1;
    my $data = YAML::Syck::LoadFile(file( $FindBin::Bin , 'config.yaml')->stringify);

    unless( $data->{user_name} ) {
        Carp::croak('please user_name.');        
    }

    unless( $data->{passwd} ) {
        Carp::croak('please passwd.');        
    }

    unless( $data->{agent} ) {
        $data->{agent} = 'wassr-bot/0.1';
    }

    $data->{api_host} = 'api.wassr.jp';

    $data;
};

sub __ua {
    my $ua  = LWP::UserAgent->new(
        agent => $CONFIG->{agent},
    );
    $ua->credentials(
        'api.wassr.jp:80', 'API Authentication',
        $CONFIG->{user_name}, $CONFIG->{passwd},
    );

    return $ua;
}

sub _post {
    my $url = shift;
    my $ua  = __ua;

    my $res = $ua->post($url); 
    
    $res->is_success ? $res->decoded_content : undef;
}

sub _get {
    my $path  = shift;
    my $query = shift||{};
    my $ua   = __ua;

    my $uri = URI->new("http://@{[$CONFIG->{api_host}]}");
    $uri->path($path);
    $uri->query_form($query); 

    my $res = $ua->get($uri->as_string); 
warn $res->decoded_content;
    my $content = decode_json( $res->is_success ? $res->decoded_content : undef );

    if( ref $content eq 'ARRAY' ) {
        return wantarray ? @{$content} : $content;
    }
    else { 
        return $content; 
    }
}

sub user_timeline {
    my $id   = shift or Carp::croak('need ! id(user_name)');
    my $page = shift || 1;

    return _get( '/statuses/user_timeline.json' => {
        id   => $id,
        page => $page,
    });
} 

sub friends_timeline   { 
    my $id   = shift or Carp::croak('need ! id(user_name)');
    
    return _get( '/statuses/friends_timeline.json' => {
        id   => $id,
    });
}

sub replies { 
    return _get('/statuses/replies.json');
}

sub followers {
    return _get('/statuses/followers.json');
}

1;
