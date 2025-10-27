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

    constraint pk_codigo primary key(codigo),
    constraint unique_cpf unique(cpf),
    constraint unique_telefone unique(telefone),
    constraint fk_codigo_cep foreign key(codigo_cep) references CEPs,

    -- É sempre bom verificar os valores inseridos pelo usuário
    -- Tudo aqui deve ser maior que 0
    constraint check_cpf check(cpf > 0),
    constraint check_numero check(numero > 0),
    constraint check_telefone check(telefone > 0),
);

-- Aqui entra a lógica para armazenar os endereços
-- É uma boa prática destrinchar as partes do endereço em tabelas diferentes
create table CEPs (
    codigo          int not null identity,
    cep             int not null,
    codigo_cidade   int not null,
    
    constraint pk_codigo primary key(codigo),
    constraint unique_cep unique(cep),
    constraint fk_codigo_cidade foreign key(codigo_cidade) references Cidades
);

create table Cidades (
    codigo      int not null identity,
    nome        varchar(50) not null,
    codigo_uf   int not null,

    constraint pk_codigo primary key(codigo),
    constraint unique_nome unique(nome),
    constraint fk_codigo_uf foreign key(codigo_uf) references UFs
);

create table UFs (
    codigo      int not null identity,
    sigla       varchar(2) not null,

    constraint pk_codigo primary key(codigo),
    constraint unique_sigla unique(sigla)
);

-- Aqui entram as tabelas principais do sistema
-- Essas tabelas representam os usuários do sistema e herdam de Pessoas
-- 'codigo_pessoa' deve ser chave primária e estrangeira (vindo de Pessoas)
create table Dentistas (
    codigo_pessoa    int not null,
    crm              int not null,

    constraint pk_codigo_pessoa primary key(codigo_pessoa),
    constraint fk_codigo_pessoa foreign key(codigo_pessoa) references Pessoas,
    constraint unique_crm unique(crm)
);

create table Proteticos (
    codigo_pessoa   int not null,
    -- acho que devia ter mais coisa aqui...

    constraint pk_codigo_pessoa primary key(codigo_pessoa),
    constraint fk_codigo_pessoa foreign key(codigo_pessoa) references Pessoas
);

create table Entregadores (
    codigo_pessoa   int not null,
    comissao        decimal(5,2) not null,

    constraint pk_codigo_pessoa primary key(codigo_pessoa),
    constraint fk_codigo_pessoa foreign key(codigo_pessoa) references Pessoas,

    -- O valor da comissão não pode ser negativo
    constraint check_comissao check(comissao >= 0)
);

-- Como a tabelas Entregas manda a chave para Pedidos, ela deve ser criada antes de Pedidos
-- Corrigindo: A tabela Entregas deve referenciar um Pedido. Um Pedido pode ter uma Entrega.
create table Entregas (
    id                  int not null identity,
    id_pedido           int not null,
    codigo_entregador   int not null,
    data_hora_entrega   datetime not null default getdate(),

    constraint pk_id primary key(id),
    constraint fk_id_pedido foreign key(id_pedido) references Pedidos,
    constraint fk_codigo_entregador foreign key(codigo_entregador) references Entregadores
);

-- Tanto um Dentista quanto um Protético interagem com n Pedidos
-- Vários Pedidos podem ser entregues por um Entregador, mas não é obrigatório
-- O código do Entregador é responsabilidade da tabela Entregas
create table Pedidos (
    id                  int not null identity,
    valor_total         decimal(6,2) not null,
    codigo_dentista     int not null,
    codigo_protetico    int not null,

    constraint pk_id primary key(id),
    constraint fk_codigo_dentista foreign key(codigo_dentista) references Dentistas,
    constraint fk_codigo_protetico foreign key(codigo_protetico) references Proteticos,
    
    -- O valor total não pode ser negativo
    constraint check_total check(valor_total)
);

-- Pedidos podem ter ou não Parcelas
create table Parcelas (
    codigo      int not null identity,
    id_pedido   int not null,
    valor       decimal(6,2) not null,
    
    constraint pk_codigo primary key(codigo),
    constraint fk_id_pedido foreign key(id_pedido) references Pedidos,

    constraint check_valor check(valor > 0)
);

-- Os serviços disponíveis para encomenda são guardados nesta tabela
-- Um Pedido tem vários Serviços e um Serviço tem vários Pedidos
create table Servicos (
    codigo      int not null identity,
    nome        varchar(50) not null,
    descricao   varchar(150) not null,
    valor       decimal(6,2) not null,

    constraint pk_codigo primary key(codigo),
    constraint unique_nome unique(nome),
    
    constraint check_valor check(valor >= 0)
);

-- Esta tabela é usada para fazer o N-N entre Pedidos e Serviços
-- As chaves estrangeiras devem ser primárias também, assim forma-se o N-N
-- Aqui usa-se chave primária composta (duas primary keys)
create table Itens_Pedidos (
    id_pedido       int not null,
    codigo_servico  int not null,
    quantidade      int not null,

    constraint pk_id_pedido primary key(id_pedido),
    constraint pk_codigo_servico primary key(codigo_servico),
    
    constraint fk_id_pedido foreign key(id_pedido) references Pedidos,
    constraint fk_codigo_servico foreign key(codigo_servico) references Servicos,

    constraint check_quantidade check(quantidade > 0)
);
go