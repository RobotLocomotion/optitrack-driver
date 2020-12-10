# -*- python -*-

# Based on commit c90e851365abbc000d64f6ba629831c315274149 of
# https://github.com/RobotLocomotion/drake/blob/master/tools/skylark/pathutils.bzl

def basename(path):
    """Return the file name portion of a file path."""
    return path.split("/")[-1]

def dirname(path):
    """Return the directory portion of a file path."""
    if path == "/":
        return "/"

    parts = path.split("/")

    if len(parts) > 1:
        return "/".join(parts[:-1])

    return "."

def join_paths(*args):
    """Join paths without duplicating separators.

    This is roughly equivalent to Python's `os.path.join`.

    Args:
        *args (:obj:`list` of :obj:`str`): Path components to be joined.

    Returns:
        :obj:`str`: The concatenation of the input path components.
    """
    result = ""

    for part in args:
        if part.endswith("/"):
            part = part[-1]

        if part == "" or part == ".":
            continue

        result += part + "/"

    return result[:-1]
