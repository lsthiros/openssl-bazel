exports_files(
    [
        "crypto/buildinf.h",
        "crypto/x86_64cpuid.s",
    ] + glob(["crypto/**/*.s"]),
    visibility = ["//visibility:public"],
)

cc_library(
    name = "buildinf_headers",
    hdrs = ["crypto/buildinf.h"],
    strip_include_prefix = "crypto",
    visibility = ["//visibility:public"],
)

cc_library(
    name = "openssl_conf_headers",
    hdrs = [
        "include/openssl/opensslconf.h",
        "include/crypto/bn_conf.h",
        "include/crypto/dso_conf.h",
    ],
    includes = [
        "include",
    ],
    visibility = ["//visibility:public"],
)

cc_binary(
    name = "libcrypto.so",
    deps = [
        "@openssl//:openssl_headers",
        "@openssl//:crypto_so-1",
        "@openssl//:crypto_so-2",
        "@openssl//:crypto_so-3",
        "@openssl//:crypto_so-4",
        "@openssl//:crypto_so-5",
    ],
    # linkstatic = False,
    linkshared = True,
    visibility = ["//visibility:public"],
)

cc_library(
    name = "crypt",
    deps = [
        "@openssl//:openssl_headers",
        "@openssl//:crypto_so-1",
        "@openssl//:crypto_so-2",
        "@openssl//:crypto_so-3",
        "@openssl//:crypto_so-4",
        "@openssl//:crypto_so-5",
    ],
    linkstatic = True,
    visibility = ["//visibility:public"],
)
