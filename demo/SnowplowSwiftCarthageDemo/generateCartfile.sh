parent="$(cd ../../../; pwd)"
branch="$(cd ../../../; git rev-parse --abbrev-ref HEAD)"

cat >./Cartfile <<EOF
git "file://${parent}" "${branch}"
EOF
