def libssl():
    native.cc_library(
        name = "test_headers",
        hdrs = native.glob(["include/**/*.h"]) + [
            "@//third_party/openssl:include/openssl/opensslconf.h",
        ],
        includes = [
            "external/openssl/include",
            "third_party/openssl/include",
        ],
    )