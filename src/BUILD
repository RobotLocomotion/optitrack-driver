# -*- python -*-
# This file contains rules for Bazel; see drake/doc/bazel.rst.

package(default_visibility = ["//visibility:public"])

# Used by drake //:install target.
py_library(
    name = "optitrack_client_py",
    srcs = ["optitrack_client.py"],
    deps = ["@lcm//:lcm-python",
            "//lcmtypes:py_optitrack_lcmtypes"],
)

py_binary(
    name = "optitrack_client",
    srcs = [":optitrack_client_py"],
    deps = [":optitrack_client_py"],
)
