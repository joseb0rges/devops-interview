# Terraform Infrastructure – API com ALB + mTLS + ECS Fargate + WAF

## 📌 Visão Geral

Este repositório contém a implementação de **infraestrutura em AWS via Terraform** para hospedar uma **API em ECS Fargate**, exposta através de um **Application Load Balancer (ALB)** com **SSL/TLS** e **mTLS** habilitados.
O provisionamento é automatizado via **CI/CD no GitHub Actions**, garantindo segurança, consistência e reprodutibilidade.

### Componentes Provisionados

* **Networking**: VPC, subnets públicas e privadas, Internet Gateway e roteamento.
* **S3 (mTLS Truststore)**: bucket versionado para armazenar o bundle de certificados da CA confiável (mTLS).
* **ALB**: balanceador público com listener HTTPS, certificado TLS via ACM e **Trust Store** integrado ao S3.
* **ECS Fargate**: cluster, task definitions e services para execução da aplicação containerizada.
* **WAF v2**: Web Application Firewall integrado ao ALB para proteção contra tráfego malicioso.

---

## 🔐 Fluxo de Segurança

1. O cliente acessa o **ALB** via HTTPS.
2. O **ALB exige autenticação mTLS** (certificado cliente válido).
3. O **bundle da CA** usado para validação do cliente é armazenado no **S3 versionado** e associado ao **Trust Store do ALB**.
4. Conexões válidas são encaminhadas para o **ECS Fargate Service**.
5. O **WAF v2** filtra tráfego malicioso antes que chegue à aplicação.

---

## 🛠️ Gerando Certificados com OpenSSL

> ⚠️ Estes certificados são apenas para **homologação/testes**.
> Em produção, recomenda-se usar **AWS ACM PCA** ou uma **CA corporativa**.

### 1. Criar CA Root

```bash
# Chave privada da CA
openssl genrsa -out certs/ca.key 4096

# Certificado da CA (válido por 10 anos)
openssl req -x509 -new -nodes -key certs/ca.key -sha256 -days 3650 \
  -out certs/ca.crt -subj "/CN=MyRootCA/O=MyOrg/C=BR"
```

### 2. Criar Certificado do Cliente

```bash
# Chave privada do cliente
openssl genrsa -out certs/client.key 2048

# CSR (certificate signing request)
openssl req -new -key certs/client.key -out certs/client.csr \
  -subj "/CN=client1/O=MyOrg/C=BR"

# Assina o CSR com a CA Root
openssl x509 -req -in certs/client.csr -CA certs/ca.crt -CAkey certs/ca.key \
  -CAcreateserial -out certs/client.crt -days 365 -sha256
```

### 3. Gerar Bundle da CA

```bash
cat certs/ca.crt > certs/ca_bundle.pem
```

Este arquivo (`ca_bundle.pem`) é enviado ao **S3** e referenciado pelo **ALB Trust Store**.

### 4. Testar Conexão mTLS

```bash
curl -vk https://<ALB_DNS> \
  --cert certs/client.crt \
  --key certs/client.key
```

---

## ⚙️ CI/CD (GitHub Actions)

A pipeline de provisionamento está definida em `.github/workflows/terraform.yml` e possui dois jobs principais:

### **PLAN - DEV**

Executado automaticamente a cada **push para `main`**:

* `terraform init`
* `terraform validate`
* `terraform plan`
  O plano (`plan.dev.out`) é salvo como artefato.

### **APPLY - DEV**

Executado **apenas manualmente** via `workflow_dispatch`:

* Baixa o artefato `plan.dev.out`
* Executa `terraform apply -auto-approve`

🔒 Isso garante que **nenhuma mudança seja aplicada sem aprovação explícita**.

---

## 🚀 Benefícios da Implementação

✅ **Automação completa** – provisionamento 100% versionado e reprodutível com Terraform.
✅ **Segurança reforçada** – mTLS no ALB + proteção adicional com WAF.
✅ **Escalabilidade** – workloads serverless no ECS Fargate.
✅ **Governança** – certificados versionados em S3.
✅ **Confiabilidade** – mudanças aplicadas apenas via CI/CD controlado.


