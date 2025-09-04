# E-commerce Cart API

API REST desenvolvida em **Ruby on Rails** para gerenciamento de um carrinho de compras em um e-commerce.  

A aplicação permite criar carrinhos de compras, adicionar/alterar/remover produtos, listar itens do carrinho e gerenciar carrinhos abandonados por meio de **jobs automáticos**.

---

## Tecnologias

- [Ruby 3.3.1](https://www.ruby-lang.org)
- [Rails 7.1.3.2](https://rubyonrails.org)
- [PostgreSQL 16](https://www.postgresql.org/)
- [Redis 7.0.15](https://redis.io/)
- [Sidekiq](https://sidekiq.org/) para processamento de jobs em background
- [Docker](https://www.docker.com/) e [Docker Compose](https://docs.docker.com/compose/) para orquestração

---

## Funcionalidades

#### 1. Criar carrinho
- Cria um carrinho para a sessão.
- Retorna os dados co carrinho e a lista de produtos e valores.

**Rota**: `POST /carts`
**Payload**:
```json
{ }
```

**Response**:
```json
{
  "id": 789,
  "products": [],
  "total_price": 0
}
```

---

#### 2. Listar itens do carrinho atual
- Retorna todos os produtos do carrinho atual, com preços unitários, totais e o valor total acumulado.

**Rota**: `GET /carts`

**Response**:
```json
{
  "id": 789,
  "products": [
    {
      "id": 645,
      "name": "Nome do produto",
      "quantity": 2,
      "unit_price": 1.99,
      "total_price": 3.98
    }
  ],
  "total_price": 3.98
}
```

---

#### 3. Adicionar produtos no carrinho
- Se o produto já existir no carrinho, apenas a quantidade é atualizada.
- Retorna o carrinho atualizado.

**Rota**: `POST /carts/add_item`
**Payload**:
```json
{
  "product_id": 1230,
  "quantity": 1
}
```

**Response**:
```json
{
  "id": 1,
  "products": [
    {
      "id": 1230,
      "name": "Nome do produto X",
      "quantity": 2,
      "unit_price": 7.00,
      "total_price": 14.00
    },
    {
      "id": 1020,
      "name": "Nome do produto Y",
      "quantity": 1,
      "unit_price": 9.90,
      "total_price": 9.90
    }
  ],
  "total_price": 23.9
}
```

---

#### 4. Remover um produto do carrinho
- Remove o produto do carrinho.
- Caso não exista, retorna erro apropriado.
- Se o carrinho ficar vazio, retorna o payload atualizado com lista vazia.

**Rota**: `DELETE /carts/:product_id`

---

#### 5. Gerenciar carrinhos abandonados
- **Carrinho abandonado**: sem interação por mais de 3 horas.
- Após 3 horas → marcado como abandonado.
- Após 7 dias → removido do sistema.
- Um **job** gerencia esse processo automaticamente.

---

## Executando com Docker

A aplicação já vem com **Dockerfile** e **docker-compose.yml** configurados.  

#### 1. Subir a aplicação
```bash
docker-compose up --build
```

Esse comando irá subir:
- API Rails
- PostgreSQL
- Redis
- Sidekiq

---

#### 2. Criar banco de dados
Com os containers em execução:
```bash
docker-compose run --rm web bundle exec rails db:create db:migrate
```

---

#### 3. Executar testes
```bash
docker-compose run --rm web bundle exec rspec
```

---

## Estrutura do projeto

```
.
├── app
│   ├── controllers
│   ├── jobs
│   ├── models
│   ├── services
│   └── serializers
├── spec
├── config
├── Dockerfile
├── docker-compose.yml
└── README.md
```

---

## Tratamento de erros

- Produtos com quantidade negativa não são aceitos.
- Tentativa de remover produtos inexistentes retorna erro apropriado.
- Carrinhos vazios são tratados e retornados corretamente.
- Não é possível adicionar um produto em um carrinho com status `completed` ou `expired`

---

## Testes

- Implementados em **RSpec**.
- Cobrem rotas, serviços, models e jobs.
- Incluem casos de borda como:
  - adicionar produtos repetidos,
  - remover produtos inexistentes,
  - carrinho vazio após remoção,
  - expiração e exclusão de carrinhos abandonados.

Para rodar:
```bash
docker-compose run --rm web bundle exec rspec
```

---

## 📌 Resumo

Essa API fornece a base para um sistema de carrinho de compras em e-commerce, com:
- CRUD de itens no carrinho
- Controle de abandono
- Testes robustos
- Orquestração via Docker

Pronta para ser integrada a um frontend ou sistema maior.
