alias nowrfc="date -u +\"%Y-%m-%dT%H:%M:%S+07:00\""


# Function to delete pods in Evicted, Error, or CrashLoopBackOff state
kdelbadpods() {
  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Usage: kdelbadpods"
    echo "Delete pods in Evicted, Error, or CrashLoopBackOff state."
    return 0
  fi

  kubectl get pods | grep -E 'Evicted|Error|CrashLoopBackOff' | awk '{print $1}' | xargs -r kubectl delete pod
}

# Function to get logs from pods with label selector
klogslb() {
    local label_selector=""
    local namespace_opt=""
    local extra_args=()

    # Handle --help or -h
    for arg in "$@"; do
        if [[ "$arg" == "--help" || "$arg" == "-h" ]]; then
            echo "Usage: klogslb [-n namespace] [-l label_selector] [kubectl logs options]"
            echo
            echo "If -l is not provided, a label list will be shown for selection via fzf."
            echo "Examples:"
            echo "  klogslb --tail=100"
            echo "  klogslb -n mynamespace --tail=50"
            echo "  klogslb -l \"app=myapp\" --since=5m"
            echo
            echo "You can add any kubectl logs options after the label/namespace flags."
            return 0
        fi
    done

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -l|--selector)
                label_selector="$2"
                shift 2
                ;;
            -n|--namespace)
                namespace_opt="-n $2"
                shift 2
                ;;
            *)
                extra_args+=("$1")
                shift
                ;;
        esac
    done

    # Nếu chưa có label_selector thì tự động lấy list labels từ các pod và chọn bằng fzf
    if [[ -z "$label_selector" ]]; then
        label_selector=$(kubectl get pods $namespace_opt --show-labels --no-headers | \
            awk '{print $NF}' | tr ',' '\n' | sort | uniq | fzf --prompt="Select label: ")
        if [[ -z "$label_selector" ]]; then
            echo "❌ No label selected."
            return 1
        fi
    fi

    kubectl get pods -l "$label_selector" $namespace_opt -o name | cut -d/ -f2 | while read -r pod; do
        echo "==== Logs from $pod ===="
        kubectl logs "${extra_args[@]}" $namespace_opt "$pod"
        echo
    done
}

# Function to exec into pods with label selector
kexeclb() {
    local label_selector=""
    local namespace_opt=""
    local extra_args=()
    local user_cmd=()

    # Handle --help or -h
    for arg in "$@"; do
        if [[ "$arg" == "--help" || "$arg" == "-h" ]]; then
            echo "Usage: kexeclb [-n namespace] [-l label_selector] -- <command>"
            echo
            echo "If you don't provide -l, it will display a label list to select (fzf)."
            echo "Examples:"
            echo "  kexeclb -- ls /data"
            echo "  kexeclb -n myns -- cat logs/predict.log"
            echo "  kexeclb -l \"app=myapp\" -- ls"
            echo
            echo "Note:"
            echo "- For complex commands (like cd, &&, pipe), use:"
            echo "  kexeclb -- /bin/sh -c 'cd logs && ls'"
            return 0
        fi
    done

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -l|--selector)
                label_selector="$2"
                shift 2
                ;;
            -n|--namespace)
                namespace_opt="-n $2"
                shift 2
                ;;
            --)
                shift
                user_cmd=("$@")
                break
                ;;
            *)
                extra_args+=("$1")
                shift
                ;;
        esac
    done

    if [[ -z "$label_selector" ]]; then
        label_selector=$(kubectl get pods $namespace_opt --show-labels --no-headers | \
            awk '{print $NF}' | tr ',' '\n' | sort | uniq | fzf --prompt="Select label: ")
        [[ -z "$label_selector" ]] && echo "❌ No label selected." && return 1
    fi

    if [[ ${#user_cmd[@]} -eq 0 ]]; then
        echo "❌ You must provide a command to exec in pods (e.g., ls, cat logs/predict.log, ...)"
        echo "👉 Usage: kexeclb -l \"app=myapp\" -- ls"
        return 1
    fi

    kubectl get pods -l "$label_selector" $namespace_opt -o name | cut -d/ -f2 | while read -r pod; do
        echo "==== Exec on $pod ===="
        kubectl exec $namespace_opt "$pod" -- "${user_cmd[@]}"
        echo
    done
}

# Function to get pod image by label selector
kgimlb() {
  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Usage: kgimg -l label_selector"
    echo
    echo "If -l is not provided, a label list will be shown for selection via fzf."
    echo "Examples:"
    echo "  kgimg -l \"app=myapp\""
    echo "  kgimg -l \"app=myapp\" -n mynamespace"
    echo
    return 0
  fi

  local label_selector=""
  local namespace_opt=""

  while [[ $# -gt 0 ]]; do
      case "$1" in
          -l|--selector)
              label_selector="$2"
              shift 2
              ;;
          -n|--namespace)
              namespace_opt="-n $2"
              shift 2
              ;;
          *)
              shift
              ;;
      esac
  done

  # If label_selector is not provided, use fzf to select
  if [[ -z "$label_selector" ]]; then
      label_selector=$(kubectl get pods $namespace_opt --show-labels --no-headers | \
          awk '{print $NF}' | tr ',' '\n' | sort | uniq | fzf --prompt="Select label: ")
      [[ -z "$label_selector" ]] && echo "❌ No label selected." && return 1
  fi

  # Get all image which match the label selector
  kubectl get pods -l "$label_selector" $namespace_opt -o jsonpath='{.items[*].spec.containers[*].image}' | \
      tr ' ' '\n' | sort | uniq
}

# Function to get labels of a pod
kglb() {
    local pod_name=""
    local namespace_opt=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -n|--namespace)
                namespace_opt="-n $2"
                shift 2
                ;;
            *)
                pod_name="$1"
                shift
                ;;
        esac
    done

    # Transfer command to english
    # If pod_name is not provided, use fzf to select
    if [[ -z "$pod_name" ]]; then
        pod_name=$(kubectl get pods $namespace_opt --no-headers | awk '{print $1}' | fzf --prompt="Select pod: ")
        [[ -z "$pod_name" ]] && echo "❌ No pod selected." && return 1
    fi

    # If labels are separated by ",", list all labels in a new line
    kubectl  get pod $pod_name $namespace_opt --show-labels --no-headers | \
        awk '{print $NF}' | tr ',' '\n' | sort | uniq
}

k8s_helper_commands() {
    local commands=(
        "kdelbadpods: Delete pods in Evicted, Error, or CrashLoopBackOff state"
        "klogslb: Get logs from pods with label selector"
        "kexeclb: Exec into pods with label selector"
        "kgimlb: Get images of pods with label selector"
        "kglb: Get labels of a pod"
    )

    for cmd in "${commands[@]}"; do
        echo "$cmd"
    done
}
