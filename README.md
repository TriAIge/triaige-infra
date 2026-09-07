# triaige-infra

Provisionamento de infraestrutura AWS do TriAIge: Terraform (rede, compute, load
balancer, filas, storage) + Ansible (deploy dos serviços e configuração do MySQL),
orquestrados via GitHub Actions.

## Estrutura

```
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

## Operação

Os workflows são disparados manualmente (`workflow_dispatch`), nunca em push/PR — a infra
não é recriada a cada commit.

**AWS Academy Learner Lab**: as credenciais AWS (`AWS_ACCESS_KEY_ID`/
`AWS_SECRET_ACCESS_KEY`/`AWS_SESSION_TOKEN`, Secrets do repositório) vêm da aba "AWS
Details" do laboratório e **mudam a cada reinício** — é preciso atualizar os Secrets antes
de rodar `terraform-apply`/`terraform-destroy`.

**State remoto**: o `tfstate` é restaurado do cache do GitHub Actions (chave fixa
`tfstate-cache`), compartilhado entre apply e destroy. Caches expiram após ~7 dias sem
uso — se isso acontecer, o state precisa ser reconstruído manualmente antes do próximo
apply.

## Segurança

O `.gitignore` exclui `*.pem`/`*.tfstate`/`*.tfvars` para chaves e state gerados
localmente. **Atenção:** os arquivos em `terraform/keys/` (`key-ec2-private-triaige.pem`,
`key-ec2-public-triaige.pem` e seus `.pub`) estão atualmente versionados no histórico do
repositório, de antes dessas regras existirem — revisar a necessidade de remover esses
arquivos do histórico e rotacionar as chaves antes de considerar este repositório seguro
para acesso mais amplo.
