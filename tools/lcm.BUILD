# -*- python -*-
# This file contains rules for the Bazel build system; see https://bazel.build.

# Based on commit 758822db27e1d023b81f89b3fd2a7ebcdcb24d9c of
# https://github.com/RobotLocomotion/drake/blob/master/tools/workspace/lcm/package.BUILD.bazel

load("@rules_python//python:defs.bzl", "py_library")
load("@//tools:generate_file.bzl", "generate_file")
load("@//tools:generate_export_header.bzl", "generate_export_header")

licenses(["restricted"])

package(default_visibility = ["//visibility:public"])

config_setting(
    name = "linux",
    constraint_values = ["@platforms//os:linux"],
    visibility = ["//visibility:private"],
)

# Generate header to provide ABI export symbols for LCM.
generate_export_header(
    out = "lcm/lcm_export.h",
    lib = "lcm",
    static_define = "LCM_STATIC",
)

# These options are used when building all LCM C/C++ code.
# They do not flow downstream to LCM-using libraries.
LCM_COPTS = [
    "-Wno-all",
    "-Wno-deprecated-declarations",
    "-Wno-format-zero-length",
    "-std=gnu11",
    "-fvisibility=hidden",
]

LCM_PUBLIC_HEADERS = [
    # Public (installed) headers
    "lcm/eventlog.h",
    "lcm/lcm.h",
    "lcm/lcm-cpp.hpp",
    "lcm/lcm-cpp-impl.hpp",
    "lcm/lcm_coretypes.h",
    "lcm/lcm_export.h",  # N.B. This is from generate_export_header above.
    "lcm/lcm_version.h",
]

# The paths within the LCM source archive that make #include statements work.
LCM_PUBLIC_HEADER_INCLUDES = [
    ".",
    # TODO(jwnimmer-tri): The 'lcm' is needed so we can generate lcm_export.h
    # with the correct path and still include it like '#include "lcm_export.h"'
    # from other LCM headers. However, this "pollutes" the include paths of
    # everyone using LCM. Can we do better?
    "lcm",
]

# We only build a shared-library flavor of liblcm.so, because its LGPL-licensed
# and thus should never be linked statically.  Building C++ shared libraries
# in Bazel is not well-supported, but for C code is relatively trivial.  This
# rule creates the runtime artifact -- a loadable shared library with its deps
# linked dynamically.  The `name = "lcm"` rule below provides the compile-time
# artifact that combines the shared library with its headers.
cc_binary(
    name = "liblcm.so",
    srcs = [
        # Sources
        "lcm/eventlog.c",
        "lcm/lcm.c",
        "lcm/lcm_file.c",
        "lcm/lcm_memq.c",
        "lcm/lcm_mpudpm.c",
        "lcm/lcm_tcpq.c",
        "lcm/lcm_udpm.c",
        "lcm/lcmtypes/channel_port_map_update_t.c",
        "lcm/lcmtypes/channel_to_port_t.c",
        "lcm/ringbuffer.c",
        "lcm/udpm_util.c",
        # Private headers
        "lcm/dbg.h",
        "lcm/ioutils.h",
        "lcm/lcm_internal.h",
        "lcm/lcmtypes/channel_port_map_update_t.h",
        "lcm/lcmtypes/channel_to_port_t.h",
        "lcm/ringbuffer.h",
        "lcm/udpm_util.h",
    ] + LCM_PUBLIC_HEADERS,
    copts = LCM_COPTS,
    includes = LCM_PUBLIC_HEADER_INCLUDES,
    linkopts = select({
        ":linux": [
            "-pthread",  # For lcm_(mp)udpm.c.
            "-Wl,-soname,liblcm.so",
        ],
        "@//conditions:default": [],
    }),
    linkshared = 1,
    visibility = ["//visibility:private"],
    deps = ["@glib"],
)

# This is the compile-time target for liblcm.  See above for details.
cc_library(
    name = "lcm",
    srcs = ["liblcm.so"],
    hdrs = LCM_PUBLIC_HEADERS,
    includes = LCM_PUBLIC_HEADER_INCLUDES,
)

cc_binary(
    name = "lcm-logger",
    srcs = [
        "lcm-logger/glib_util.c",
        "lcm-logger/glib_util.h",
        "lcm-logger/lcm_logger.c",
    ],
    copts = LCM_COPTS,
    deps = [
        ":lcm",
        "@glib",
    ],
)

cc_binary(
    name = "lcm-logplayer",
    srcs = ["lcm-logger/lcm_logplayer.c"],
    copts = LCM_COPTS,
    deps = [":lcm"],
)

cc_binary(
    name = "lcm-gen",
    srcs = [
        "lcm/lcm_version.h",
        "lcmgen/emit_c.c",
        "lcmgen/emit_cpp.c",
        "lcmgen/emit_csharp.c",
        "lcmgen/emit_go.c",
        "lcmgen/emit_java.c",
        "lcmgen/emit_lua.c",
        "lcmgen/emit_python.c",
        "lcmgen/getopt.c",
        "lcmgen/getopt.h",
        "lcmgen/lcmgen.c",
        "lcmgen/lcmgen.h",
        "lcmgen/main.c",
        "lcmgen/tokenize.c",
        "lcmgen/tokenize.h",
    ],
    copts = LCM_COPTS,
    includes = ["."],
    deps = [
        "@glib",
    ],
)

cc_binary(
    name = "_lcm.so",
    srcs = [
        "lcm-python/module.c",
        "lcm-python/pyeventlog.c",
        "lcm-python/pylcm.c",
        "lcm-python/pylcm.h",
        "lcm-python/pylcm_subscription.c",
        "lcm-python/pylcm_subscription.h",
        "lcm/dbg.h",
    ],
    copts = LCM_COPTS,
    linkshared = 1,
    linkstatic = 1,
    visibility = ["//visibility:private"],
    deps = [
        ":lcm",
        "@python",
    ],
)

# Downstream users of lcm-python expect to say "import lcm".  However, in the
# sandbox the python package is located at lcm/lcm-python/lcm/__init__.py to
# match the source tree structure of LCM; without any special help the import
# would fail.
#
# Normally we'd add `imports = ["lcm-python"]` to establish a PYTHONPATH at the
# correct subdirectory, and that almost works.  However, because the external
# is named "lcm", Bazel's auto-generated empty "lcm/__init__.py" at the root of
# the sandbox is found first, and prevents the lcm-python subdirectory from
# ever being found.
#
# To repair this, we provide our own init file at the root of the sandbox that
# overrides the Bazel empty default.  Its implementation just delegates to the
# lcm-python init file.
#
# Relatedly, within the upstream __init__.py there is a `from ._lcm import`
# statement that loads the compiled C code for LCM python support.  Even though
# the `./_lcm.so` (the glue) resolves correctly in the sandbox, it needs to
# then load the main library `liblcm.so` to operate.  That happens via its
# RUNPATH, but because the RUNPATH is relative, when the lcm module is loaded
# from the wrong sys.path entry, the RUNPATH no longer works.  To work around
# that, we pre-load the shared library before calling the upstream __init__,
# using python ctypes with the realpath to the shared library.
# generate_file(
#     name = "gen/lcm/__init__.py",
#     content = """
# import ctypes
# import os.path
# ctypes.cdll.LoadLibrary(os.path.realpath(__path__[0] + '/_lcm.so'))
# _filename = __path__[0] + \"/lcm-python/lcm/__init__.py\"
# with open(_filename) as f:
#     _code = compile(f.read(), _filename, 'exec')
#     exec(_code)
# """,
#     visibility = ["//visibility:private"],
# )

generate_file(
    name = "gen/lcm/__init__.py",
    content = """
import ctypes
from pathlib import Path
# The base_dir refers to the base of our package.BUILD.bazel.
_base_dir = Path(__path__[0]).resolve().parent.parent
# Load the native code.
ctypes.cdll.LoadLibrary(_base_dir / '_lcm.so')
# We need to tweak the upstream __init__ before we run it.
_filename = _base_dir / 'lcm-python/lcm/__init__.py'
_text = _filename.read_text(encoding='utf-8')
# Respell where the native code comes from.
_text = _text.replace('from lcm import _lcm', 'import _lcm')
_text = _text.replace('from lcm._lcm import', 'from _lcm import')
exec(compile(_text, _filename, 'exec'))
""",
    visibility = ["//visibility:private"],
)

py_library(
    name = "lcm-python-upstream",
    srcs = ["lcm-python/lcm/__init__.py"],  # Actual code from upstream.
    data = [":_lcm.so"],
    visibility = ["//visibility:private"],
)

py_library(
    name = "lcm-python",
    srcs = ["gen/lcm/__init__.py"],  # Shim, from the genrule above.
    imports = ["gen"],
    deps = [":lcm-python-upstream"],
)

java_library(
    name = "lcm-java",
    srcs = glob(["lcm-java/lcm/**/*.java"]),
    javacopts = [
        # Suppressed until lcm-proj/lcm#159 is fixed.
        "-XepDisableAllChecks",
    ],
    runtime_deps = [
        "@com_jidesoft_jide_oss//jar",
        "@commons_io//jar",
        "@org_apache_xmlgraphics_commons//jar",
    ],
    deps = ["@net_sf_jchart2d//jar"],
)

java_binary(
    name = "lcm-logplayer-gui",
    main_class = "lcm.logging.LogPlayer",
    runtime_deps = [":lcm-java"],
)

java_binary(
    name = "lcm-spy",
    jvm_flags = [
        # These flags are copied from the lcm/lcm-java/lcm-spy.sh.in.
        "-Djava.net.preferIPv4Stack=true",
        "-ea",
    ],
    main_class = "lcm.spy.Spy",
    runtime_deps = [":lcm-java"],
)
