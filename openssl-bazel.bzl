load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def openssl_bazel():
    http_archive(
        name = "openssl",
        urls = ["https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_1_1_1m.tar.gz"],
        sha256 = "36ae24ad7cf0a824d0b76ac08861262e47ec541e5d0f20e6d94bab90b2dab360",
        build_file = "//third_party/openssl:openssl.BUILD",
        strip_prefix = "openssl-OpenSSL_1_1_1m",
    )
