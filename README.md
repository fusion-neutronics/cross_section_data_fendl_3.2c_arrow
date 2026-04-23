# FENDL 3.2c Cross Section Data (Arrow format)

Pre-built FENDL 3.2c nuclear cross section data in Apache Arrow IPC format, converted using [nuclear_data_to_yamc_format](https://github.com/fusion-neutronics/nuclear_data_to_yamc_format).

## Download

Grab the latest release artifact from the [Releases](https://github.com/fusion-neutronics/cross_section_data_fendl_3.2c_arrow/releases) page.

## Building locally

### Prerequisites

- Python 3.9+
- NJOY2016 on PATH (`njoy` binary)
- OpenMC Python package

### Install system packages

```bash
sudo apt-get install -y cmake gfortran git gh
```

### Build and install NJOY2016

```bash
git clone https://github.com/njoy/NJOY2016.git
cd NJOY2016 && mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)
sudo cp njoy /usr/local/bin/
cd ../..
```

### Install Python dependencies

```bash
pip install nuclear_data_to_yamc_format
pip install --extra-index-url https://shimwell.github.io/wheels openmc
```

### Build and (optionally) upload

From the repo root:

```bash
./build_release.sh            # build cross sections and tar each nuclide
./build_release.sh 1.0.0      # same, then upload every .arrow.tar to release tag 1.0.0
TAG=1.0.0 ./build_release.sh  # same as above, via env var
```

Without a tag the script stops after producing the `.arrow.tar` files (under `fendl-3.2c-arrow/neutron/` and `fendl-3.2c-arrow/photon/`) so you can upload manually. With a tag it runs `gh release upload ... --clobber` for you.

To convert a single nuclide for testing:

```bash
convert-fendl --release 3.2c --nuclides Fe56
```

### Clean up source files

```bash
rm -rf fendl-3.2c-ace fendl-3.2c-endf fendl-3.2c-download
```
