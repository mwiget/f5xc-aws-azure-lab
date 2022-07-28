FROM gitpod/workspace-base

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - \
      && sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
      && sudo apt-get update && sudo apt-get install -y -q terraform inetutils-ping jq \
      && curl -sLO "https://vesio.azureedge.net/releases/vesctl/$(curl -s https://downloads.volterra.io/releases/vesctl/latest.txt)/vesctl.linux-amd64.gz" \
      && gzip -d  vesctl.linux-amd64.gz \
      && chmod +x vesctl.linux-amd64 \
      && sudo mv  vesctl.linux-amd64 /usr/local/bin/vesctl \
      && curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash \
      && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
      && unzip awscliv2.zip \
      && sudo ./aws/install \
      && rm -rf aws awscliv2.zip
