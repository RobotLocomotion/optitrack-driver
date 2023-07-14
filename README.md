# optitrack-driver

This repository contains a python application which translates data
streamed from the Optitrack Motive software (aka NatNet) into LCM
messages.

## To build and run locally:

```
bazel run //src:optitrack_client
```

## To build a wheel:

```
bazel build //wheel
```

Then (within a virtual environment), install the wheel file:

```
pip install bazel-bin/wheel/optitrack_driver-*-py3-none-any.whl
```
