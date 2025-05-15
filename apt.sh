sudo apt update
sudo apt insatll -y \
    git \
    curl \
    unzip \
    golang-go \
    ca-certificates \
    gnupg \
    lsb-release

echo "Installing Terraform..."
if ! command -v terraform &>/dev/null; then
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
        | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update
    sudo apt install -y terraform
else
    echo "Terraform is already installed"
fi

