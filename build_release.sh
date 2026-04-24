#!/usr/bin/env bash
# Build FENDL 3.2c cross sections, tar each nuclide, and optionally upload
# them to a GitHub release.
#
# Usage (run from repo root):
#   ./build_release.sh              # build + tar only
#   ./build_release.sh 1.0.0        # build + tar + upload to release tag 1.0.0
#   TAG=1.0.0 ./build_release.sh    # same, via env var

set -euo pipefail

TAG="${1:-${TAG:-}}"
OUT_DIR="fendl-3.2c-arrow"
GH_REPO="fusion-neutronics/cross_section_data_fendl_3.2c_arrow"

echo "==> converting FENDL 3.2c neutron + photon data into $OUT_DIR/"
convert-fendl --release 3.2c

tar_arrows () {
  local dir="$1"
  echo "==> tarring arrow files/folders in $dir"
  (
    cd "$dir"
    shopt -s nullglob
    for d in *.arrow; do tar -cf "${d}.tar" "$d"; done
  )
}
tar_arrows "$OUT_DIR/neutron"
tar_arrows "$OUT_DIR/photon"

echo
echo "Done. Artifacts ready under $OUT_DIR/."

if [[ -n "$TAG" ]]; then
  echo
  echo "==> uploading to release $TAG on $GH_REPO"
  shopt -s nullglob
  neutron_tars=("$OUT_DIR"/neutron/*.arrow.tar)
  photon_tars=("$OUT_DIR"/photon/*.arrow.tar)
  shopt -u nullglob
  [[ ${#neutron_tars[@]} -gt 0 ]] && gh release upload "$TAG" "${neutron_tars[@]}" --repo "$GH_REPO" --clobber
  [[ ${#photon_tars[@]}  -gt 0 ]] && gh release upload "$TAG" "${photon_tars[@]}"  --repo "$GH_REPO" --clobber
  [[ -f "$OUT_DIR/index.txt" ]] && gh release upload "$TAG" "$OUT_DIR/index.txt" --repo "$GH_REPO" --clobber
  echo "==> upload complete"
else
  echo
  echo "No TAG given. To upload, re-run with a tag (./build_release.sh <TAG>) or:"
  echo "  export TAG=<your-tag>"
  echo "  gh release upload \$TAG $OUT_DIR/neutron/*.arrow.tar --repo $GH_REPO --clobber"
  echo "  gh release upload \$TAG $OUT_DIR/photon/*.arrow.tar  --repo $GH_REPO --clobber"
  echo "  gh release upload \$TAG $OUT_DIR/index.txt            --repo $GH_REPO --clobber"
fi
