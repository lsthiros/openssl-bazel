load("@//third_party/openssl:libcrypto_so.bzl", "libcrypto_so")
load("@//third_party/openssl:libssl_so.bzl", "libssl_so")

libcrypto_so()
libssl_so()

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
    name = "openssl_headers",
    hdrs = glob(["include/**/*.h"]) + [
        "@//third_party/openssl:include/openssl/opensslconf.h",
    ],
    local_defines = openssl_local_defines,
    includes = [
        "external/openssl/include",
        "third_party/openssl/include",
    ],
    visibility = ["//visibility:public"],
)
