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

filegroup(
    name = "crypto_asm",
    srcs = [
        "crypto/aes/aesni-mb-x86_64.s",
        "crypto/aes/aesni-sha1-x86_64.s",
        "crypto/aes/aesni-sha256-x86_64.s",
        "crypto/aes/aesni-x86_64.s",
        "crypto/aes/vpaes-x86_64.s",
        "crypto/bn/rsaz-avx2.s",
        "crypto/bn/rsaz-x86_64.s",
        "crypto/bn/x86_64-gf2m.s",
        "crypto/bn/x86_64-mont.s",
        "crypto/bn/x86_64-mont5.s",
        "crypto/camellia/cmll-x86_64.s",
        "crypto/chacha/chacha-x86_64.s",
        "crypto/ec/ecp_nistz256-x86_64.s",
        "crypto/ec/x25519-x86_64.s",
        "crypto/md5/md5-x86_64.s",
        "crypto/modes/aesni-gcm-x86_64.s",
        "crypto/modes/ghash-x86_64.s",
        "crypto/poly1305/poly1305-x86_64.s",
        "crypto/rc4/rc4-md5-x86_64.s",
        "crypto/rc4/rc4-x86_64.s",
        "crypto/sha/keccak1600-x86_64.s",
        "crypto/sha/sha1-mb-x86_64.s",
        "crypto/sha/sha1-x86_64.s",
        "crypto/sha/sha256-mb-x86_64.s",
        "crypto/sha/sha256-x86_64.s",
        "crypto/sha/sha512-x86_64.s",
        "crypto/whrlpool/wp-x86_64.s",
        "crypto/x86_64cpuid.s",
    ],
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

openssl_local_defines = [
        "OPENSSL_USE_NODELETE",
        "L_ENDIAN",
        "OPENSSL_PIC",
        "OPENSSL_CPUID_OBJ",
        "OPENSSL_IA32_SSE2",
        "OPENSSL_BN_ASM_MONT",
        "OPENSSL_BN_ASM_MONT5",
        "OPENSSL_BN_ASM_GF2m",
        "SHA1_ASM",
        "SHA256_ASM",
        "SHA512_ASM",
        "KECCAK1600_ASM",
        "RC4_ASM",
        "MD5_ASM",
        "AESNI_ASM",
        "VPAES_ASM",
        "GHASH_ASM",
        "ECP_NISTZ256_ASM",
        "X25519_ASM",
        "POLY1305_ASM",
        "NDEBUG",
        "OPENSSLDIR=\"\\\"/usr/local/ssl\\\"\"",
        "ENGINESDIR=\"\\\"/usr/local/lib/engines-1.1\\\"\"",
]

cc_library(
    name = "crypt",
    srcs = [
        "@openssl//:crypto_sources",
        ":crypto_asm",
    ],
    hdrs = [
        "@openssl//:openssl_public_headers",
        ":openssl_conf_headers",
    ],
    local_defines = openssl_local_defines,
    textual_hdrs = [
        "@openssl//:crypto_textual_headers",
    ],

    deps = [
        # "@openssl//:openssl_public_headers",
    ] +
    [
        # "@openssl//:crypto_headers",
        "@openssl//:crypto_modes_header",
        "@openssl//:openssl_public_headers",
        "@openssl//:curve_arch_headers",
        "@openssl//:curve_headers",
    ] +
    [
        ":openssl_conf_headers",
        ":buildinf_headers",
    ]
)

cc_library(
    name = "ssl",
    srcs = [
        "@openssl//:libssl_sources",
    ],
    hdrs = [
        "@openssl//:openssl_public_headers",
    ],
    deps = [
        ":crypt",
    ],
    local_defines = openssl_local_defines,
)