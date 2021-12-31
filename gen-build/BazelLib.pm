use strict;
use warnings;

package BazelLib;

sub new {
    my ($class, $args) = @_;
    my $self = {
        'name' => $args->{'name'},
        'srcs' => $args->{'srcs'},
        'local_defines' => $args->{'local_defines'},
        'includes' => $args->{'includes'},
        'deps' => $args->{'deps'},
    };
    bless $self, $class;
    return $self;
}

sub from_library_group {
    my ($class, $library_group, $name) = @_;
    # New empty array @header_srcs
    my @header_srcs = ();
    # New empty array @srcs
    my @srcs = ();

    # Copy d_flags from library_group to @d_flags
    my @d_flags = @{$library_group->{'d_flags'}};

    foreach my $source_object (@{$library_group->{'objects'}}) {
        my $source_file = $source_object->{'source'};
        # If 'assembler' key is defined on $source_object
        # prepend "@//third_party/openssl:" to $source_file
        if (defined $source_object->{'assembler'}) {
            $source_file = '@//third_party/openssl:' . $source_file;
        }
        foreach my $header_src (@{$source_object->{'header_deps'}}) {
            # A regex detector that matches the external headers
            # These headers start with "include/" and do not need to be added as a source dep
            my $inverse_include_detector = qr/^(?!include\/).+/mp;

            # If $header_src is not already in @header_srcs
            # push $header_src to @header_srcs
            if ((!grep {$_ eq $header_src} @header_srcs) && ($header_src =~ $inverse_include_detector)) {
                push(@header_srcs, $header_src);
            }
        }
        push(@srcs, $source_file);
    }

    # Combine header_srcs and srcs into a single array
    my @srcs_and_headers = (@header_srcs, @srcs);
    # Copy the array at $library_group->{'includes'} to @includes
    my @includes = @{$library_group->{'includes'}};

    return BazelLib->new({
        'name' => $name,
        'srcs' => \@srcs_and_headers,
        'local_defines' => \@d_flags,
        'includes' => \@includes,
        'deps' => [":openssl_headers"],
    });
}

sub to_hash {
    my ($self) = @_;
    return {
        'name' => $self->{'name'},
        'srcs' => $self->{'srcs'},
        'local_defines' => $self->{'local_defines'},
        'includes' => $self->{'includes'},
        'deps' => $self->{'deps'},
    };
}

sub serialize_to_bazel {
    my ($self) = @_;
    my $name = $self->{'name'};
    my $srcs = $self->{'srcs'};
    my $local_defines = $self->{'local_defines'};
    my $includes = $self->{'includes'};

    my $result = "";
    $result .= "cc_library(\n";
    $result .= "    name = \"$name\",\n";

    $result .= "    srcs = [\n";
    for my $src (@$srcs) {
        $result .= "        \"$src\",\n";
    }
    $result .= "    ],\n";

    $result .= "    local_defines = [\n";
    for my $define (@$local_defines) {
        $result .= "        \"$define\",\n";
    }
    $result .= "    ],\n";

    $result .= "    copts = [\n";
    for my $include (@$includes) {
        # if $include is not "."
        if ($include ne ".") {
            $include = "external/openssl/$include";
        }
        $result .= "        \"-I$include\",\n";
    }

    $result .= "    deps = [\n";
    foreach my $dep (@{$self->{'deps'}}) {
        $result .= "        \"$dep\",\n";
    }
    $result .= "    ],\n";
    $result .= ")\n";
    return $result;
}

1;