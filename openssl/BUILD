
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
    name = "crypto",
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


cc_binary(
    name = "libssl.so",
    deps = [
        "@openssl//:libssl_so-0",
        "@openssl//:openssl_headers",
        ":libcrypto.so",
    ],
    linkshared = True,
    visibility = ["//visibility:public"],
)

cc_library(
    name = "ssl",
    deps = [
        "@openssl//:libssl_so-0",
        "@openssl//:openssl_headers",
        ":libcrypto.so",
    ],
    visibility = ["//visibility:public"],
)
