/* 
    -- Código SQL do trabalho interdisciplinar do Grupo MKMG --
    Este arquivo e o diagrama DER estão disponíveis no repositório do Github
    https://github.com/Mardson581/InterProtese

    Se possível, documente todo o código que for alterado ou adicionado para facilitar a
    manutenção :-)

    Não vale usar ChatGPT aqui >:-(
*/

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

-- Tanto um Dentista quanto um Protético interagem com n Pedidos
create table Pedidos (
    id          int not null identity,

);