#!/bin/bash

setup_k3s (){
    set -e
    echo "=== Start to Install K3s ==="

    echo "=== Disable Firewall ==="
    systemctl disable --now firewalld || echo "firewalld not found, skipping firewall disable step"

    echo "=== Disable Swap (K8s Requirement) ==="
    swapoff -a
    sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

    echo "=== Using CN mirror to install server ==="

    curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | \
    INSTALL_K3S_MIRROR=cn \
    INSTALL_K3S_EXEC="server --disable servicelb --disable traefik --flannel-backend none" \
    sh -

    echo "=== Configure Kubectl Access Permissions ==="
    mkdir -p $HOME/.kube
    cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config
    echo "export KUBECONFIG=$HOME/.kube/config" >> $HOME/.bashrc

    # ----------------------------------------------------------------------
    # Grant kubectl access to the current user (ubuntu) by copying the kubeconfig file and setting permissions
    # ----------------------------------------------------------------------
    TARGET_USER=${target_user}
    if id "$TARGET_USER" &>/dev/null; then
        USER_HOME=$(eval echo ~$TARGET_USER)
        echo "=== Add kubectl access for $TARGET_USER ==="
        mkdir -p "$USER_HOME/.kube"
        cp /etc/rancher/k3s/k3s.yaml "$USER_HOME/.kube/config"
        chown -R "$TARGET_USER:$TARGET_USER" "$USER_HOME/.kube"
        chmod 600 "$USER_HOME/.kube/config"

        if ! grep -q "export KUBECONFIG=$USER_HOME/.kube/config" "$USER_HOME/.bashrc" 2>/dev/null; then
            echo "export KUBECONFIG=$USER_HOME/.kube/config" >> "$USER_HOME/.bashrc"
        fi
        echo "Successfully configured kubectl access for $TARGET_USER"
    else
        echo "User $TARGET_USER does not exist, skipping kubectl permission configuration"
    fi

    echo "=== Waiting for K3s to start and deploy Calico network plugin (as a replacement for Flannel) ==="
    sleep 30
    kubectl get node

    kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

    echo "=== Deployment completed, current status as below ==="
    kubectl get pods -A

    # ----------------------------------------------------------------------
    # Install Helm (using CDN for faster download)
    # ----------------------------------------------------------------------
    echo "=== Install Helm ==="
    if ! command -v helm &> /dev/null; then
        TENCENT_MIRROR="https://get.helm.sh/"
        HELM_VERSION="v3.12.0"                    
        HELM_TAR="helm-$HELM_VERSION-linux-amd64.tar.gz"
        URL="$TENCENT_MIRROR/$HELM_TAR"

        echo "Downloading $URL ..."
        curl -fsSL "$URL" -o "$HELM_TAR"

        echo "Extracting $HELM_TAR ..."
        tar -zxvf "$HELM_TAR"
        mv linux-amd64/helm /usr/local/bin/helm
        chmod +x /usr/local/bin/helm
        rm -rf "$HELM_TAR" linux-amd64
        echo "Helm $HELM_VERSION installed successfully at $(which helm)."
    else
        echo "Helm already installed: $(helm version --short)"
    fi

    echo "=== End to Install K3s ==="
}

output() {
    echo "K3s Instance IP: ${instance_ip}"
    echo "K3s Instance ID: ${instance_id}"
    echo "Execute cmd to connect server: ssh -i k3s-cvm/ssh_key/cvm_key.pem ubuntu@${instance_ip}"
}

main() {
    echo "Setup K3s ..."
    setup_k3s
    
    output
}

main