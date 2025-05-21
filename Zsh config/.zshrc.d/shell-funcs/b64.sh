decodeb64() {
  echo "$1" | base64 --decode
}
encodeb64() {
  echo "$1" | base64
}