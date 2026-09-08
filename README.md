# TriAIge / triaige-infra

> Provisionamento e operação da infraestrutura AWS do TriAIge: Terraform (rede, compute, load balancer, filas, storage) + Ansible (deploy dos serviços e configuração do MySQL), orquestrados via GitHub Actions.

## Sobre o projeto

O **TriAIge** é uma plataforma de triagem jurídica assistida por IA, composta por múltiplos serviços (ingestão, pipeline de IA, notificação) que precisam de rede, banco de dados, filas e storage compartilhados na AWS.

Este repositório contém a infraestrutura responsável por:

- Provisionar toda a topologia de rede, compute, load balancer, filas e storage via Terraform.
- Instalar/configurar o MySQL e fazer o deploy dos serviços nas instâncias EC2 via Ansible.
- Orquestrar apply/destroy da infraestrutura via workflows do GitHub Actions, disparados manualmente.

## Papel deste serviço na arquitetura

```text
GitHub Actions (workflow_dispatch)
   ↓
Terraform apply (rede, compute, load balancer, filas, storage)
   ↓
Ansible (em paralelo)
   ├── playbook-deploy-services.yml    → sobe triaige-srv-mcp-ai, triaige-srv-orchestrator
   │                                     e triaige-srv-notification nas EC2 públicas
   └── playbook-configure-mysql.yml    → instala/configura o MySQL na EC2 privada
                                          (acessada via ProxyJump por uma EC2 pública)
```

Este repositório não expõe API nem processa dados de negócio — ele existe para que os demais serviços do TriAIge (`triaige-srv-orchestrator`, `triaige-srv-mcp-ai` e o serviço de notificação) tenham onde rodar.

## Responsabilidades

Este repositório é responsável por:

- Definir e provisionar a rede (VPC, subnets, internet/NAT gateway, route tables, NACLs, security groups).
- Provisionar as instâncias EC2, o load balancer (ALB), as filas (SQS) e os buckets de storage (S3).
- Configurar o MySQL compartilhado e fazer o deploy dos serviços via Ansible.
- Expor os outputs necessários (endpoints, URLs de fila, nomes de bucket) para configuração dos demais serviços.
- Orquestrar apply/destroy via GitHub Actions, sem recriar a infraestrutura a cada commit.

### Fora do escopo

Este repositório não é responsável por:

- Lógica de negócio de qualquer serviço (ingestão, pipeline de IA, notificação) — cada um vive em seu próprio repositório.
- Migração/seed de schema de aplicação — o schema (`script.sql`, raiz do monorepo) é aplicado externamente ao provisionamento de infraestrutura.

## Arquitetura

```text
terraform/
  main.tf, variables.tf, outputs.tf, monitoring.tf
  modules/
    network/          VPC, subnets, IGW, NAT, route tables, NACLs, security groups
    compute/ec2/       instâncias EC2
    load_balancer/     ALB
    messaging/sqs/     filas
    storage/           buckets S3
ansible/
  playbook-deploy-services.yml     sobe triaige-srv-mcp-ai, triaige-srv-orchestrator
                                    e triaige-srv-notification nas EC2 públicas
  playbook-configure-mysql.yml     instala/configura o MySQL na EC2 privada
                                    (databases triaige_srv_orchestrator e
                                    triaige_srv_notification), acessada via
                                    ProxyJump por uma EC2 pública
.github/workflows/
  terraform-apply.yml    workflow_dispatch: terraform apply -> deploy dos serviços
                          (Ansible) -> configuração do MySQL (Ansible), os dois
                          últimos em paralelo
  terraform-destroy.yml  workflow_dispatch (exige digitar "destroy"): destrói toda
                          a infra
```

### Comunicação com outros serviços

| Serviço / Recurso | Tipo | Finalidade |
|---|---|---|
| `triaige-srv-orchestrator` | Deploy (Ansible) + recursos AWS | EC2 pública, filas SQS, buckets S3 usados pelo serviço |
| `triaige-srv-mcp-ai` | Deploy (Ansible) + recursos AWS | EC2 pública, filas SQS, buckets S3 usados pelo serviço |
| `triaige-srv-notification` | Deploy (Ansible) | EC2 pública (serviço fora deste monorepo) |
| MySQL (EC2 privada) | Provisionamento + configuração | Banco compartilhado pelos serviços de aplicação |

## Tecnologias utilizadas

- Terraform (>= 1.5.0), provider `hashicorp/aws` (~> 5.0)
- Ansible
- AWS (VPC, EC2, ALB, SQS, S3, CloudWatch)
- GitHub Actions (workflows `workflow_dispatch`)
- MySQL

## Estrutura do projeto

```text
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── monitoring.tf
├── keys/            chaves EC2 (ver seção Segurança)
└── modules/
    ├── network/
    ├── compute/ec2/
    ├── load_balancer/
    ├── messaging/sqs/
    └── storage/
ansible/
├── ansible.cfg
├── playbook-deploy-services.yml
└── playbook-configure-mysql.yml
.github/workflows/
├── terraform-apply.yml
└── terraform-destroy.yml
```

### Organização dos módulos Terraform

- `network`: VPC, subnets públicas/privadas, internet gateway, NAT gateway, route tables, NACLs, security groups.
- `compute/ec2`: instâncias EC2 públicas (serviços de aplicação) e privada (MySQL).
- `load_balancer`: Application Load Balancer na frente das EC2 públicas.
- `messaging/sqs`: filas de ingestão, pré-processamento, resultados e DLQs.
- `storage`: buckets S3 (documentos raw, trusted, curated).

## Pré-requisitos

- Terraform >= 1.5.0
- Ansible
- AWS CLI configurado (ou credenciais via GitHub Actions Secrets)
- Acesso ao AWS Academy Learner Lab (ou conta AWS equivalente)

## Configuração

### Variáveis de ambiente / Terraform

Principais variáveis (`terraform/variables.tf`):

```text
aws_region
environment
alert_email
iam_instance_profile
acm_certificate_arn
```

Credenciais AWS (`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_SESSION_TOKEN`) são configuradas como Secrets do repositório no GitHub Actions, não em arquivo local.

> Nunca versione credenciais, tokens, senhas ou outros secrets reais no repositório.

### Configuração local

Este repositório é operado principalmente via GitHub Actions (`workflow_dispatch`), não por execução manual de `terraform apply` numa máquina local — mas os playbooks Ansible e os arquivos Terraform podem ser inspecionados/validados localmente com `terraform plan` e `ansible-playbook --syntax-check`.

**AWS Academy Learner Lab:** as credenciais AWS vêm da aba "AWS Details" do laboratório e **mudam a cada reinício** — é preciso atualizar os Secrets do repositório antes de rodar `terraform-apply`/`terraform-destroy`.

**State remoto:** o `tfstate` é restaurado do cache do GitHub Actions (chave fixa `tfstate-cache`), compartilhado entre apply e destroy. Caches expiram após ~7 dias sem uso — se isso acontecer, o state precisa ser reconstruído manualmente antes do próximo apply.

## Executando localmente

### Validando o Terraform

```bash
cd terraform
terraform init
terraform plan
```

### Aplicando/destruindo a infraestrutura

Os workflows são disparados manualmente (`workflow_dispatch`), nunca em push/PR:

- `terraform-apply.yml`: `terraform apply` → deploy dos serviços (Ansible) → configuração do MySQL (Ansible), os dois últimos em paralelo.
- `terraform-destroy.yml`: exige digitar `destroy` para confirmar; destrói toda a infraestrutura.

## Fluxo principal

```text
Disparo manual do workflow (workflow_dispatch)
   ↓
terraform apply (rede, compute, load balancer, filas, storage)
   ↓
Ansible: deploy dos serviços (EC2 públicas) + configuração do MySQL (EC2 privada)
   ↓
Infraestrutura pronta para os serviços de aplicação
```

## Segurança

- `.gitignore` exclui `*.pem`/`*.tfstate`/`*.tfvars` para chaves e state gerados localmente a partir de agora.
- **Atenção:** os arquivos em `terraform/keys/` (`key-ec2-private-triaige.pem`, `key-ec2-public-triaige.pem` e seus `.pub`) ainda estão versionados no histórico do repositório, de antes dessas regras existirem — a remoção desses arquivos do histórico e a rotação das chaves é um ajuste pendente antes de considerar este repositório seguro para acesso mais amplo.
- Credenciais AWS nunca ficam em arquivo versionado — são injetadas via Secrets do GitHub Actions.

## Repositórios relacionados

Este repositório faz parte do ecossistema **TriAIge**.

| Repositório | Responsabilidade |
|---|---|
| `triaige-front-nextjs` | Site institucional e mockup de dashboard (Next.js / Tailwind) |
| `triaige-srv-orchestrator` | Ingestão de documentos e orquestração do fluxo de triagem |
| `triaige-srv-mcp-ai` | Pipeline de pré-processamento e raciocínio de IA |

## Projeto acadêmico

Projeto desenvolvido como Trabalho de Conclusão de Curso em:

**Curso:** Sistemas de Informação
**Instituição:** São Paulo Tech School
**Ano:** 2026

### Objetivo

Prover a infraestrutura AWS necessária para operar os serviços do TriAIge, com provisionamento reproduzível via Terraform e deploy automatizado via Ansible, dentro das limitações de um ambiente de laboratório acadêmico (AWS Academy Learner Lab).

## Equipe

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/GabrielNunees063">
        <img src="https://avatars.githubusercontent.com/u/125298578?v=4" width="100px;"><br>
        <sub><b>Gabriel Nunes</b></sub>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/Bielzinschiavo">
        <img src="https://avatars.githubusercontent.com/u/125298078?v=4" width="100px;"><br>
        <sub><b>Gabriel Schiavo</b></sub>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/gyuliapiqueira">
        <img src="https://avatars.githubusercontent.com/u/125298346?v=4" width="100px;"><br>
        <sub><b>Gyulia Piqueira</b></sub>
      </a>
    </td>
  </tr>

  <tr>
    <td align="center" colspan="3">
      <table>
        <tr>
          <td align="center">
            <a href="https://github.com/Kaori2">
              <img src="https://avatars.githubusercontent.com/u/125297000?v=4" width="100px;"><br>
              <sub><b>Kaori Katayama</b></sub>
            </a>
          </td>
          <td align="center">
            <a href="https://github.com/Miguel-Araujo325">
              <img src="https://avatars.githubusercontent.com/u/125296970?v=4" width="100px;"><br>
              <sub><b>Miguel Araujo</b></sub>
            </a>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

## Licença

> Este projeto foi desenvolvido para fins acadêmicos.
