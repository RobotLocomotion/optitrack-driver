# -*- python -*-

# Based on commit 2d97b78e79ffe0ce6e0df51b729ed91731ff67d1 of
# https://github.com/RobotLocomotion/drake/blob/master/tools/workspace/execute.bzl

def path(repo_ctx, additional_search_paths = []):
    """Return the value of the PATH environment variable that would be used by
    the which() command."""
    search_paths = additional_search_paths

    if repo_ctx.os.name == "mac os x":
        search_paths = search_paths + ["/usr/local/bin"]
    search_paths = search_paths + ["/usr/bin", "/bin"]
    return ":".join(search_paths)

def which(repo_ctx, program, additional_search_paths = []):
    """Return the path of the given program or None if there is no such program
    in the PATH as defined by the path() function above. The value of the
    user's PATH environment variable is ignored.
    """
    exec_result = repo_ctx.execute(["which", program], environment = {
        "PATH": path(repo_ctx, additional_search_paths),
    })
    if exec_result.return_code != 0:
        return None
    return repo_ctx.path(exec_result.stdout.strip())
