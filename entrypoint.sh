#!/bin/bash
set -e -x

arch=$(uname -m)

# CLI arguments
PY_VERSIONS=$1
BUILD_REQUIREMENTS=$2
SYSTEM_PACKAGES=$3
PRE_BUILD_COMMAND=$4
BUILD_EXECUTABLE=$5
BUILD_COMMAND=$6
PREBUILD_PATH=$7
PACKAGE_PATH=$8

# Temporary workaround for LD_LIBRARY_PATH issue. See
# https://github.com/RalfG/python-wheels-manylinux-build/issues/26
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib

if [ ! -z "$SYSTEM_PACKAGES" ]; then
    yum install -y ${SYSTEM_PACKAGES}  || { echo "Installing yum package(s) failed."; exit 1; }
fi

if [ ! -z "$PRE_BUILD_COMMAND" ]; then
    cd /github/workspace/"$PREBUILD_PATH"
    $PRE_BUILD_COMMAND || { echo "Pre-build command failed."; exit 1; }
fi

cd /github/workspace/"${PACKAGE_PATH}"

# pre-cleanup
rm -rf *.egg-info
find -noleaf -name "*.py[co]" -delete

# Compile wheels
arrPY_VERSIONS=(${PY_VERSIONS// / })
for PY_VER in "${arrPY_VERSIONS[@]}"; do
    echo "Python ${PY_VER} ${arch}:"
    python_bin="/opt/python/${PY_VER}/bin"
    pip="$python_bin/pip"

    # Prepare base python
    "$pip" install -U --disable-pip-version-check pip setuptools auditwheel

    # Check if requirements were passed
    if [ ! -z "$BUILD_REQUIREMENTS" ]; then
        "$pip" install --no-cache-dir --disable-pip-version-check ${BUILD_REQUIREMENTS} || { echo "Installing requirements failed."; exit 1; }
    fi

    # Check if environment consistent
    "$pip" check --no-input --disable-pip-version-check

    # Build wheels
    "$python_bin/$BUILD_EXECUTABLE" $BUILD_COMMAND || { echo "Building wheels failed."; exit 1; }
done

# Bundle external shared libraries into the wheels
# find -exec does not preserve failed exit codes, so use an output file for failures
failed_wheels=$PWD/failed-wheels
rm -f "$failed_wheels"
find . -type f -iname "*-linux*.whl" -exec sh -c "auditwheel repair '{}' -w \$(dirname '{}') --plat '${PLAT}' || { echo 'Repairing wheels failed.'; auditwheel show '{}' >> "$failed_wheels"; }" \;

if [[ -f "$failed_wheels" ]]; then
    echo "Repairing wheels failed:"
    cat failed-wheels
    exit 1
fi

# Cleanup
rm -rf .eggs
rm -rf build
rm -rf *.egg-info
# Clean caches and cythonized
find -noleaf -name "*.py[co]" -delete

echo "Succesfully build wheels:"
find . -type f -iname "*-manylinux*.whl"
