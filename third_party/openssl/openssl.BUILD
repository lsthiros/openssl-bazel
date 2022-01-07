load("@//third_party/openssl:libcrypto_so.bzl", "libcrypto_so")
load("@//third_party/openssl:libssl_so.bzl", "libssl_so")

libcrypto_so()
libssl_so()


cc_library(
    name = "openssl_public_headers",
    hdrs = glob(["include/**/*.h"]),
    includes = [
        "include",
    ],
    visibility = ["//visibility:public"],
)
