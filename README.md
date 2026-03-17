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
pip install "nuclear_data_to_yamc_format>=0.1.3"
pip install --extra-index-url https://shimwell.github.io/wheels openmc
```

### Convert all nuclides

```bash
convert-fendl --release 3.2c
```

This downloads ACE (neutron) and ENDF (photon) files from IAEA if not found locally, then converts all isotopes through NJOY at 6 temperatures. Output goes to `fendl-3.2c-arrow/`.

To convert a single nuclide for testing:

```bash
convert-fendl --release 3.2c --nuclides Fe56
```

### Compress each nuclide and upload to a release

```bash
cd fendl-3.2c-arrow/neutron
for d in *.arrow; do
  tar -cf "${d}.tar" "$d"
done
gh release upload <TAG> *.arrow.tar \
  --repo fusion-neutronics/cross_section_data_fendl_3.2c_arrow \
  --clobber
cd ../..
```

Replace `<TAG>` with the release tag (e.g. `0.0.1`). This uploads each nuclide as a separate uncompressed tar (e.g. `Fe56.arrow.tar`, `U235.arrow.tar`).

### Clean up source files

```bash
rm -rf fendl-3.2c-ace fendl-3.2c-endf fendl-3.2c-download
```
