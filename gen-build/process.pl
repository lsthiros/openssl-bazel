#  Copyright 2021 Louie Thiros
# 
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

use warnings;
# TODO (lthiros) Enable strict mode
# use strict;

use JSON;

use YAML::Tiny;
use BazelLib;

use Getopt::Long qw(GetOptions);

# Create source file object with includes, d_flags, and object, and source
sub source_file {
    my $includes = shift;
    my $d_flags = shift;
    my $object = shift;
    my $source = shift;
    my $source_file = {
        'includes' => $includes,
        'd_flags' => $d_flags,
        'object' => $object,
        'source' => $source
    };
    return $source_file;
}

# create a deep copy of a source_file object with the same values
sub copy_source_file {
    my $source_file = shift;
    my $copy = {
        # Copy the includes array from $source_file
        'includes' => [@{$source_file->{'includes'}}],
        'd_flags' => [@{$source_file->{'d_flags'}}],
        'object' => $source_file->{'object'},
        'source' => $source_file->{'source'}
    };

    # if the source file has a 'assembler' key, copy it
    if (exists $source_file->{'assembler'}) {
        $copy->{'assembler'} = {%{$source_file->{'assembler'}}};
    }

    # If the source has a 'header_deps' key, copy it as an array to $copy
    if (exists $source_file->{'header_deps'}) {
        $copy->{'header_deps'} = [@{$source_file->{'header_deps'}}];
    }
    return $copy;
}

sub create_source_file {
    my $d_flag_regex = qr/(?:-D([[:alnum:]_]+(?:=[[:alnum:]_])*))/;
    my $include_regex = qr/(?:-I([[:alnum:]_\-\/\.]+))/;
    my $object_regex = qr/(?:-o\s*([[:alnum:]_\-\/\.]+))/;
    my $source_regex = qr/([[:alnum:]_\-\/\.]+\.[sc])/;

    my $compiler_invocation = shift;
    # set $d_flag to matches of $compiler_invocation on $d_flag_regex
    my @d_flags = $compiler_invocation =~ /$d_flag_regex/g;
    my @includes = $compiler_invocation =~ /$include_regex/g;
    # Sort includes to ensure consistent order
    @includes = sort @includes;
    # Set object to first match of $compiler_invocation on $object_regex
    $compiler_invocation =~ /$object_regex/;
    my $object = $1;
    # If object is undefined, die and print compiler invocation
    if (!defined $object) {
        die "Could not find object file for compiler invocation: $compiler_invocation\n";
    }
    # Set $source to first match of $compiler_invocation on $source_regex
    $compiler_invocation =~ /$source_regex/;
    my $source = $1;
    if (!defined $source) {
        die "Could not find source file for compiler invocation: $compiler_invocation\n";
    }

    # Create source file object with includes, d_flags, and object, and source and place in a result variable
    return source_file(\@includes, \@d_flags, $object, $source);
}

sub first_pass_source_and_lib {
    $raw_build_file = shift;

    open(my $raw_build_fh, '<', "openssl-build.log") or die "Could not open $raw_build_file: $!";
    my $ar_build_matcher = qr/ar r ([[:alnum:]\-_.\/]+\.a)\s+((?:(?:[[:alnum:]\-_.\/]+\.o)\s?)*)/mp;
    my $object_extractor = qr/([[:alnum:]\-_.\/]+\.o)/mp;
    my $compiler_invocation_detector = qr/(?=^gcc)(?=^(?:(?!\.so).)*$).*[[:alnum:]\_\-\/]+\.[sc]/mp;

    my $so_build_matcher = qr/\t-o\s([[:alnum:]\-_.\/]+.so)(?:\.\d)* (?:-\S+\s+)*((?:[[:alnum:]\-_.\/]+.o\s?)*)/mp;

    my $assembler_source_extractor = qr/CC=\"gcc\" .* ([[:alnum:]_\-.\/]+\.pl) elf ([[:alnum:]_\-.\/]+\.s)/mp;

    %libraries = ();
    @sources = ();
    @assembler_sources = ();

    while (my $line = <$raw_build_fh>) {
        if ($line =~ $ar_build_matcher || $line =~ $so_build_matcher) {
            my $library_name = $1;
            my $list_of_objects = $2;
            my @objects = $list_of_objects =~ /$object_extractor/g;
            $libraries{$library_name} = [@objects];
        }
        elsif ($line =~ $compiler_invocation_detector) {
            my $source = create_source_file($line);
            # Add source to sources array
            push(@sources, $source);
        }
        elsif ($line =~ $assembler_source_extractor) {
            my $assembler_source = {
                'generator' => $1,
                'assembler' => $2
            };
            push(@assembler_sources, $assembler_source);
        }
    }

    close $raw_build_fh;
    my $result = {
        'libraries' => \%libraries,
        'sources' => \@sources,
        'assembler_sources' => \@assembler_sources,
    };

    return $result;
}

sub get_header_deps {
    my $source_file = shift;

    my $header_extractor = qr/([[:alnum:]_\-\/\.]+\.h)/;
    $source_file =~ s/\.c$/.d/;
    my $header_deps = [];
    if (-e $source_file) {
        open(my $header_deps_fh, '<', $source_file) or die "Could not open $source_file: $!";
        while (my $line = <$header_deps_fh>) {
            if (my @headers = $line =~ /$header_extractor/g) {
                my @sanitized_headers = ();
                for my $header (@headers) {
                    my $sanitized_header;
                    $sanitized_header = $header =~ s/[[:alnum:]\.\-]+\/\.\.\///rg;
                    push(@sanitized_headers, $sanitized_header);
                }
                push(@$header_deps, @sanitized_headers);
            }
        }
        close $header_deps_fh;
    }
    # Sort header deps
    @$header_deps = sort @$header_deps;
    return $header_deps;
}

sub group_objects_by_include_dirs {
    $objects = shift;
    $include_groups = {};
    foreach my $object (@$objects) {
        # Concatenate object->{'includes'} into a single string
        my $include_key = ' ' . join(' ', @{$object->{'includes'}});
        # If include_key is not in include_groups, create a new array and add it to include_groups
        if (!exists $include_groups->{$include_key}) {
            # Copy the array $object->{'includes'} by value into a new array
            my @includes = @{$object->{'includes'}};
            my @d_flags = @{$object->{'d_flags'}};
            $include_groups->{$include_key} = {includes => \@includes, d_flags => \@d_flags, objects => []};
        }
        push(@{$include_groups->{$include_key}->{'objects'}}, copy_source_file($object));
    }
    # reference to new empty array
    my $result = [];
    # Iterate through include_groups in alphabetical order of keys
    foreach my $include_key (sort keys %$include_groups) {
        # print "include_key \"$include_key\"\n";
        push(@$result, $include_groups->{$include_key});
    }

    return $result;
}

sub second_pass_map_deps {
    my $first_pass_source_and_lib = shift;
    my $libraries = $first_pass_source_and_lib->{'libraries'};
    my $sources = $first_pass_source_and_lib->{'sources'};
    my $assembler_sources = $first_pass_source_and_lib->{'assembler_sources'};

    my %source_index = ();
    for my $source (@$sources) {
        # If 'object' is not in $source, die and print $source
        # If 'object' is undefined, die and print $source
        if (!defined $source->{'object'}) {
            my $pretty_source = JSON->new->pretty->encode($source);
            die "Source file object is undefined: $pretty_source\n";
        }
        my $source_name = $source->{'object'};
        $source_index{$source_name} = $source;
    }

    my %assembler_index = ();
    for my $assembler_source (@$assembler_sources) {
        my $assembler_source_name = $assembler_source->{'assembler'};
        $assembler_index{$assembler_source_name} = $assembler_source;
    }

    my %revised_libraries = ();
    for my $library_name (keys %$libraries) {
        my @objects = @{$libraries->{$library_name}};
        my @revised_objects = ();
        for my $object (@objects) {
            if (exists $source_index{$object}) {
                my $source = $source_index{$object};
                if (exists $assembler_index{$source->{'source'}}) {
                    my $assembler_source = $assembler_index{$source->{'source'}};
                    $source->{'assembler'} = $assembler_source;
                }
                my $header_deps = get_header_deps($source->{'source'});
                $source->{'header_deps'} = $header_deps;
                push(@revised_objects, $source);
            }
        }

        $grouped_objects = group_objects_by_include_dirs(\@revised_objects);
        $revised_libraries{$library_name} = $grouped_objects;
    }

    my $result = {
        'libraries' => \%revised_libraries,
        'sources' => $sources
    };
}

sub library_groups_to_bazel {
    my ($library_groups, $output_dir) = @_;

    for $libname (keys %$library_groups) {
        my $groups = $library_groups->{$libname};
        my $sanitized_libname = $libname;
        $sanitized_libname=~ s/\./_/g;
        open(my $bazel_fh, '>', $output_dir . "/$sanitized_libname.bzl") or die "Could not open file 'openssl_so.bazel' $!";

        print $bazel_fh "def $sanitized_libname():\n";
        my $idx = 0;
        for $group (@$groups) {
            my $bazel_lib = BazelLib->from_library_group($group, "$sanitized_libname-$idx");
            print $bazel_fh $bazel_lib->serialize_to_bazel(4);
            print $bazel_fh "\n";
            $idx += 1;
        }
    }
}


sub main {
    my $raw_build_file = "openssl-build.log";
    my $first_pass_source_and_lib = first_pass_source_and_lib($raw_build_file);
    my $second_pass_map_deps = second_pass_map_deps($first_pass_source_and_lib);
    my $libraries = $second_pass_map_deps->{'libraries'};
    my $sources = $second_pass_map_deps->{'sources'};

    my $result = {
        'libraries' => $libraries,
        'sources' => $sources
    };

    # With GetOptions, get the "output_directory" option if it exists
    my $output_directory = ".";
    GetOptions(
        'output_directory=s' => \$output_directory
    );

    # Find library dependencies for "libcrypto.so" and "libssl.so" and "libcrypto.a" and "libssl.a"
    my $libcrypto_so = $libraries->{'libcrypto.so'};
    my $libssl_so = $libraries->{'libssl.so'};
    my $libcrypto_a = $libraries->{'libcrypto.a'};
    my $libssl_a = $libraries->{'libssl.a'};
    
    my $final_result = {
        'libcrypto.so' => $libcrypto_so,
        'libssl.so' => $libssl_so,
        'libcrypto.a' => $libcrypto_a,
        'libssl.a' => $libssl_a,
    };

    library_groups_to_bazel($final_result, $output_directory);
}

main();