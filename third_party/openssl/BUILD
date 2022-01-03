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
