# -*- python -*-
# This file marks a workspace root for the Bazel build system; see
# https://bazel.build.

workspace(name = "optitrack_driver")

load("//tools:pkg_config.bzl", "pkg_config_repository")
load("//tools:python.bzl", "python_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:java.bzl", "java_import_external")

java_import_external(
    name = "com_jidesoft_jide_oss",
    jar_sha256 = "a2edc2749cf482f6b2b1331f35f0383a1a11c19b1cf6d9a8cf7c69ce4cc8e04b",
    jar_urls = [
        "https://jcenter.bintray.com/com/jidesoft/jide-oss/2.9.7/jide-oss-2.9.7.jar",
        "https://repo1.maven.org/maven2/com/jidesoft/jide-oss/2.9.7/jide-oss-2.9.7.jar",
        "http://maven.ibiblio.org/maven2/com/jidesoft/jide-oss/2.9.7/jide-oss-2.9.7.jar",
    ],
    licenses = ["restricted"],
)

java_import_external(
    name = "commons_io",
    jar_sha256 = "3307319ddc221f1b23e8a1445aef10d2d2308e0ec46977b3f17cbb15c0ef335b",
    jar_urls = [
        "https://jcenter.bintray.com/commons-io/commons-io/1.3.1/commons-io-1.3.1.jar",
        "https://repo1.maven.org/maven2/commons-io/commons-io/1.3.1/commons-io-1.3.1.jar",
        "http://maven.ibiblio.org/maven2/commons-io/commons-io/1.3.1/commons-io-1.3.1.jar",
    ],
    licenses = ["notice"],
)

pkg_config_repository(
    name = "glib",
    modname = "glib-2.0",
    licenses = ["restricted"],
)

http_archive(
    name = "lcm",
    build_file = "//tools:lcm.BUILD",
    sha256 = "8bf90431eacb982cd8a7715ec566f0d94e1dbab849d0a7af1db45b384559935d",
    strip_prefix = "lcm-a059d86deaca39d8c355a02da01b251fb62e3b80",
    urls = ["https://github.com/lcm-proj/lcm/archive/a059d86deaca39d8c355a02da01b251fb62e3b80.tar.gz"],
)

java_import_external(
    name = "net_sf_jchart2d",
    jar_sha256 = "41af674b1bb00d8b89a0649ddaa569df5750911b4e33f89b211ae82e411d16cc",
    jar_urls = [
        "https://jcenter.bintray.com/net/sf/jchart2d/jchart2d/3.3.2/jchart2d-3.3.2.jar",
        "https://repo1.maven.org/maven2/net/sf/jchart2d/jchart2d/3.3.2/jchart2d-3.3.2.jar",
        "http://maven.ibiblio.org/maven2/net/sf/jchart2d/jchart2d/3.3.2/jchart2d-3.3.2.jar",
    ],
    licenses = ["restricted"],
)

java_import_external(
    name = "org_apache_xmlgraphics_commons",
    jar_sha256 = "7ce0c924c84e2710c162ae1c98f5047d64f528268792aba642d4bae5e1de7181",
    jar_urls = [
        "https://jcenter.bintray.com/org/apache/xmlgraphics/xmlgraphics-commons/1.3.1/xmlgraphics-commons-1.3.1.jar",
        "https://repo1.maven.org/maven2/org/apache/xmlgraphics/xmlgraphics-commons/1.3.1/xmlgraphics-commons-1.3.1.jar",
        "http://maven.ibiblio.org/maven2/org/apache/xmlgraphics/xmlgraphics-commons/1.3.1/xmlgraphics-commons-1.3.1.jar",
    ],
    licenses = ["notice"],
)

python_repository(name = "python")

http_archive(
    name = "rules_python",
    url = "https://github.com/bazelbuild/rules_python/releases/download/0.0.1/rules_python-0.0.1.tar.gz",
    sha256 = "aa96a691d3a8177f3215b14b0edc9641787abaaa30363a080165d06ab65e1161",
)

load("@rules_python//python:repositories.bzl", "py_repositories")

py_repositories()
