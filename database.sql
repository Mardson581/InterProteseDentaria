/* 
    -- Código SQL do trabalho interdisciplinar do Grupo MKMG --
    Este arquivo e o diagrama DER estão disponíveis no repositório do Github
    https://github.com/Mardson581/InterProteseDentaria

    Se possível, documente todo o código que for alterado ou adicionado para facilitar a
    manutenção :-)

    Não vale usar ChatGPT aqui >:-(
*/

create database InterProtetico; -- É um bom nome? Talvez fosse bom trocar?
go

use InterProtetico;
go

-- Aqui entra a lógica para armazenar os endereços
-- É uma boa prática destrinchar as partes do endereço em tabelas diferentes
create table UFs (
    codigo      int not null identity,
    sigla       varchar(2) not null,

    constraint pk_codigo_uf primary key(codigo),
    constraint unique_sigla unique(sigla)
);

create table Cidades (
    codigo      int not null identity,
    nome        varchar(50) not null,
    codigo_uf   int not null,

    constraint pk_codigo_cidade primary key(codigo),
    constraint unique_nome_cidade unique(nome),
    constraint fk_codigo_uf foreign key(codigo_uf) references UFs
);

create table CEPs (
    codigo          int not null identity,
    cep             int not null,
    codigo_cidade   int not null,
    
    constraint pk_codigo_cep primary key(codigo),
    constraint unique_cep unique(cep),
    constraint fk_codigo_cidade foreign key(codigo_cidade) references Cidades
);

-- Pessoas é a tabela pai de Dentistas, Protéticos e Entregadores
-- As tabelas filhas herdarão desta tabela através da coluna 'codigo'
create table Pessoas (
    codigo          int not null identity,
    cpf             int not null,
    nome            varchar(100) not null,
    numero          int not null,
    telefone        int not null,
    logradouro      varchar(50) not null,
    codigo_cep      int not null,

    constraint pk_codigo_pessoa primary key(codigo),
    constraint unique_cpf unique(cpf),
    constraint unique_telefone unique(telefone),
    constraint fk_codigo_cep foreign key(codigo_cep) references CEPs,

    -- É sempre bom verificar os valores inseridos pelo usuário
    -- Tudo aqui deve ser maior que 0
    constraint check_cpf check(cpf > 0),
    constraint check_numero check(numero > 0),
    constraint check_telefone check(telefone > 0),
);

-- Aqui entram as tabelas principais do sistema
-- Essas tabelas representam os usuários do sistema e herdam de Pessoas
-- 'codigo_pessoa' deve ser chave primária e estrangeira (vindo de Pessoas)
create table Dentistas (
    codigo_pessoa    int not null,
    crm              int not null,

    constraint pk_codigo_dentista primary key(codigo_pessoa),
    constraint fk_codigo_pessoa_dentista foreign key(codigo_pessoa) references Pessoas,
    constraint unique_crm unique(crm)
);

create table Proteticos (
    codigo_pessoa   int not null,
    -- acho que devia ter mais coisa aqui...

    constraint pk_codigo_protetico primary key(codigo_pessoa),
    constraint fk_codigo_pessoa_protetico foreign key(codigo_pessoa) references Pessoas
);

create table Entregadores (
    codigo_pessoa   int not null,
    comissao        decimal(5,2) not null,

    constraint pk_codigo_entregador primary key(codigo_pessoa),
    constraint fk_codigo_pessoa_entregador foreign key(codigo_pessoa) references Pessoas,

    -- O valor da comissão não pode ser negativo
    constraint check_comissao check(comissao >= 0)
);

-- Como a tabelas Entregas manda a chave para Pedidos, ela deve ser criada antes de Pedidos
-- O status pode ser 'Para entregar', 'Em trânsito, 'Entregue' ou 'Cancelado', sendo representado por 0, 1, 2, 3
create table Entregas (
    id                  int not null identity,
    codigo_entregador   int not null,
    data_hora_entrega   datetime not null default getdate(),
    status              int not null default 0,

    constraint pk_id_entrega primary key(id),
    constraint fk_codigo_entregador foreign key(codigo_entregador) references Entregadores,

    -- Verificar se o status é válido (0, 1, 2 ou 3)
    constraint check_status check(status in (0,1,2,3))
);

-- Tanto um Dentista quanto um Protético interagem com n Pedidos
-- Um Pedido pode estar em uma entrega ou não (tornando codigo_entrega=null)
-- A relação de Entregas e Pedidos é de 1-N
-- *Verificar com o professor se codigo_entrega pode ser null ou não*
create table Pedidos (
    id                  int not null identity,
    valor_total         decimal(6,2) not null,
    codigo_dentista     int not null,
    codigo_protetico    int not null,
    codigo_entrega      int default null,

    constraint pk_id_pedido primary key(id),
    constraint fk_codigo_dentista foreign key(codigo_dentista) references Dentistas,
    constraint fk_codigo_protetico foreign key(codigo_protetico) references Proteticos,
    constraint fk_codigo_entrega foreign key(codigo_entrega) references Entregas,
    
    -- O valor total não pode ser negativo
    constraint check_total check(valor_total >= 0)
);

-- Pedidos podem ter ou não Parcelas
create table Parcelas (
    codigo      int not null identity,
    id_pedido   int not null,
    valor       decimal(6,2) not null,
    
    constraint pk_codigo_parcela primary key(codigo),
    constraint fk_id_pedido_parcela foreign key(id_pedido) references Pedidos,

    constraint check_valor_parcela check(valor > 0)
);

-- Os serviços disponíveis para encomenda são guardados nesta tabela
-- Um Pedido tem vários Serviços e um Serviço tem vários Pedidos
create table Servicos (
    codigo      int not null identity,
    nome        varchar(50) not null,
    descricao   varchar(150) not null,
    valor       decimal(6,2) not null,

    constraint pk_codigo_servico primary key(codigo),
    constraint unique_nome_servicos unique(nome),
    
    constraint check_valor_servico check(valor >= 0)
);

-- Esta tabela é usada para fazer o N-N entre Pedidos e Serviços
-- As chaves estrangeiras devem ser primárias também, assim forma-se o N-N
create table Itens_Pedidos (
    id_pedido       int not null,
    codigo_servico  int not null,
    quantidade      int not null,

    -- Aqui usa-se chave primária composta (duas primary keys)
    constraint pk_id_pedido_servico primary key(id_pedido, codigo_servico),
    
    constraint fk_id_pedido foreign key(id_pedido) references Pedidos,
    constraint fk_codigo_servico foreign key(codigo_servico) references Servicos,

    constraint check_quantidade check(quantidade > 0)
);
go

select 'Parece que tudo está certo!' -- Teste