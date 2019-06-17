# -*- python -*-

# Based on commit 3460b1718f2f2b8c4190b9181cefc0965dae5276 of
# https://github.com/RobotLocomotion/drake/blob/master/tools/workspace/os.bzl

"""A collection of OS-related utilities intended for use in repository rules,
i.e., rules used by WORKSPACE files, not BUILD files.
"""

load("//tools:execute.bzl", "which")

def exec_using_which(repository_ctx, command):
    """Run the given command (a list), using the which() function in
    execute.bzl to locate the executable named by the zeroth index of
    `command`.

    Return struct with attributes:
    - error (None when success, or else str message)
    - stdout (str command output, possibly empty)
    """

    # Find the executable.
    fullpath = which(repository_ctx, command[0])
    if fullpath == None:
        return struct(
            stdout = "",
            error = "could not find which '%s'" % command[0],
        )

    # Run the executable.
    result = repository_ctx.execute([fullpath] + command[1:])
    if result.return_code != 0:
        error = "error %d running %r (command %r, stdout %r, stderr %r)" % (
            result.return_code,
            command[0],
            command,
            result.stdout,
            result.stderr,
        )
        return struct(stdout = result.stdout, error = error)

    # Success.
    return struct(stdout = result.stdout, error = None)

def _make_result(
        error = None,
        ubuntu_release = None,
        macos_release = None):
    """Return a fully-populated struct result for determine_os, below."""
    if ubuntu_release != None:
        distribution = "ubuntu"
    elif macos_release != None:
        distribution = "macos"
    else:
        distribution = None
    return struct(
        error = error,
        distribution = distribution,
        is_macos = (macos_release != None),
        is_ubuntu = (ubuntu_release != None),
        ubuntu_release = ubuntu_release,
        macos_release = macos_release,
    )

def _determine_linux(repository_ctx):
    """Handle determine_os on Linux."""

    # Shared error message text across different failure cases.
    error_prologue = "could not determine Linux distribution: "

    # Run sed to determine Linux NAME and VERSION_ID.
    sed = exec_using_which(repository_ctx, [
        "sed",
        "-n",
        "/^\(NAME\|VERSION_ID\)=/{s/[^=]*=//;s/\"//g;p}",
        "/etc/os-release",
    ])
    if sed.error != None:
        return _make_result(error = error_prologue + sed.error)

    # Compute an identifying string, in the form of "$NAME $VERSION_ID".
    lines = [line.strip() for line in sed.stdout.strip().split("\n")]
    distro = " ".join([x for x in lines if len(x) > 0])

    # Match supported Ubuntu release(s). These should match those listed in
    # both doc/developers.rst the root CMakeLists.txt.
    for ubuntu_release in ["16.04", "18.04"]:
        if distro == "Ubuntu " + ubuntu_release:
            return _make_result(ubuntu_release = ubuntu_release)

    # Nothing matched.
    return _make_result(
        error = error_prologue + "unsupported distribution '%s'" % distro,
    )

def _determine_macos(repository_ctx):
    """Handle determine_os on macOS."""

    # Shared error message text across different failure cases.
    error_prologue = "could not determine macOS version: "

    # Run sw_vers to determine macOS version.
    sw_vers = exec_using_which(repository_ctx, [
        "sw_vers",
        "-productVersion",
    ])
    if sw_vers.error != None:
        return _make_result(error = error_prologue + sw_vers.error)

    major_minor_versions = sw_vers.stdout.strip().split(".")[:2]
    macos_release = ".".join(major_minor_versions)

    # Match supported macOS release(s).
    if macos_release in ["10.13", "10.14"]:
        return _make_result(macos_release = macos_release)

    # Nothing matched.
    return _make_result(
        error = error_prologue + "unsupported macOS '%s'" % macos_release,
    )

def determine_os(repository_ctx):
    """
    A repository_rule helper function that determines which of the supported OS
    versions we are targeting.

    Argument:
        repository_ctx: The context passed to the repository_rule calling this.

    Result:
        a struct, with attributes:
        - error: str iff any error occurred, else None
        - distribution: str either "ubuntu" or "macos" if no error
        - is_macos: True iff on a supported macOS release, else False
        - macos_release: str like "10.14" iff on a supported macOS, else None
        - is_ubuntu: True iff on a supported Ubuntu version, else False
        - ubuntu_release: str like "16.04" iff on a supported ubuntu, else None
    """

    os_name = repository_ctx.os.name
    if os_name == "mac os x":
        return _determine_macos(repository_ctx)
    elif os_name == "linux":
        return _determine_linux(repository_ctx)
    else:
        return _make_result(error = "unknown or unsupported OS '%s'" % os_name)
