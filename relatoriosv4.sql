-- Relatório 1: Lista dos empregados admitidos entre 2019-01-01 e 2022-03-31
-- Trazendo as colunas (Nome Empregado, CPF Empregado, Data Admissão, Salário, Departamento, Número de Telefone)
-- Ordenado por data de admissão decrescente;

select * from empregado 
where dataAdm between '2023-01-01' and '2023-04-01';

-- Relatório 2: Lista dos empregados que ganham menos que a média salarial dos funcionários do Petshop
-- Trazendo as colunas (Nome Empregado, CPF Empregado, Data Admissão, Salário, Departamento, Número de Telefone)
-- Ordenado por nome do empregado;

select avg(salario) as "salário" from empregado;

select cpf as "CPF", nome "Funcionário", sexo "Gênero", email "E-mail", salario "Salário", comissao "Comissão", dataAdm "Data de Admissão" 
	from empregado
		where salario < 3360
			order by nome; 

select emp.cpf as "CPF", emp.nome "Empregado", coalesce(tel.numero, 'Não informado') "Telefone", dep.nome "Departamento",
	concat('R$', format(emp.salario, 2, 'de_DE')) "Salário",
    date_format(emp.dataAdm, '%H:%i - %d/%m/%Y') "Data de Admissão"
    from empregado emp
		left join telefone tel on tel.Empregado_cpf = emp.cpf
        inner join departamento dep on dep.idDepartamento = emp.Departamento_idDepartamento
			where emp.salario < (select avg(salario) from empregado)
				order by emp.nome;
            


-- Relatório 3: Lista dos departamentos com a quantidade de empregados total por cada departamento
-- Trazendo também a média salarial dos funcionários do departamento e a média de comissão recebida pelos empregados do departamento
-- Colunas: (Departamento, Quantidade de Empregados, Média Salarial, Média da Comissão)
-- Ordenado por nome do departamento;

select b.nome, count(a.Departamento_IdDepartamento), a.salario, a.comissao
from empregado as a
inner join departamento as b on b.idDepartamento = a.Departamento_idDepartamento
group by b.nome
order by b.nome;


-- Relatório 4: Lista dos empregados com a quantidade total de vendas já realizadas por cada Empregado
-- Além da soma do valor total das vendas do empregado e a soma de suas comissões
-- Colunas: (Nome Empregado, CPF Empregado, Sexo, Salário, Quantidade Vendas, Total Valor Vendido, Total Comissão das Vendas)
-- Ordenado por quantidade total de vendas realizadas;

select 
e.cpf as 'CPF do Empregado',
e.nome as 'Nome do Empregado',
e.sexo as 'Gênero',
e.salario as 'Salário',
sum(v.valor) as 'Renda Bruta em Vendas',
sum(v.comissao) as 'Comissão Total',
count(v.idVenda) as 'Quantidade de Vendas'
from empregado as e
inner join venda as v
on e.cpf = v.Empregado_cpf
group by v.Empregado_cpf;

-- Relatório 5: Lista dos empregados que prestaram serviço na venda
-- Computando a quantidade total de vendas realizadas com serviço por cada Empregado
-- Além da soma do valor total apurado pelos serviços prestados nas vendas por empregado e a soma de suas comissões
-- Colunas: (Nome Empregado, CPF Empregado, Sexo, Salário, Quantidade Vendas com Serviço, Total Valor Vendido com Serviço, Total Comissão das Vendas com Serviço)
-- Ordenado por quantidade total de vendas realizadas;


select 
e.nome as 'Nome do Empregado',
e.cpf as 'CPF do Empregado',
e.sexo as 'Sexo',
e.salario as 'Salário',
count(v.idVenda) as 'Quantidade de Vendas com Serviços',
sum(v.valor) as 'Total Vendido com Serviços',
sum(v.comissao) as 'Total de Comissões com Serviços'
 from servico as s
 left join venda as v
 on s.idServico = v.idVenda
 left join empregado as e 
 on v.Empregado_cpf = e.cpf
 group by Empregado_cpf
 order by Empregado_cpf;



-- Relatório 6: Lista dos serviços já realizados por um Pet
-- Trazendo as colunas (Nome do Pet, Data do Serviço, Nome do Serviço, Quantidade, Valor, Empregado que realizou o Serviço)
-- Ordenado por data do serviço da mais recente a mais antiga;

select 
p.nome as 'Nome do Pet',
v.data as 'Data de Venda',
v.Cliente_cpf as 'CPF do Cliente',
v.Empregado_cpf as 'CPF do Empregado', 
v.valor as 'Valor do Serviço'
from pet as p
left join venda as v on p.Cliente_cpf = v.Cliente_cpf 
where p.nome = 'Sunny'
order by v.data desc;


-- Relatório 7: Lista das vendas já realizadas para um Cliente
-- Trazendo as colunas (Data da Venda, Valor, Desconto, Valor Final, Empregado que realizou a venda)
-- Ordenado por data do serviço da mais recente a mais antiga;

select 
date_format(data, '%H:%i - %d/%m/%Y') 'Data de Venda',
concat('R$ ', format(valor, 2, 'de_DE')) "Valor",
concat('R$ ', format(desconto, 2, 'de_DE')) "Desconto",
concat('R$ ', format(valor - desconto, 2, 'de_DE')) "Valor Final",
Empregado_cpf as 'CPF do Empregado'
from venda
where Cliente_cpf = '017.503.885-61'
order by data desc;

-- Relatório 8: Lista dos 10 serviços mais vendidos
-- Trazendo a quantidade de vendas de cada serviço e o somatório total dos valores de serviço vendido
-- Colunas: (Nome do Serviço, Quantidade Vendas, Total Valor Vendido)
-- Ordenado por quantidade total de vendas realizadas;

select  
quantidade as 'Quantidade de Vendas', 
Servico_idServico as 'Código do Serviço', 
concat('R$ ', format(valor, 2, 'de_DE')) "Valor"
from itensservico
order by quantidade desc
limit 10;

-- Relatório 9: Lista das formas de pagamentos mais utilizadas nas Vendas
-- Informando quantas vendas cada forma de pagamento já foi relacionada
-- Colunas: (Tipo Forma Pagamento, Quantidade Vendas, Total Valor Vendido)
-- Ordenado por quantidade total de vendas realizadas;

select tipo "Forma de Pagamento", count(Venda_idVenda) "Quantidade de Vendas",
	concat("R$ ", format(sum(valorPago), 2, 'de_DE')) "Valor Total Vendido"
	from formapgvenda
		group by tipo
			order by sum(valorPago) desc;

-- Relatório 10: Balanço das Vendas
-- Informando a soma dos valores vendidos por dia
-- Colunas: (Data Venda, Quantidade de Vendas, Valor Total Venda)
-- Ordenado por Data Venda da mais recente a mais antiga;

select 
count(idVenda) as 'Quantidade de Vendas do Dia' , 
concat("R$ ", format(sum(valor), 2, 'de_DE')) 'Renda Bruta' , 
date_format(data, '%H:%i - %d/%m/%Y') 'Data de Venda'
from venda
group by data;


-- Relatório 11: Lista dos Produtos
-- Informando qual Fornecedor de cada produto
-- Colunas: (Nome Produto, Valor Produto, Categoria do Produto, Nome Fornecedor, Email Fornecedor, Telefone Fornecedor)
-- Ordenado por Nome Produto;

select 
    pro.nome as "nome produto", 
    concat('R$ ', format(sum(pro.valorVenda), 2, 'de_DE')) as "valor produto", 
    pro.marca as "categoria do produto",
    coalesce(max(frn.nome), 'sem registro') as "nome fornecedor", 
    coalesce(max(frn.email), 'sem registro') as "email fornecedor", 
    coalesce(max(tel.numero), 'sem registro') as "telefone fornecedor"
from 
    produtos pro
left join 
    itenscompra itc on itc.Produtos_idProduto = pro.idProduto
left join 
    compras com on com.idCompra = itc.Compras_idCompra
left join 
    fornecedor frn on frn.cpf_cnpj = com.Fornecedor_cpf_cnpj
left join 
    telefone tel on tel.Fornecedor_cpf_cnpj = frn.cpf_cnpj
group by 
    pro.idProduto
order by 
    pro.nome;  -- Ordenando por nome do produto

-- Relatório 12: Lista dos Produtos mais vendidos
-- Informando a quantidade (total) de vezes que cada produto participou em vendas e o total de valor apurado com a venda do produto
-- Colunas: (Nome Produto, Quantidade (Total) Vendas, Valor Total Recebido pela Venda do Produto)
-- Ordenado por quantidade de vezes que o produto participou em vendas;

select  
quantidade, 
idProduto, 
nome, 
concat('R$ ', format(valorVenda, 2, 'de_DE')) "Valor", 
concat('R$ ', format(quantidade * valorVenda, 2, 'de_DE')) "Renda Bruta"

from produtos
order by quantidade 
limit 10;






-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema petshop
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema petshop
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `petshop` DEFAULT CHARACTER SET utf8 ;
USE `petshop` ;

-- -----------------------------------------------------
-- Table `petshop`.`Departamento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `petshop`.`Departamento` (
  `idDepartamento` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(45) NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  `localDep` VARCHAR(45) NULL,
  `Gerente_cpf` VARCHAR(14) NULL,
  PRIMARY KEY (`idDepartamento`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) ,
  INDEX `fk_Departamento_Empregado1_idx` (`Gerente_cpf` ASC))
-- ,
--  CONSTRAINT `fk_Departamento_Empregado1`
--    FOREIGN KEY (`Gerente_cpf`)
--    REFERENCES `petshop`.`Empregado` (`cpf`)
--    ON DELETE NO ACTION
--    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `petshop`.`Empregado`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `petshop`.`Empregado` (
  `cpf` VARCHAR(14) NOT NULL,
  `nome` VARCHAR(60) NOT NULL,
  `sexo` CHAR(1) NOT NULL,
  `email` VARCHAR(60) NULL,
  `ctps` VARCHAR(45) NOT NULL,
  `cargo` VARCHAR(45) NOT NULL,
  `dataAdm` DATETIME NOT NULL,
  `dataDem` DATETIME NULL,
  `salario` DECIMAL(7,2) ZEROFILL NOT NULL,
  `comissao` DECIMAL(6,2) ZEROFILL NULL,
  `bonificacao` DECIMAL(6,2) ZEROFILL NULL,
  `Departamento_idDepartamento` INT NOT NULL,
  PRIMARY KEY (`cpf`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC)  ,
  INDEX `fk_Empregado_Departamento_idx` (`Departamento_idDepartamento` ASC)  ,
  CONSTRAINT `fk_Empregado_Departamento`
    FOREIGN KEY (`Departamento_idDepartamento`)
    REFERENCES `petshop`.`Departamento` (`idDepartamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `petshop`.`Custos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `petshop`.`Custos` (
  `idCusto` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(45) NOT NULL,
  `valor` DECIMAL(7,2) ZEROFILL NOT NULL,
  `dataPag` DATETIME NULL,
  `dataVenc` DATETIME NOT NULL,
  `obs` VARCHAR(150) NULL,
  `Departamento_idDepartamento` INT NULL,
  PRIMARY KEY (`idCusto`),
  INDEX `fk_Custos_Departamento1_idx` (`Departamento_idDepartamento` ASC)  ,
  CONSTRAINT `fk_Custos_Departamento1`
    FOREIGN KEY (`Departamento_idDepartamento`)
    REFERENCES `petshop`.`Departamento` (`idDepartamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `petshop`.`Cliente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `petshop`.`Cliente` (
  `cpf` VARCHAR(14) NOT NULL,
  `nome` VARCHAR(60) NOT NULL,
  `numTelefone` VARCHAR(11) NOT NULL,
  `numTelefone2` VARCHAR(11) NULL,
  `email` VARCHAR(60) NULL,
  `corresponsavel` VARCHAR(60) NULL,
  PRIMARY KEY (`cpf`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC)  )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `petshop`.`Venda`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `petshop`.`Venda` (
  `idVenda` INT NOT NULL AUTO_INCREMENT,
  `data` DATETIME NOT NULL,
  `valor` DECIMAL(7,2) ZEROFILL NOT NULL,
  `comissao` DECIMAL(6,2) ZEROFILL NULL,
  `desconto` DECIMAL(4,2) ZEROFILL NULL,
  `Cliente_cpf` VARCHAR(14) NULL,
  `Empregado_cpf` VARCHAR(14) NOT NULL,
  PRIMARY KEY (`idVenda`),
  INDEX `fk_Venda_Cliente1_idx` (`Cliente_cpf` ASC)  ,
  INDEX `fk_Venda_Empregado1_idx` (`Empregado_cpf` ASC)  ,
  CONSTRAINT `fk_Venda_Cliente1`
    FOREIGN KEY (`Cliente_cpf`)
    REFERENCES `petshop`.`Cliente` (`cpf`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Venda_Empregado1`
    FOREIGN KEY (`Empregado_cpf`)
    REFERENCES `petshop`.`Empregado` (`cpf`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `petshop`.`Servico`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `petshop`.`Servico` (
  `idServico` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(60) NOT NULL,
  `valorVenda` DECIMAL(6,2) ZEROFILL NOT NULL,
  `valorCusto` DECIMAL(6,2) ZEROFILL NULL,
  PRIMARY KEY (`idServico`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `petshop`.`PET`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `petshop`.`PET` (
  `idPET` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(45) NOT NULL,
  `idade` INT NULL,
  `especie` VARCHAR(45) NOT NULL,
  `raca` VARCHAR(45) NOT NULL,
  `cor` VARCHAR(45) NOT NULL,
  `porte` VARCHAR(45) NULL,
  `peso` DECIMAL(5,2) NULL,
  `alergia` VARCHAR(80) NULL,
  `obs` VARCHAR(150) NULL,
  `Cliente_cpf` VARCHAR(14) NOT NULL,
  PRIMARY KEY (`idPET`),
  INDEX `fk_PET_Cliente1_idx` (`Cliente_cpf` ASC)  ,
  CONSTRAINT `fk_PET_Cliente1`
    FOREIGN KEY (`Cliente_cpf`)
    REFERENCES `petshop`.`Cliente` (`cpf`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `petshop`.`itensServico`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `petshop`.`itensServico` (
  `Empregado_cpf` VARCHAR(14) NOT NULL,
  `Servico_idServico` INT NOT NULL,
  `Venda_idVenda` INT NOT NULL,
  `PET_idPET` INT NOT NULL,
  `quantidade` INT NOT NULL,
  `valor` DECIMAL(6,2) ZEROFILL NOT NULL,
  `desconto` DECIMAL(4,2) ZEROFILL NULL,
  PRIMARY KEY (`Empregado_cpf`, `Servico_idServico`, `Venda_idVenda`, `PET_idPET`),
  INDEX `fk_itensServico_Servico1_idx` (`Servico_idServico` ASC)  ,
  INDEX `fk_itensServico_Venda1_idx` (`Venda_idVenda` ASC)  ,
  INDEX `fk_itensServico_PET1_idx` (`PET_idPET` ASC)  ,
  CONSTRAINT `fk_itensServico_Empregado1`
    FOREIGN KEY (`Empregado_cpf`)
    REFERENCES `petshop`.`Empregado` (`cpf`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_itensServico_Servico1`
    FOREIGN KEY (`Servico_idServico`)
    REFERENCES `petshop`.`Servico` (`idServico`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_itensServico_Venda1`
    FOREIGN KEY (`Venda_idVenda`)
    REFERENCES `petshop`.`Venda` (`idVenda`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_itensServico_PET1`
    FOREIGN KEY (`PET_idPET`)
    REFERENCES `petshop`.`PET` (`idPET`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `petshop`.`FormaPgVenda`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `petshop`.`FormaPgVenda` (
  `idFormaPgVenda` INT NOT NULL AUTO_INCREMENT,
  `tipo` VARCHAR(45) NOT NULL,
  `valorPago` DECIMAL(7,2) ZEROFILL NOT NULL,
  `Venda_idVenda` INT NOT NULL,
  PRIMARY KEY (`idFormaPgVenda`),
  INDEX `fk_formaPgVenda_Venda1_idx` (`Venda_idVenda` ASC)  ,
  CONSTRAINT `fk_formaPgVenda_Venda1`
    FOREIGN KEY (`Venda_idVenda`)
    REFERENCES `petshop`.`Venda` (`idVenda`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `petshop`.`Endereco`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `petshop`.`Endereco` (
  `Cliente_cpf` VARCHAR(14) NOT NULL,
  `uf` CHAR(2) NOT NULL,
  `cidade` VARCHAR(45) NOT NULL,
  `bairro` VARCHAR(45) NOT NULL,
  `rua` VARCHAR(45) NOT NULL,
  `numero` INT NULL,
  `comp` VARCHAR(45) NULL,
  `cep` CHAR(9) NOT NULL,
  PRIMARY KEY (`Cliente_cpf`),
  CONSTRAINT `fk_Endereco_Cliente1`
    FOREIGN KEY (`Cliente_cpf`)
    REFERENCES `petshop`.`Cliente` (`cpf`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `petshop`.`Produtos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `petshop`.`Produtos` (
  `idProduto` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(45) NOT NULL,
  `quantidade` DECIMAL(6,2) NOT NULL,
  `marca` VARCHAR(45) NOT NULL,
  `dataVenc` DATE NULL,
  `valorVenda` DECIMAL(6,2) ZEROFILL NOT NULL,
  `precoCusto` DECIMAL(6,2) ZEROFILL NOT NULL,
  PRIMARY KEY (`idProduto`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `petshop`.`ItensVendaProd`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `petshop`.`ItensVendaProd` (
  `Venda_idVenda` INT NOT NULL,
  `Produto_idProduto` INT NOT NULL,
  `quantidade` DECIMAL(6,2) NOT NULL,
  `valor` DECIMAL(6,2) ZEROFILL NOT NULL,
  `desconto` DECIMAL(4,2) NULL,
  INDEX `fk_Venda_has_Produto_Produto1_idx` (`Produto_idProduto` ASC)  ,
  INDEX `fk_Venda_has_Produto_Venda1_idx` (`Venda_idVenda` ASC)  ,
  PRIMARY KEY (`Venda_idVenda`, `Produto_idProduto`),
  CONSTRAINT `fk_Venda_has_Produto_Venda1`
    FOREIGN KEY (`Venda_idVenda`)
    REFERENCES `petshop`.`Venda` (`idVenda`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Venda_has_Produto_Produto1`
    FOREIGN KEY (`Produto_idProduto`)
    REFERENCES `petshop`.`Produtos` (`idProduto`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `petshop`.`Fornecedor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `petshop`.`Fornecedor` (
  `cpf_cnpj` VARCHAR(15) NOT NULL,
  `nome` VARCHAR(45) NOT NULL,
  `valorFrete` DECIMAL(6,2) ZEROFILL NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`cpf_cnpj`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC)  )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `petshop`.`Compras`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `petshop`.`Compras` (
  `idCompra` INT NOT NULL AUTO_INCREMENT,
  `dataComp` DATETIME NOT NULL,
  `valorTotal` DECIMAL(7,2) ZEROFILL NOT NULL,
  `dataVenc` DATE NOT NULL,
  `dataPag` DATETIME NULL,
  `desconto` DECIMAL(4,2) NULL,
  `juros` DECIMAL(5,2) ZEROFILL NULL,
  `Fornecedor_cpf_cnpj` VARCHAR(15) NOT NULL,
  PRIMARY KEY (`idCompra`),
  INDEX `fk_Compras_Fornecedor1_idx` (`Fornecedor_cpf_cnpj` ASC)  ,
  CONSTRAINT `fk_Compras_Fornecedor1`
    FOREIGN KEY (`Fornecedor_cpf_cnpj`)
    REFERENCES `petshop`.`Fornecedor` (`cpf_cnpj`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `petshop`.`ItensCompra`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `petshop`.`ItensCompra` (
  `Compras_idCompra` INT NOT NULL,
  `Produtos_idProduto` INT NOT NULL,
  `quantidade` DECIMAL(6,2) NOT NULL,
  `valorCompra` DECIMAL(7,2) ZEROFILL NOT NULL,
  PRIMARY KEY (`Compras_idCompra`, `Produtos_idProduto`),
  INDEX `fk_Compras_has_Produtos_Produtos1_idx` (`Produtos_idProduto` ASC)  ,
  INDEX `fk_Compras_has_Produtos_Compras1_idx` (`Compras_idCompra` ASC)  ,
  CONSTRAINT `fk_Compras_has_Produtos_Compras1`
    FOREIGN KEY (`Compras_idCompra`)
    REFERENCES `petshop`.`Compras` (`idCompra`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Compras_has_Produtos_Produtos1`
    FOREIGN KEY (`Produtos_idProduto`)
    REFERENCES `petshop`.`Produtos` (`idProduto`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `petshop`.`FormaPagCompra`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `petshop`.`FormaPagCompra` (
  `idFormaPagCompra` INT NOT NULL AUTO_INCREMENT,
  `tipo` VARCHAR(45) NOT NULL,
  `valorPago` DECIMAL(7,2) ZEROFILL NOT NULL,
  `Compras_idCompra` INT NOT NULL,
  PRIMARY KEY (`idFormaPagCompra`),
  INDEX `fk_FormaPagCompra_Compras1_idx` (`Compras_idCompra` ASC)  ,
  CONSTRAINT `fk_FormaPagCompra_Compras1`
    FOREIGN KEY (`Compras_idCompra`)
    REFERENCES `petshop`.`Compras` (`idCompra`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `petshop`.`Telefone`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `petshop`.`Telefone` (
  `idTelefone` INT NOT NULL AUTO_INCREMENT,
  `numero` VARCHAR(11) NOT NULL,
  `Empregado_cpf` VARCHAR(14) NULL,
  `Departamento_idDepartamento` INT NULL,
  `Fornecedor_cpf_cnpj` VARCHAR(15) NULL,
  PRIMARY KEY (`idTelefone`),
  INDEX `fk_Telefone_Empregado1_idx` (`Empregado_cpf` ASC)  ,
  INDEX `fk_Telefone_Departamento1_idx` (`Departamento_idDepartamento` ASC)  ,
  INDEX `fk_Telefone_Fornecedor1_idx` (`Fornecedor_cpf_cnpj` ASC)  ,
  CONSTRAINT `fk_Telefone_Empregado1`
    FOREIGN KEY (`Empregado_cpf`)
    REFERENCES `petshop`.`Empregado` (`cpf`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Telefone_Departamento1`
    FOREIGN KEY (`Departamento_idDepartamento`)
    REFERENCES `petshop`.`Departamento` (`idDepartamento`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Telefone_Fornecedor1`
    FOREIGN KEY (`Fornecedor_cpf_cnpj`)
    REFERENCES `petshop`.`Fornecedor` (`cpf_cnpj`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Aprendendo ALTER TABLE
-- -----------------------------------------------------

alter table pet 
	add column foto blob null;

-- desc pet;

alter table pet
	drop column foto;

alter table pet 
	add column foto blob null after obs;

alter table pet	
	change column cor corPet varchar(15) not null;
    
-- select * from pet;

INSERT INTO CLIENTE(cpf, nome, numTelefone, numTelefone2, email)
VALUES
('017.503.885-61','MARIZA FAUSTO DA SILVA','81761527003','81591527003','marizafaustodasilva@gmail.com'),
('045.431.132-09','DISTRIBUIDORA ORIAN','81761451049','81591451049','distribuidoraorian@gmail.com'),
('055.293.993-55','LIANILDE DA SILVA E SILVA','81766196074','81596196074','lianildedasilvaesilva@gmail.com'),
('064.542.923-63','MERCADINHO E OLIVEIRA','81765130726','81595130726','mercadinhoeoliveira@gmail.com'),
('427.617.433-34','BAR E RESTAURANTE CABANA DO SOL','81764535472','81594535472','barerestaurantecabanadosol@gmail.com'),
('380.297.822-68','JOSIMARI DA CONCEICAO DOS SANTOS ARAUJO','81761301714','81591301714','josimaridaconceicaodossantosaraujo@gmail.com'),
('075.256.043-39','COMERCIAL CARDOSO','81764423206','81594423206','comercialcardoso@gmail.com'),
('401.366.803-30','LANCHE ZE MONTEIRO','81765285311','81595285311','lanchezemonteiro@gmail.com'),
('850.289.911-20','MERCEARIA GM','81764087372','81594087372','merceariagm@gmail.com'),
('805.120.623-15','COMERCIAL FAMILIA','81761482972','81591482972','comercialfamilia@gmail.com'),
('023.959.573-48','MERCEARIA DA AUREA','81765443856','81595443856','merceariadaaurea@gmail.com'),
('604.295.233-19','MINI BOX SA','81765164227','81595164227','miniboxsa@gmail.com'),
('088.878.253-51','PANIFICADORA QUERO MAIS','81765277410','81595277410','panificadoraqueromais@gmail.com'),
('328.373.483-68','MERCANTIL SAO FRANCISCO','81769712346','81599712346','mercantilsaofrancisco@gmail.com'),
('625.499.783-58','AVISTAO BOM PRECO','81764647705','81594647705','avistaobompreco@gmail.com'),
('023.837.513-75','COMERCIAL ALMEIDA','81768872609','81598872609','comercialalmeida@gmail.com'),
('614.784.393-19','DISTRIBUIDORA GIRA RAPIDO','81764683440','81594683440','distribuidoragirarapido@gmail.com'),
('635.111.523-05','BAR DO ROBERTO','81761741592','81591741592','bardoroberto@gmail.com'),
('034.113.953-03','NATALIANA DOS SANTOS','81761450831','81591450831','natalianadossantos@gmail.com'),
('972.287.963-49','BUTECO DO TOTO','81762301218','81592301218','butecodototo@gmail.com'),
('009.849.462-76','PANIFICADORA ALVORADA','81765988001','81595988001','panificadoraalvorada@gmail.com'),
('304.523.923-49','GEOVAN TEIXEIRA DA SILVA','81761026772','81591026772','geovanteixeiradasilva@gmail.com'),
('615.869.543-26','MERCANTIL ECONOMICO','81762324123','81592324123','mercantileconomico@gmail.com'),
('021.192.333-81','REURY VARIEDADES','81764087226','81594087226','reuryvariedades@gmail.com'),
('467.309.233-34','COMERCIAL SANTISTA','81761820009','81591820009','comercialsantista@gmail.com'),
('418.178.423-15','COMERCIAL SANCHES','81761375776','81591375776','comercialsanches@gmail.com'),
('332.925.233-20','RESTAURANTE DO ZEQUINHA','81765671340','81595671340','restaurantedozequinha@gmail.com'),
('030.926.143-05','ADEGA PRIMIUS','81761560992','81591560992','adegaprimius@gmail.com'),
('022.930.503-27','MANOS MAGAZINE','81761533177','81591533177','manosmagazine@gmail.com'),
('010.169.993-05','COMERCIAL BUDI','81764708398','81594708398','comercialbudi@gmail.com'),
('604.569.393-00','VERD FRUT','81764549887','81594549887','verdfrut@gmail.com'),
('070.762.033-32','CM VARIEDADES','81764218812','81594218812','cmvariedades@gmail.com'),
('482.603.983-20','COMERCIAL SAO RAIMUNDO','81765856814','81595856814','comercialsaoraimundo@gmail.com'),
('016.014.351-93','RODRIGO PEREIRA DA SILVA','8176022120','8159022120','rodrigopereiradasilva@gmail.com'),
('019.659.463-48','COMERCIAL GUERREIRO','81761033272','81591033272','comercialguerreiro@gmail.com'),
('005.710.583-96','ARAO BEBIDAS','81763140042','81593140042','araobebidas@gmail.com'),
('003.523.273-08','BAR DO PEDRO','81761521091','81591521091','bardopedro@gmail.com'),
('413.281.323-15','CHURRASCO DO BRANCO','81761548495','81591548495','churrascodobranco@gmail.com'),
('067.903.783-75','DISTRIBUIDORA 3 IRMAOS','81764202311','81594202311','distribuidora3irmaos@gmail.com'),
('099.710.403-10','CARLOS EDUARDO SOUSA BARROS','81761587224','81591587224','carloseduardosousabarros@gmail.com'),
('040.409.013-39','COMERCIAL ROMEU','81761922798','81591922798','comercialromeu@gmail.com'),
('894.146.164-20','CONSTRUCAO FERREIRA','81765302343','81595302343','construcaoferreira@gmail.com'),
('714.537.093-04','BAR DO TREVO','81761133292','81591133292','bardotrevo@gmail.com'),
('189.249.992-49','MERCEARIA ALIANCA','81765136580','81595136580','merceariaalianca@gmail.com'),
('437.902.888-70','RR DISTRIBUIDORA','81761486145','81591486145','rrdistribuidora@gmail.com'),
('874.206.782-00','MERCADINHO KM','81764670578','81594670578','mercadinhokm@gmail.com'),
('426.607.349-68','JORGE VOLNEI RIEDEL','81764269409','81594269409','jorgevolneiriedel@gmail.com'),
('600.248.883-97','LANCH E PAD PIMENTA','81764655353','81594655353','lanchepadpimenta@gmail.com'),
('001.172.372-64','PANIFICADORA DELICIA','81762180850','81592180850','panificadoradelicia@gmail.com'),
('007.397.782-93','PANIFICADORA DELICIA','81765443293','81595443293','panificadoradelicia2@gmail.com'),
('052.144.533-70','JOAO DE AZEVEDO TROVAO NETO','81768888888','81598888888','joaodeazevedotrovaoneto@gmail.com'),
('613.346.283-35','SUPERMERCADO NUNES','81761135369','81591135369','supermercadonunes@gmail.com'),
('128.238.898-33','JOSE RAIMUNDO DE SOUSA PEREIRA','81764817252','81594817252','joseraimundodesousapereira@gmail.com'),
('067.233.053-96','MERCADINHO MENDES','81764818310','81594818310','mercadinhomendes@gmail.com'),
('288.583.282-72','MARCOS ANTONIO SILVA','8176167983','8159167983','marcosantoniosilva@gmail.com'),
('025.227.879-85','ADILSON LUIZ MIKULSKI','8176326136','8159326136','adilsonluizmikulski@gmail.com'),
('051.621.513-27','COMERCIAL NEVES','81764386175','81594386175','comercialneves@gmail.com'),
('756.320.633-72','JP CLUBE','81761652962','81591652962','jpclube@gmail.com'),
('109.854.594-09','BAR DO TULIO','81765124512','81595124512','bardotulio@gmail.com'),
('602.416.203-09','LIDER CONSTRUCAO','81761264344','81591264344','liderconstrucao@gmail.com'),
('079.265.643-11','MINI BOX FILHO','81761243428','81591243428','miniboxfilho@gmail.com'),
('612.479.903-03','COMERCIAL NILSON','81761595782','81591595782','comercialnilson@gmail.com'),
('476.474.773-15','POUSADA PEDRA GRANDE','81760106392','81590106392','pousadapedragrande@gmail.com'),
('614.594.223-17','ARMAZEM GUIMARAES','81765380738','81595380738','armazemguimaraes@gmail.com'),
('002.887.693-84','TELE BAR','81762633132','81592633132','telebar@gmail.com'),
('251.906.283-53','MERCEARIA JJ','81762056568','81592056568','merceariajj@gmail.com'),
('711.629.411-20','COMERCIAL POSITIVO','81764045313','81594045313','comercialpositivo@gmail.com'),
('025.045.663-01','LANCHES BIG GELA','81764430240','81594430240','lanchesbiggela@gmail.com'),
('009.755.703-07','BAR DA JAQUELINE','81761083252','81591083252','bardajaqueline@gmail.com'),
('062.908.133-66','BAR DO CLEO','81764140226','81594140226','bardocleo@gmail.com'),
('627.700.475-15','REGINALDO MARIANO DE SOUZA','81766658674','81596658674','reginaldomarianodesouza@gmail.com'),
('987.869.972-20','ACOUGUE BOM PRECO','81765261806','81595261806','acouguebompreco@gmail.com'),
('623.850.793-48','COMERCIAL COLINS','81768184233','81598184233','comercialcolins@gmail.com'),
('863.349.303-97','ROBERTO ALVES NOGUEIRA JUNIOR','81768058578','81598058578','robertoalvesnogueirajunior@gmail.com'),
('060.065.592-00','Albaniza Franca','8176300794','8159300794','albanizafranca@gmail.com'),
('291.978.132-49','ORICELIO ALVES DE ARAUJO','81764198401','81594198401','oricelioalvesdearaujo@gmail.com'),
('036.535.673-51','LUIS FERNANDO DA CUNHA DE OLIVEIRA','81762148854','81592148854','luisfernandodacunhadeoliveira@gmail.com'),
('951.702.193-34','COMERCIAL SAO PEDRO','81764792845','81594792845','comercialsaopedro@gmail.com'),
('050.047.203-39','BRASAO BAR','81765390325','81595390325','brasaobar@gmail.com'),
('715.684.214-51','EMILY BARBOSA DOS SANTOS','81767722270','81597722270','emilybarbosadossantos@gmail.com'),
('727.506.504-53','SEVERINO DO RAMOS HENRIQUE DA SILVA','81768284031','81598284031','severinodoramoshenriquedasilva@gmail.com'),
('227.219.083-91','MARIA LUCIA F DE MORAIS','81768219877','81598219877','marialuciafdemorais@gmail.com'),
('012.410.163-13','COMERCIAL J FERREIRA','81767363354','81597363354','comercialjferreira@gmail.com'),
('612.509.353-00','EDU BEBIDAS','81765213850','81595213850','edubebidas@gmail.com'),
('616.054.243-58','AURIEMERSON DE JESUS FARIAS DOS SANTOS','81768218905','81598218905','auriemersondejesusfariasdossantos@gmail.com'),
('960.628.353-49','COMERCIAL PRIMO','81761187232','81591187232','comercialprimo@gmail.com'),
('008.319.082-11','RAFAEL SOUZA OLIVEIRA','81761093839','81591093839','rafaelsouzaoliveira@gmail.com'),
('258.059.008-07','DISTRIBUIDORA GELA GUELA','81763314152','81593314152','distribuidoragelaguela@gmail.com'),
('844.048.333-34','NAZIEL COSTA FRANCO','81765026585','81595026585','nazielcostafranco@gmail.com'),
('714.500.801-70','CAMILE LIMA VIANA','81762520129','81592520129','camilelimaviana@gmail.com'),
('937.661.733-91','MERCEARIA SALES','81761091309','81591091309','merceariasales@gmail.com'),
('621.211.123-59','DISTRIBUIDORA RP','81764405060','81594405060','distribuidorarp@gmail.com'),
('323.671.788-28','ARTUR KIRSHNICK JUNIOR','8176938072','8159938072','arturkirshnickjunior@gmail.com'),
('931.084.949-53','SONIA MARIA KLIVER','8176364476','8159364476','soniamariakliver@gmail.com'),
('619.362.473-21','SILVANETE MOTA LIMA NOGUEIRA','81764895451','81594895451','silvanetemotalimanogueira@gmail.com'),
('080.107.083-05','KEVENLLY FERREIRA CARVALHO','81764768807','81594768807','kevenllyferreiracarvalho@gmail.com'),
('291.072.293-72','BAR DO EDVAN','81764121664','81594121664','bardoedvan@gmail.com'),
('618.729.783-04','COMERCIAL JN','81764904003','81594904003','comercialjn@gmail.com'),
('004.662.603-42','OLIVAN BATISTA DE SOUSA','81769025519','81599025519','olivanbatistadesousa@gmail.com'),
('878.462.093-53','MERCEARIA ABREU','81764244484','81594244484','merceariaabreu@gmail.com');

INSERT INTO endereco(cliente_cpf, uf, cidade, bairro, rua, numero, comp, cep)
VALUES
('017.503.885-61','AL','ARAPIRACA','CENTRO','RUA MANOEL DOS SANTOS COSTA','154','','57302768'),
('045.431.132-09','MA','BACABAL','CENTRO','CJ EURICO GASPAR DUTRA','42','','65700000'),
('055.293.993-55','MA','BREJO DA AREIA','CENTRO','RUA DOS PINTOS',NULL,'','65315000'),
('064.542.923-63','MA','NOVA OLINDA-MA','CENTRO','TV DO COMERCIO','1092','','65274000'),
('427.617.433-34','MA','SITIO NOVO - MA','CENTRO','RUA PRINCIPAL KM 12',NULL,'','65925000'),
('380.297.822-68','PA','BARCARENA','CLE URBANO VILA DOS CABANOS','RUA GERMANO ARANHA','32','','68445000'),
('075.256.043-39','MA','SANTA LUZIA','ACAMPAMENTO','TV SAO FRANCISCO I','03','','65390000'),
('401.366.803-30','MA','RIACHAO','CENTRO','AVENIDA RODOVIARIA','35','','65990000'),
('850.289.911-20','MA','BURITIRANA','CENTRO','RUA MARECHAL',NULL,'','65935000'),
('805.120.623-15','MA','SEN LA ROCQUE','GENIPAPO','RUA SAO FRANCISCO',NULL,'','65935000'),
('023.959.573-48','MA','BURITIRANA','POVOADO TANQUE II','RUA BOM JESUS',NULL,'','65935000'),
('604.295.233-19','MA','AMARANTE DO MA','VILA DEUSIMAR','RUA MARIO VIANA',NULL,'','65923000'),
('088.878.253-51','MA','BARRA DO CORDA','NENZINHO III','RUA 05',NULL,'','65950000'),
('328.373.483-68','MA','BOM JESUS SELVA','CENTRO','RUA CAXIAS','117','','65395000'),
('625.499.783-58','MA','FERNANDO FALCAO','CENTRO','RUA ANTONIO PEREIRA SANTIAGO',NULL,'','65964000'),
('023.837.513-75','MA','A A DO PINDARE','ZONA RURAL','RUA NOVA',NULL,'','65398000'),
('614.784.393-19','MA','PARAIBANO','CENTRO','AVENIDA PRIMEIRO DE MAIO',NULL,'','65670000'),
('635.111.523-05','MA','SUCUP DO NORTE','CENTRO','RUA MACALA B CARNEIRO',NULL,'','65860000'),
('034.113.953-03','MA','PACO DO LUMIAR','VILA SAO JOSE 2','TRAV 7','28','VILA SAO JOSE ','65130000'),
('972.287.963-49','MA','AMARANTE DO MA','CENTRO','RUA CASTELO BRANCO','61','','65923000'),
('009.849.462-76','PA','SANTA IZA DO PA','SANTA LUCIA','RODOVIA PA 140',NULL,'','68790000'),
('304.523.923-49','MA','PEDREIRAS','SAO FRANCISCO','RUA RAIMUNDO ANSELMO','31','','65725000'),
('615.869.543-26','MA','ROSARIO','CENTRO','RUA GALL LOTT',NULL,'','65150000'),
('021.192.333-81','MA','TUNTUM','POV SANTA ROSA','AVENIDA SAO JOAO',NULL,'','65763000'),
('467.309.233-34','MA','TIMBIRAS','CENTRO','AVENIDA JOAO LEAL','37','','65420000'),
('418.178.423-15','MA','PINHEIRO - MA','FOMENTO','RUA 12 DE OUTUBRO','279','','65200000'),
('332.925.233-20','MA','S VICENTE FERRE','CENTRO','RUA GETULIO VARGAS',NULL,'','65220000'),
('030.926.143-05','MA','PINHEIRO - MA','CENTRO','AVENIDA TANCREDO NEVES',NULL,'','65200000'),
('022.930.503-27','MA','CAROLINA','CENTRO','AVENIDA ADALBERTO RIBEIRO','637','','65980000'),
('010.169.993-05','MA','A A DO PINDARE','ZONA RURAL','RUA DA MATRIZ',NULL,'','65398000'),
('604.569.393-00','MA','MARANHAOZINHO','CENTRO','RUA DA IGREJA',NULL,'','65283000'),
('070.762.033-32','MA','LAGOA DO MATO','CENTRO','RUA SAO JOAO','49','','65683000'),
('482.603.983-20','MA','SAO BENTO - MA','MUTIRAO','RUA ANTONIO DIAS','45','','65235000'),
('016.014.351-93','PA','NOVO PROGRESSO','VICINAL CEMITERIO','RODOVIA BR 163 KM 942 ME ADT 18 KM',NULL,'','68193000'),
('019.659.463-48','MA','BURITICUPU','CENTRO','RUA DO COMERCIO',NULL,'','65393000'),
('005.710.583-96','MA','BURITICUPU','CENTRO','RUA NIVEL MEDIO','7','','65393000'),
('003.523.273-08','MA','SUCUP DO NORTE','CENTRO','RUA MANOEL OLIVEIRA','359','','65860000'),
('413.281.323-15','MA','SUCUP DO NORTE','CENTRO','RUA JOAO FIGUEIREDO',NULL,'','65860000'),
('067.903.783-75','MA','PARAIBANO','CENTRO','RUA ANTONIO SABINO',NULL,'','65670000'),
('099.710.403-10','MA','GRAJAU','CANOEIRO','RUA HUMBERTO DE CAMPOS','264','','65940000'),
('040.409.013-39','MA','SUCUP DO NORTE','CENTRO','RUA MACALA B CARNEIRO',NULL,'','65860000'),
('894.146.164-20','MA','NOVA OLINDA-MA','CENTRO','TRAVESSA SAO FRANCISCO','690','','65274000'),
('714.537.093-04','MA','LORETO','SANTA FE','TV 2 DE MAIO',NULL,'','65895000'),
('189.249.992-49','MA','RIACHAO','AEROPORTO','RUA AEROPORTO',NULL,'','65990000'),
('437.902.888-70','MA','BARRA DO CORDA','PIQUIZINHO','VILA DANTAS','30','','65950000'),
('874.206.782-00','MA','S JOAO DO CARU','CENTRO','RUA NOVA',NULL,'','65385000'),
('426.607.349-68','MA','URBANO SANTOS','ZONA RURAL','POV CAPAO I',NULL,'','65530000'),
('600.248.883-97','MA','MORROS','POV SANTA HELENA','POVOAD SANTA HELENA',NULL,'','65160000'),
('001.172.372-64','PA','CAPANEMA','FATIMA','AVENIDA JOAO PAULO II','743','','68700000'),
('007.397.782-93','PA','CAPANEMA','SANTA LUZIA','RUA SAO SEBASTIAO',NULL,'','68700000'),
('052.144.533-70','MA','SAO LUIS','ANJO DA GUARDA','RUA','5','','65000000'),
('613.346.283-35','MA','BALSAS','POVOADO BATAVO','AVENIDA BATAVO',NULL,'','65800000'),
('128.238.898-33','MA','PARAIBANO','CENTRO','AVENIDA 1 DE MAIO','1093','','65670000'),
('067.233.053-96','MA','PARAIBANO','CENTRO','RUA SAO BRAZ',NULL,'','65670000'),
('288.583.282-72','MA','SANTA RITA','ZONA RURAL','POV VILA NOVA',NULL,'','65145000'),
('025.227.879-85','MA','SITIO NOVO - MA','ZONA RURAL','LUG DA DATA SANTANA',NULL,'','65925000'),
('051.621.513-27','MA','ZE DOCA','ZONA RURAL','RUA JATAY','01','','65365000'),
('756.320.633-72','MA','ITAIPAVA DO GRA','POVOADO CRIOLIZINHO','RUA DO COMERCIO',NULL,'','65948000'),
('109.854.594-09','MA','JENIP VIEIRAS','CENTRO','RUA DO COMERCIO',NULL,'','65962000'),
('602.416.203-09','MA','VARGEM GRANDE','CENTRO','ROD BR 222','30','','65430000'),
('079.265.643-11','MA','VARGEM GRANDE','CENTRO','RUA HERMETERIO LEITAO','565','','65430000'),
('612.479.903-03','MA','NINA RODRIGUES','SANTANA','RUA DA PAZ','17','','65450000'),
('476.474.773-15','MA','MORROS','PAULINOS','RODOVIA MA 402 KM2',NULL,'','65160000'),
('614.594.223-17','MA','RIACHAO','ALTO BONITO','RUA ARAME','10','','65990000'),
('002.887.693-84','MA','LORETO','CENTRO','AVENIDA GETULIO VARGAS',NULL,'','65895000'),
('251.906.283-53','MA','GRAJAU','REMANSO','AVENIDA ROSEANA SARNEY','474','','65940000'),
('711.629.411-20','MA','SAO DOM AZEITAO','CENTRO','RUA DO CAMPO',NULL,'','65888000'),
('025.045.663-01','MA','ROSARIO','CENTRO','RUA ESTEFANIO SALDANHA','4025','','65150000'),
('009.755.703-07','MA','SUCUP DO NORTE','CENTRO','RUA CLODOALDO GUIMARAES',NULL,'','65860000'),
('062.908.133-66','MA','ITAIPAVA DO GRA','CENTRO','RUA MERCIEL ARRUDA',NULL,'','65948000'),
('627.700.475-15','PA','PARAUAPEBAS','CIDADE NOVA','RUA A','0','','68515000'),
('987.869.972-20','MA','JENIP VIEIRAS','VALETA','AVENIDA FELIPE NERES',NULL,'','65962000'),
('623.850.793-48','MA','SANTA RITA','CAREMA','AVENIDA GAL RIBAS','78','','65145000'),
('863.349.303-97','MA','CAXIAS','COHAB','AVENIDA BEIJAMIN CONSTANT','2163','','65600010'),
('060.065.592-00','PA','ANANINDEUA','COQUEIRO','Rua C','1','','67113330'),
('291.978.132-49','MA','ZE DOCA','CENTRO','RUA 7 DE SETEMBRO','166','','65365000'),
('036.535.673-51','MA','OLHO D AGUA CUN','POVOADO BACURI DA LINHA','RUA GRANDE BACURI DA LINHA','272','','65706000'),
('951.702.193-34','MA','LAGOA DO MATO','CENTRO','RUA PIRANHAS',NULL,'','65683000'),
('050.047.203-39','MA','LAGOA DO MATO','CENTRO','RUA SUCUPIRAS',NULL,'','65683000'),
('715.684.214-51','PB','CAMPINA GRANDE','SANTA CRUZ','RUA FRANCISCO LOPES DE ALMEIDA','847','CASA','58418000'),
('727.506.504-53','PB','PIRPIRITUBA','CENTRO','RUA CORDEIRO DE MELO','240','','58213000'),
('227.219.083-91','PI','TERESINA','PROMORAR','QD 99 LT 12 CS B','12','','64045000'),
('012.410.163-13','MA','SAO BENTO - MA','CENTRO','RUA JOAO ALVES',NULL,'','65235000'),
('612.509.353-00','MA','LORETO','POV BURITIRANA','RODOVIA BR 230',NULL,'','65895000'),
('616.054.243-58','MA','PINHEIRO - MA','MATRIZ','RUA ANTENOR ABREU','497','','65200000'),
('960.628.353-49','MA','SANTA INES','AGUA FRIA','RUA NOVA ISRAEL JERUSALEM',NULL,'','65300000'),
('008.319.082-11','PA','TAILANDIA-PA','NOVO','RUA 06 QUADRA 11 LOTE 42','42','','68695000'),
('258.059.008-07','MA','JENIP VIEIRAS','CENTRO','RUA VALETA CENTRO AVENIDA FELIPE NERES',NULL,'','65962000'),
('844.048.333-34','MA','CARUTAPERA','CENTRO','TV SAO SEBASTIAO','99','','65295000'),
('714.500.801-70','MA','VITORINO FREIRE','JUCARAL DOS SARAIVAS','RUA DEP EDSON LOBAO','5','','65320000'),
('937.661.733-91','MA','TIMBIRAS','CENTRO','RUA SENADOR S ARCHER','115','','65420000'),
('621.211.123-59','MA','ITAIPAVA DO GRA','CENTRO','RUA PRINCIPAL',NULL,'','65948000'),
('323.671.788-28','MA','COELHO NETO','ZONA RURAL','POVOADO SANTANA VELHA',NULL,'','65620000'),
('931.084.949-53','MA','ANAPURUS','ZONA RURAL','FAZ GUABIRABA II',NULL,'','65525000'),
('619.362.473-21','MA','S VICENTE FERRE','MUTIRAO I','RUA DA IGREJA',NULL,'','65220000'),
('080.107.083-05','MA','PRES DUTRA','VILA MILITAR','RUA 28 DE JULHO',NULL,'','65760000'),
('291.072.293-72','MA','ITAIPAVA DO GRA','CENTRO','RUA RAIMUNDO CERQUEIRA','10','','65948000'),
('618.729.783-04','MA','S B RIO PRETO','CENTRO','TRAVESSA JOAO SOUSA',NULL,'','65440000'),
('004.662.603-42','PI','TERESINA','SAO JOAQUIM','RUA BARBOSA QD2',NULL,'','64005355'),
('878.462.093-53','MA','GOV NUNES FREIR','AEROPORTO','RUA PARADA','1','','65284000');

INSERT INTO fornecedor(cpf_cnpj, nome, valorFrete, email)
VALUES
('584.184.315-04'    ,'GILMAR AMARAL SANTOS'                              ,26.24,'gilmaramaralsantos@email.com'                          ),
('452.248.353-80'    ,'FLAVIO OLIVEIRA BARRETO'                           , 7.56,'flaviooliveirabarreto@email.com'                       ),
('824.491.635-49'    ,'FABIO JOSE DOS SANTOS'                             ,49.81,'fabiojosedossantos@email.com'                          ),
('116231880008-17','ARMAZEM CORAL LTDA'                                ,62.49,'armazemcoralltda@email.com'                            ),
('751.190.485-87'    ,'ELIZANDRA MARIA VILELA'                            , 7.67,'elizandramariavilela@email.com'                        ),
('976.372.258-60'    ,'DIOGO SOUSA SENA'                                  ,37.91,'diogosousasena@email.com'                              ),
('563.428.350-70'    ,'CARLOS ALBERTO CRUZ DE OLIVEIRA JUNIOR'            ,66.69,'carlosalbertocruzdeoliveirajunior@email.com'           ),
('608.593.559-50'    ,'ARTHUR ROCHA OLIVEIRA'                             ,41.07,'arthurrochaoliveira@email.com'                         ),
('373.320.850-10'    ,'ANILTON DA SILVA BARBOSA'                          , 3.32,'aniltondasilvabarbosa@email.com'                       ),
('552.133.957-40'    ,'ANDRE SANTOS NOGUEIRA'                             ,15.56,'andresantosnogueira@email.com'                         ),
('397.404.166-40'    ,'ANDERSON ROCHA SANTOS'                             ,89.17,'andersonrochasantos@email.com'                         ),
('153.076.658-30'    ,'ALESSANDRA SILVA GOMES'                            ,81.50,'alessandrasilvagomes@email.com'                        ),
('419296600001-29','HIPER REAL COMERCIAL DE ALIMENTOS LTDA'            ,75.89,'hiperrealcomercialdealimentosltda@email.com'           ),
('515049950001-69','ATACADISTA SANTO ANTONIO RECONCAVO LTDA'           ,46.75,'atacadistasantoantonioreconcavoltda@email.com'         ),
('546.744.532-40'    ,'MARCOS VINICIUS MELO CARDOSO DA SILVA'             ,62.18,'marcosviniciusmelocardosodasilva@email.com'            ),
('171616800001-60','LIGUE GAS GUERREIRO LTDA'                          ,88.35,'liguegasguerreiroltda@email.com'                       ),
('387668900001-00','SUPERMERCADO DO GUIL LTDA'                         ,25.24,'supermercadodoguilltda@email.com'                      ),
('134332700002-19','DTS COMERCIO DE EQUIPAMENTOS SEGURANCA ELETR' ,73.22,'dtscomerciodeequipamentosdesegura@email.com'   ),
('321.763.149-80'    ,'MANOEL FRANCA DE SALES'                            ,91.87,'manoelfrancadesales@email.com'                         ),
('122419450001-84','ANTONIO RONALDO RAIOL PINHEIRO'                    ,95.55,'antonioronaldoraiolpinheiro@email.com'                 ),
('056999490001-45','ASSOCIACAO DOS TAXISTA DE SANTA IZABEL'    ,75.83,'associacaodostaxistadesantaizabela@email.com'     ),
('048993160018-66','IMIFARMA PRODUTOS FARMACEUTICOS E COSMETICOS'   ,85.84,'imifarmaprodutosfarmaceuticose@email.com'  ),
('229599240006-67','D  FARMA LTDA'                                     ,76.42,'dfarmaltda@email.com'                                  ),
('072024270001-11','R CHAGAS E CIA LTDA'                               ,11.69,'rchagasecialtda@email.com'                             ),
('314811890001-05','R C B CAVALCANTE'                                  ,82.24,'rcbcavalcante@email.com'                               ),
('075104290001-78','V L BEZERRA'                                       ,11.98,'vlbezerra@email.com'                                   ),
('190071720001-15','CLEITON FERNANDES DA CONCEICAO'        ,27.85,'cleitonfernandesdaconceicao@email.com'      ),
('287.828.220-50'    ,'WELDEN DOS SANTOS ANTUNES'                         ,81.40,'weldendossantosantunes@email.com'                      ),
('158.556.623-30'    ,'AMILTON DA SILVA CHAVES'                           ,29.54,'amiltondasilvachaves@email.com'                        ),
('678.425.124-50'    ,'GLORIA MARIA BENTES REIS'                          ,80.96,'gloriamariabentesreis@email.com'                       ),
('425.848.172-68'    ,'WANDERLEI DO ESPIRITO SANTO'                       ,10.28,'wanderleidoespiritosanto@email.com'                    ),
('736.243.437-50'    ,'AMANDA RIBEIRO DA SILVA'                           ,26.39,'amandaribeirodasilva@email.com'                        ),
('863.971.842-34'    ,'ELIANE DA COSTA SANTOS'                            ,91.71,'elianedacostasantos@email.com'                         ),
('736.566.236-00'    ,'ANA VITORIA BATISTA DOS SANTOS'                    ,51.79,'anavitoriabatistadossantos@email.com'                  ),
('437.607.437-30'    ,'TATIANA ARAUJO'                                    ,63.03,'tatianaaraujo@email.com'                               ),
('693.364.822-20'    ,'ELIANE GOMES DE OLIVEIRA'                          ,45.57,'elianegomesdeoliveira@email.com'                       ),
('519072480001-71','MARCO CLEY SOUZA DA SILVA'                         ,54.67,'marcocleysouzadasilva@email.com'                       ),
('450.793.133-90'    ,'MIKAELA MARQUES SILVA'                             ,97.11,'mikaelamarquessilva@email.com'                         ),
('590.579.720-00'    ,'ELLEN GABRIELLA RODRIGUES DOS REIS'                ,67.36,'ellengabriellarodriguesdosreis@email.com'              ),
('134.030.320-50'    ,'MONALIZA DE SOUZA TOBIAS'                          ,48.28,'monalizadesouzatobias@email.com'                       ),
('132.772.124-40'    ,'LIVIA TAIANE SANTOS DO ROSARIO'                    , 2.03,'liviataianesantosdorosario@email.com'                  ),
('209.764.295-00'    ,'ANDREA CASTRO LISBOA'                              ,84.44,'andreacastrolisboa@email.com'                          ),
('660.932.443-34'    ,'MARIA DA LUZ DO NASCIMENTO'                        ,25.17,'mariadaluzdonascimento@email.com'                      ),
('302.452.826-10'    ,'RUTH RAFAELLE OLIVEIRA DA SILVA'                   ,20.71,'ruthrafaelleoliveiradasilva@email.com'                 ),
('678.570.432-49'    ,'GRACINETH RIBEIRO RAMOS'                           ,48.89,'gracinethribeiroramos@email.com'                       ),
('665.165.283-49'    ,'NEUMA DOS SANTOS'                                  ,39.73,'neumadossantos@email.com'                              ),
('320.717.534-10'    ,'EUNICE SILVA DO NASCIMENTO'                        ,68.73,'eunicesilvadonascimento@email.com'                     ),
('519.692.112-53'    ,'IZABELA SALEMA DA SILVA'                           ,31.66,'izabelasalemadasilva@email.com'                        ),
('516.927.027-50'    ,'HIGOR JOSE ARAUJO DOS SANTOS'                      ,28.69,'higorjosearaujodossantos@email.com'                    ),
('909.454.833-00'    ,'SAMARA DO NASCIMENTO SILVA'                        ,18.33,'samaradonascimentosilva@email.com'                     ),
('263.850.021-60'    ,'JOSE LUCIO CALANDRINI BARBOSA'                     ,61.93,'joseluciocalandrinibarbosa@email.com'                  ),
('715.350.202-53'    ,'LEITICIA DE CASSIA REIS PANTOJA'                   ,58.43,'leiticiadecassiareispantoja@email.com'                 ),
('746.845.731-00'    ,'FRANCISCA CLAUDILENE DA SILVA'                     ,70.82,'franciscaclaudilenedasilva@email.com'                  ),
('712.034.152-90'    ,'ANDREZA COSTA CAMARA'                              , 4.71,'andrezacostacamara@email.com'                          ),
('470.536.632-80'    ,'LEIDIANE BARBOSA DE OLIVEIRA'                      ,60.87,'leidianebarbosadeoliveira@email.com'                   ),
('102.263.103-96'    ,'ANA CLARA DE SOUSA SILVA'                          ,73.14,'anaclaradesousasilva@email.com'                        ),
('191.273.139-80'    ,'MARCELA VIANA DE LIMA MARTINS'                     ,75.04,'marcelavianadelimamartins@email.com'                   ),
('668.420.839-90'    ,'LETICIA RIBEIRO DA SILVA'                          ,88.07,'leticiaribeirodasilva@email.com'                       ),
('939.955.245-40'    ,'ALEXSANDRA DA SILVA SANTOS'                        ,44.79,'alexsandradasilvasantos@email.com'                     ),
('104.170.163-28'    ,'JAMILLE DE SENA SILVA'                             ,52.31,'jamilledesenasilva@email.com'                          ),
('655.836.983-49'    ,'FRANCISCA ADRIANA CORREIA COSTA'                   ,19.49,'franciscaadrianacorreiacosta@email.com'                ),
('677.791.631-80'    ,'KELLIANNY DA SILVA COSTA'                          ,22.46,'kelliannydasilvacosta@email.com'                       ),
('870.117.734-60'    ,'SUELI SOUSA DOS SANTOS'                            ,23.90,'suelisousadossantos@email.com'                         ),
('932.189.032-70'    ,'DAIANE LIMA DE OLIVEIRA'                           ,82.45,'daianelimadeoliveira@email.com'                        ),
('636.629.139-00'    ,'LUDIMYLLA DOS SANTOS FERREIRA'                     ,12.88,'ludimylladossantosferreira@email.com'                  ),
('554.884.437-70'    ,'KESSIA MARIA NASCIMENTO SOUSA'                     ,52.60,'kessiamarianascimentosousa@email.com'                  ),
('757.673.830-80'    ,'MARIA CAMILA BARBOSA DA SILVA'                     ,32.09,'mariacamilabarbosadasilva@email.com'                   ),
('222213870001-49','MOURA   SILVA LTDA'                                ,31.59,'mourasilvaltda@email.com'                              ),
('784.714.126-40'    ,'ADRIELLY COSTA CAMARA'                             ,58.25,'adriellycostacamara@email.com'                         ),
('701.679.282-01'   ,'SYRLENNE CARDOSO SOUSA'                             ,82.52,'syrlennecardososousa@email.com'                        ),
('726.326.925-20'    ,'ERICA GABRIELA OLIVEIRA MODESTO'                   ,98.28,'ericagabrielaoliveiramodesto@email.com'                ),
('266.496.520-40'    ,'KAUE SOUZA PIRANHA'                                ,16.83,'kauesouzapiranha@email.com'                            ),
('516.966.572-53'    ,'EDERSON JOSE RAMOS BEZERRA'                        ,23.70,'edersonjoseramosbezerra@email.com'                     ),
('353.194.298-00'    ,'VANESSA CANTAO DE SOUZA'                           ,77.55,'vanessacantaodesouza@email.com'                        ),
('433.649.828-80'    ,'MATHEUS DA SILVA RIBEIRO'                          ,61.59,'matheusdasilvaribeiro@email.com'                       ),
('700.398.562-40'    ,'BENEDITO LIMA BOTELHO'                             ,54.48,'beneditolimabotelho@email.com'                         ),
('386.770.425-20'    ,'RAFAEL RABELO COELHO'                              , 8.18,'rafaelrabelocoelho@email.com'                          ),
('362.512.027-50'    ,'IGOR GABRIEL UPTON SOARES'                         , 9.79,'igorgabrieluptonsoares@email.com'                      ),
('278.101.782-53'    ,'FERNANDO DE JESUS MARINHO'                         ,65.21,'fernandodejesusmarinho@email.com'                      ),
('700.406.602-90'    ,'ALAN CLAYTON BRASIL DO ROSARIO'                    ,56.30,'alanclaytonbrasildorosario@email.com'                  ),
('665.173.112-20'    ,'SHEILA CRISTINA NOVAES DA SILVA'                   ,83.60,'sheilacristinanovaesdasilva@email.com'                 ),
('664.915.922-00'    ,'SHIRLEY CRISTIANE SOUZA NOVAES'                    ,95.34,'shirleycristianesouzanovaes@email.com'                 ),
('501.373.829-60'    ,'ADRIANE RAIOL DA COSTA'                            ,82.33,'adrianeraioldacosta@email.com'                         ),
('591.146.320-20'    ,'LUIZ FERNANDO OLIVEIRA DA SILVA'                   ,51.34,'luizfernandooliveiradasilva@email.com'                 ),
('602.355.745-70'    ,'JOSE LOPES DOS SANTOS'                             ,62.01,'joselopesdossantos@email.com'                          ),
('627.580.238-30'    ,'RAFAELLY DIAS SILVA'                               ,50.76,'rafaellydiassilva@email.com'                           ),
('708.425.330-00'    ,'ALINE SILVA PEREIRA'                               ,71.44,'alinesilvapereira@email.com'                           ),
('530.006.430-00'    ,'DIANA FREITAS DA SILVA'                            ,72.90,'dianafreitasdasilva@email.com'                         ),
('541.379.232-80'    ,'CAMILA LIMA FREITAS'                               ,26.85,'camilalimafreitas@email.com'                           ),
('992.697.336-10'    ,'MARIA EDUARDA COSTA QUEIROZ'                       ,81.28,'mariaeduardacostaqueiroz@email.com'                    ),
('751.201.731-60'    ,'ISMAEL FREITAS SOUSA'                              ,52.03,'ismaelfreitassousa@email.com'                          ),
('304.953.334-00'    ,'LUCINETE BARROS PALAVRA'                           ,61.45,'lucinetebarrospalavra@email.com'                       ),
('892.356.235-10'    ,'ISABELE SANTOS DO NASCIMENTO'                      ,57.16,'isabelesantosdonascimento@email.com'                   ),
('964.989.735-60'    ,'JULIANO RODRIGUES SILVA'                           ,51.45,'julianorodriguessilva@email.com'                       ),
('716.433.133-20'    ,'ERMESON SILVA SOARES'                              ,82.26,'ermesonsilvasoares@email.com'                          ),
('463.890.329-00'    ,'TATYELLE BRAGA'                                    ,35.94,'tatyellebraga@email.com'                               ),
('101.717.983-25'    ,'RAIKKONEN DA ROCHA GOMES'                          , 7.42,'raikkonendarochagomes@email.com'                       ),
('276.825.039-20'    ,'JOAO PAULO DA SILVA DE LIMA'                       ,89.96,'joaopaulodasilvadelima@email.com'                      ),
('613.217.233-50'    ,'TAILIS CARDOSO MOTA'                               ,81.71,'tailiscardosomota@email.com'                           ),
('616.695.313-50'    ,'LIA DOS SANTOS SOUSA SANCHES'                      ,92.25,'liadossantossousasanches@email.com'                    );

INSERT INTO `petshop`.`Servico` (`nome`, `valorVenda`, `valorCusto`) VALUES
    ('Banho e Tosa - Pequeno Porte', 65.00, 45.00),
    ('Banho e Tosa - Médio Porte', 75.00, 55.00),
    ('Banho e Tosa - Grande Porte', 90.00, 70.00),
    ('Banho - Pequeno Porte', 40.00, 25.00),
    ('Banho - Médio Porte', 50.00, 35.00),
    ('Banho - Grande Porte', 60.00, 45.00),
    ('Tosa - Pequeno Porte', 35.00, 25.00),
    ('Tosa - Médio Porte', 45.00, 30.00),
    ('Tosa - Grande Porte', 55.00, 40.00),
    ('Consultas Veterinárias', 80.00, 60.00),
    ('Exames Laboratoriais', 120.00, 90.00),
    ('Vacinação Anual', 60.00, 45.00),
    ('Consulta de Urgência', 100.00, 75.00),
    ('Tratamento Odontológico', 150.00, 120.00),
    ('Hospedagem - Pequeno Porte', 50.00, 35.00),
    ('Hospedagem - Médio Porte', 60.00, 45.00),
    ('Hospedagem - Grande Porte', 70.00, 55.00),
    ('Adestramento Básico', 100.00, 80.00),
    ('Adestramento Avançado', 150.00, 120.00),
    ('Creche para Cães', 40.00, 30.00),
    ('Passeio Diário', 25.00, 20.00),
    ('Cuidados com Animais Idosos', 70.00, 55.00),
    ('Tratamento para Dermatite', 85.00, 65.00),
    ('Corte de Unhas', 15.00, 10.00),
    ('Limpeza de Ouvidos', 20.00, 15.00),
    ('Massagem Relaxante', 30.00, 25.00),
    ('Terapia Comportamental', 120.00, 90.00),
    ('Cuidados Especiais para Filhotes', 70.00, 55.00),
    ('Microchipagem', 50.00, 40.00),
    ('Desparasitação', 25.00, 20.00);

INSERT INTO PET (nome, idade, especie, raca, corPet, porte, peso, alergia, obs, Cliente_cpf)
VALUES
    ('Max', 3, 'Cachorro', 'Golden Retriever', 'Dourado', 'Grande', 30.5, NULL, NULL, '017.503.885-61'),
    ('Luna', 2, 'Cachorro', 'Labrador', 'Preto', 'Grande', 28.0, NULL, 'Alergia a pulgas', '017.503.885-61'),
    ('Whiskers', 4, 'Gato', 'Siamês', 'Marrom', 'Médio', 12.2, NULL, NULL, '045.431.132-09'),
    ('Nemo', NULL, 'Peixe', 'Beta', 'Laranja', NULL, 0.1, NULL, NULL, '055.293.993-55'),
    ('Simba', 5, 'Leão', 'Pantera', 'Marrom', 'Grande', 180.0, NULL, 'Rei da selva', '055.293.993-55'),
    ('Tweety', 1, 'Pássaro', 'Canário', 'Amarelo', 'Pequeno', 0.05, NULL, 'Canta lindas músicas', '055.293.993-55'),
    ('Daisy', 2, 'Coelho', 'Holandês', 'Branco e preto', 'Pequeno', 1.0, NULL, NULL, '064.542.923-63'),
    ('Speedy', 3, 'Tartaruga', 'Tigre-d água', 'Verde', 'Pequeno', 0.5, NULL, 'Muito lenta', '427.617.433-34'),
    ('Milo', 1, 'Hamster', 'Sírio', 'Dourado', 'Pequeno', 0.03, NULL, 'Gosta de girar na roda', '380.297.822-68'),
    ('Snickers', 4, 'Cavalo', 'Puro Sangue Árabe', 'Marrom', 'Grande', 550.0, NULL, 'Corredor veloz', '075.256.043-39'),
    ('Bella', 2, 'Cachorro', 'Bulldog', 'Marrom', 'Médio', 20.0, NULL, NULL, '075.256.043-39'),
    ('Charlie', 1, 'Cachorro', 'Poodle', 'Branco', 'Pequeno', 6.7, NULL, 'Alergia a grama', '075.256.043-39'),
    ('Lucy', 5, 'Gato', 'Maine Coon', 'Cinza', 'Grande', 16.8, NULL, NULL, '401.366.803-30'),
    ('Bubbles', NULL, 'Peixe', 'Guppi', 'Azul', NULL, 0.2, NULL, NULL, '850.289.911-20'),
    ('Leo', 4, 'Leão', 'Pantera', 'Marrom', 'Grande', 200.0, NULL, 'Majestoso', '805.120.623-15'),
    ('Rio', 1, 'Pássaro', 'Arara', 'Colorida', 'Médio', 1.2, NULL, 'Adora voar', '805.120.623-15'),
    ('Oreo', 2, 'Coelho', 'Angorá', 'Branco', 'Médio', 1.5, NULL, NULL, '023.959.573-48'),
    ('Shelly', 3, 'Tartaruga', 'Tartaruga de Caixa', 'Marrom', 'Pequeno', 0.8, NULL, 'Vive na água', '604.295.233-19'),
    ('Peanut', 1, 'Hamster', 'Chinês', 'Cinza', 'Pequeno', 0.04, NULL, 'Muito ágil', '088.878.253-51'),
    ('Spirit', 6, 'Cavalo', 'Quarto de Milha', 'Alazão', 'Grande', 600.0, NULL, 'Campeão de corrida', '328.373.483-68'),
    ('Coco', 2, 'Cachorro', 'Shih Tzu', 'Branco e marrom', 'Pequeno', 7.5, NULL, NULL, '625.499.783-58'),
    ('Buddy', 3, 'Cachorro', 'Dachshund', 'Marrom', 'Pequeno', 8.2, NULL, 'Adora cavar buracos', '023.837.513-75'),
    ('Oliver', 2, 'Gato', 'Bengal', 'Amarelo', 'Médio', 12.0, NULL, NULL, '023.837.513-75'),
    ('Goldie', NULL, 'Peixe', 'Beta', 'Dourado', NULL, 0.15, NULL, NULL, '023.837.513-75'),
    ('Rocky', 4, 'Leão', 'Pantera', 'Marrom', 'Grande', 210.0, NULL, 'Líder da savana', '614.784.393-19'),
    ('Sunny', 1, 'Pássaro', 'Periquito', 'Verde', 'Pequeno', 0.08, NULL, 'Fala algumas palavras', '614.784.393-19'),
    ('Hopper', 2, 'Coelho', 'Lionhead', 'Branco', 'Pequeno', 1.3, NULL, NULL, '614.784.393-19'),
    ('Squirt', 3, 'Tartaruga', 'Tartaruga de Pintas Vermelhas', 'Marrom', 'Pequeno', 0.9, NULL, 'Fica quieta', '635.111.523-05'),
    ('Nibbles', 1, 'Hamster', 'Roborovski', 'Dourado', 'Pequeno', 0.03, NULL, 'Sempre em movimento', '034.113.953-03'),
    ('Thunder', 7, 'Cavalo', 'Árabe', 'Preto', 'Grande', 700.0, NULL, 'Veloz como o vento', '034.113.953-03'),
    ('Ruby', 2, 'Cachorro', 'Chihuahua', 'Marrom', 'Pequeno', 3.4, NULL, NULL, '972.287.963-49'),
    ('Teddy', 3, 'Cachorro', 'Bichon Frise', 'Branco', 'Pequeno', 6.1, NULL, 'Adora brincar', '009.849.462-76'),
    ('Misty', 4, 'Gato', 'Ragdoll', 'Branco e cinza', 'Médio', 14.5, NULL, NULL, '009.849.462-76'),
    ('Bubbles', NULL, 'Peixe', 'Guppi', 'Prateado', NULL, 0.18, NULL, NULL, '304.523.923-49'),
    ('Leo', 5, 'Leão', 'Pantera', 'Marrom', 'Grande', 220.0, NULL, 'Majestoso', '615.869.543-26'),
    ('Sky', 1, 'Pássaro', 'Calopsita', 'Cinza e amarelo', 'Pequeno', 0.1, NULL, 'Canta alegremente', '021.192.333-81'),
    ('Lola', 2, 'Coelho', 'Fuzzy Lop', 'Branco e cinza', 'Médio', 1.6, NULL, NULL, '021.192.333-81'),
    ('Spike', 4, 'Tartaruga', 'Tartaruga de Casco Mole', 'Verde', 'Médio', 1.5, NULL, 'Gosta de nadar', '467.309.233-34'),
    ('Pippin', 1, 'Hamster', 'Sírio', 'Marrom', 'Pequeno', 0.02, NULL, 'Pequeno e ágil', '418.178.423-15'),
    ('Spirit', 8, 'Cavalo', 'Paint Horse', 'Alazão e branco', 'Grande', 650.0, NULL, 'Pinturas lindas', '418.178.423-15'),
    ('Lucky', 2, 'Cachorro', 'Shiba Inu', 'Vermelho', 'Médio', 17.8, NULL, NULL, '332.925.233-20'),
    ('Bella', 3, 'Cachorro', 'Pug', 'Bege', 'Pequeno', 15.3, NULL, 'Ronca bastante', '332.925.233-20'),
    ('Milo', 2, 'Gato', 'British Shorthair', 'Cinza', 'Médio', 11.7, NULL, NULL, '332.925.233-20'),
    ('Goldie', NULL, 'Peixe', 'Piranha', 'Prateado', NULL, 0.25, NULL, NULL, '030.926.143-05'),
    ('Leo', 6, 'Leão', 'Pantera', 'Marrom', 'Grande', 240.0, NULL, 'Rei da selva', '022.930.503-27'),
    ('Sunny', 2, 'Pássaro', 'Periquito Australiano', 'Verde e amarelo', 'Pequeno', 0.09, NULL, 'Canta o dia todo', '010.169.993-05'),
    ('Binky', 2, 'Coelho', 'Rex', 'Preto', 'Médio', 1.8, NULL, NULL, '010.169.993-05'),
    ('Shelly', 5, 'Tartaruga', 'Tartaruga de Espinhos', 'Verde e marrom', 'Médio', 1.7, NULL, 'Tem espinhos nas costas', '604.569.393-00'),
    ('Peanut', 1, 'Hamster', 'Chinês', 'Cinza e branco', 'Pequeno', 0.02, NULL, 'Adora girar na bola', '070.762.033-32'),
    ('Thunder', 9, 'Cavalo', 'Clydesdale', 'Castanho', 'Grande', 800.0, NULL, 'Majestoso e forte', '482.603.983-20'),
    ('Coco', 3, 'Cachorro', 'Boxer', 'Tigrado', 'Grande', 35.0, NULL, NULL, '016.014.351-93'),
    ('Buddy', 4, 'Cachorro', 'Husky Siberiano', 'Branco e preto', 'Grande', 32.6, NULL, 'Pelagem densa', '019.659.463-48'),
    ('Luna', 3, 'Gato', 'Persa', 'Branco', 'Médio', 13.4, NULL, NULL, '005.710.583-96'),
    ('Bubbles', NULL, 'Peixe', 'Piranha', 'Dourado', NULL, 0.3, NULL, NULL, '003.523.273-08'),
    ('Leo', 7, 'Leão', 'Pantera', 'Marrom', 'Grande', 250.0, NULL, 'Domina a savana', '413.281.323-15'),
    ('Sparrow', 1, 'Pássaro', 'Pardal', 'Marrom', 'Pequeno', 0.03, NULL, 'Canta melodias', '067.903.783-75'),
    ('Hopper', 3, 'Coelho', 'Holandês', 'Branco e preto', 'Médio', 2.0, NULL, NULL, '099.710.403-10'),
    ('Squirt', 6, 'Tartaruga', 'Tartaruga de Pintas Amarelas', 'Amarelo', 'Médio', 2.2, NULL, 'Adora nadar', '040.409.013-39'),
    ('Nibbles', 1, 'Hamster', 'Sírio', 'Dourado', 'Pequeno', 0.01, NULL, 'Bem pequeno', '894.146.164-20'),
    ('Spirit', 10, 'Cavalo', 'Frisão', 'Preto', 'Grande', 900.0, NULL, 'Cabelo longo', '714.537.093-04'),
    ('Ruby', 3, 'Cachorro', 'Poodle', 'Branco', 'Pequeno', 5.7, NULL, NULL, '189.249.992-49'),
    ('Teddy', 4, 'Cachorro', 'Bulldog Francês', 'Tigrado', 'Pequeno', 11.8, NULL, 'Focinho achatado', '437.902.888-70'),
    ('Misty', 5, 'Gato', 'Siamese', 'Cinza', 'Médio', 10.9, NULL, NULL, '874.206.782-00'),
    ('Goldie', NULL, 'Peixe', 'Beta', 'Laranja', NULL, 0.35, NULL, NULL, '426.607.349-68'),
    ('Leo', 8, 'Leão', 'Pantera', 'Marrom', 'Grande', 260.0, NULL, 'Rei da savana', '426.607.349-68'),
    ('Sunny', 3, 'Pássaro', 'Cacatua', 'Branca', 'Médio', 0.15, NULL, 'Fala e dança', '600.248.883-97'),
    ('Lola', 4, 'Coelho', 'Mini Rex', 'Castanho', 'Médio', 1.9, NULL, NULL, '001.172.372-64'),
    ('Spike', 6, 'Tartaruga', 'Tartaruga de Espinhos', 'Verde e marrom', 'Médio', 2.0, NULL, 'Defesa natural', '007.397.782-93'),
    ('Pippin', 2, 'Hamster', 'Russo Anão', 'Cinza', 'Pequeno', 0.02, NULL, 'Muito rápido', '052.144.533-70'),
    ('Thunder', 11, 'Cavalo', 'Morgan', 'Baio', 'Grande', 999.0, NULL, 'Elegante e forte', '613.346.283-35');

INSERT INTO DEPARTAMENTO(NOME, EMAIL, LOCALDEP,GERENTE_CPF)
VALUES
    ('Financeiro', 'financeiro@email.com','20° Andar', '111.111.111-11'),
    ('Vendas', 'vendas@email.com','10° Andar', '567.890.123-45'),
    ('Comercial', 'comercial@email.com','Terreo', '888.888.888-88');
   
INSERT INTO Empregado (cpf, nome, sexo, email, ctps, cargo, dataAdm, dataDem, salario, comissao, bonificacao, Departamento_idDepartamento)
VALUES
    ('111.111.111-11', 'Jorge Luis', 'M', 'jorge@email.com', '12345', 'Gerente', '2023-01-01', NULL, 5000.00, 500.00, 100.00, 1),
    ('222.222.222-22', 'Maria Santos', 'F', 'maria@email.com', '67890', 'Vendedor', '2023-02-15', NULL, 2500.00, 300.00, 50.00, 2),
    ('333.333.333-33', 'Carlos Souza', 'M', 'carlos@email.com', '54321', 'Atendente', '2023-03-10', NULL, 2200.00, 200.00, 30.00, 1),
    ('444.444.444-44', 'Ana Ferreira', 'F', 'ana@email.com', '98765', 'Vendedor', '2023-04-20', NULL, 2700.00, 350.00, 60.00, 3),
    ('555.555.555-55', 'Luiz Pereira', 'M', 'luiz@email.com', '13579', 'Gerente', '2023-05-05', NULL, 5200.00, 550.00, 120.00, 2),
    ('666.666.666-66', 'Fernanda Costa', 'F', 'fernanda@email.com', '24680', 'Atendente', '2023-06-30', NULL, 2300.00, 220.00, 35.00, 1),
    ('777.777.777-77', 'Ricardo Oliveira', 'M', 'ricardo@email.com', '86420', 'Vendedor', '2023-07-15', NULL, 2600.00, 320.00, 55.00, 2),
    ('888.888.888-88', 'Marta Lima', 'F', 'marta@email.com', '99999', 'Gerente', '2023-08-20', NULL, 5100.00, 500.00, 110.00, 3),
    ('999.999.999-99', 'Pedro Santos', 'M', 'pedro@email.com', '77777', 'Atendente', '2023-09-10', NULL, 2100.00, 180.00, 25.00, 1),
    ('123.456.789-01', 'Lucia Rodrigues', 'F', 'lucia@email.com', '12312', 'Vendedor', '2023-10-25', NULL, 2900.00, 380.00, 70.00, 2),
    ('234.567.890-12', 'Marcos Almeida', 'M', 'marcos@email.com', '65465', 'Gerente', '2023-11-05', NULL, 5300.00, 600.00, 130.00, 3),
    ('345.678.901-23', 'Larissa Silva', 'F', 'larissa@email.com', '98712', 'Atendente', '2023-12-15', NULL, 2400.00, 250.00, 40.00, 1),
    ('456.789.012-34', 'Gustavo Pereira', 'M', 'gustavo@email.com', '78978', 'Vendedor', '2024-01-20', NULL, 2700.00, 320.00, 60.00, 2),
    ('567.890.123-45', 'Isabela Costa', 'F', 'isabela@email.com', '12345', 'Gerente', '2024-02-10', NULL, 5200.00, 550.00, 120.00, 3),
    ('678.901.234-56', 'Roberto Souza', 'M', 'roberto@email.com', '65432', 'Atendente', '2024-03-05', NULL, 2200.00, 220.00, 35.00, 1);

INSERT INTO Custos (nome, valor, dataPag, dataVenc, obs, Departamento_idDepartamento)
VALUES
    ('Custo_001', 123.45, '2023-09-08', '2023-09-18', NULL, 1),
    ('Custo_002', 234.56, '2023-09-09', '2023-09-19', NULL, 2),
    ('Custo_003', 345.67, '2023-09-10', '2023-09-20', NULL, 3),
    ('Custo_004', 456.78, '2023-09-11', '2023-09-21', NULL, 1),
    ('Custo_005', 567.89, '2023-09-12', '2023-09-22', NULL, 2),
    ('Custo_006', 678.90, '2023-09-13', '2023-09-23', NULL, 3),
    ('Custo_007', 789.01, '2023-09-14', '2023-09-24', NULL, 1),
    ('Custo_008', 890.12, '2023-09-15', '2023-09-25', NULL, 2),
    ('Custo_009', 901.23, '2023-09-16', '2023-09-26', NULL, 3),
    ('Custo_010', 123.45, '2023-09-17', '2023-09-27', NULL, 1),
    ('Custo_011', 234.56, '2023-09-18', '2023-09-28', NULL, 2),
    ('Custo_012', 345.67, '2023-09-19', '2023-09-29', NULL, 3),
    ('Custo_013', 456.78, '2023-09-20', '2023-09-30', NULL, 1),
    ('Custo_014', 567.89, '2023-09-21', '2023-10-01', NULL, 2),
    ('Custo_015', 678.90, '2023-09-22', '2023-10-02', NULL, 3),
    ('Custo_016', 789.01, '2023-09-23', '2023-10-03', NULL, 1),
    ('Custo_017', 890.12, '2023-09-24', '2023-10-04', NULL, 2),
    ('Custo_018', 901.23, '2023-09-25', '2023-10-05', NULL, 3),
    ('Custo_019', 123.45, '2023-09-26', '2023-10-06', NULL, 1),
    ('Custo_020', 234.56, '2023-09-27', '2023-10-07', NULL, 2),
    ('Custo_021', 345.67, '2023-09-28', '2023-10-08', NULL, 3),
    ('Custo_022', 456.78, '2023-09-29', '2023-10-09', NULL, 1),
    ('Custo_023', 567.89, '2023-09-30', '2023-10-10', NULL, 2),
    ('Custo_024', 678.90, '2023-10-01', '2023-10-11', NULL, 3),
    ('Custo_025', 789.01, '2023-10-02', '2023-10-12', NULL, 1),
    ('Custo_026', 890.12, '2023-10-03', '2023-10-13', NULL, 2),
    ('Custo_027', 901.23, '2023-10-04', '2023-10-14', NULL, 3),
    ('Custo_028', 123.45, '2023-10-05', '2023-10-15', NULL, 1),
    ('Custo_029', 234.56, '2023-10-06', '2023-10-16', NULL, 2),
    ('Custo_030', 345.67, '2023-10-07', '2023-10-17', NULL, 3),
    ('Custo_031', 456.78, '2023-10-08', '2023-10-18', NULL, 1),
    ('Custo_032', 567.89, '2023-10-09', '2023-10-19', NULL, 2),
    ('Custo_033', 678.90, '2023-10-10', '2023-10-20', NULL, 3),
    ('Custo_034', 789.01, '2023-10-11', '2023-10-21', NULL, 1),
    ('Custo_035', 890.12, '2023-10-12', '2023-10-22', NULL, 2),
    ('Custo_036', 901.23, '2023-10-13', '2023-10-23', NULL, 3),
    ('Custo_037', 123.45, '2023-10-14', '2023-10-24', NULL, 1),
    ('Custo_038', 234.56, '2023-10-15', '2023-10-25', NULL, 2),
    ('Custo_039', 345.67, '2023-10-16', '2023-10-26', NULL, 3),
    ('Custo_040', 456.78, '2023-10-17', '2023-10-27', NULL, 1),
    ('Custo_041', 567.89, '2023-10-18', '2023-10-28', NULL, 2),
    ('Custo_042', 678.90, '2023-10-19', '2023-10-29', NULL, 3),
    ('Custo_043', 789.01, '2023-10-20', '2023-10-30', NULL, 1),
    ('Custo_044', 890.12, '2023-10-21', '2023-10-31', NULL, 2),
    ('Custo_045', 901.23, '2023-10-22', '2023-11-01', NULL, 3),
    ('Custo_046', 123.45, '2023-10-23', '2023-11-02', NULL, 1),
    ('Custo_047', 234.56, '2023-10-24', '2023-11-03', NULL, 2),
    ('Custo_048', 345.67, '2023-10-25', '2023-11-04', NULL, 3),
    ('Custo_049', 456.78, '2023-10-26', '2023-11-05', NULL, 1),
    ('Custo_050', 567.89, '2023-10-27', '2023-11-06', NULL, 2),
    ('Custo_051', 678.90, '2023-10-28', '2023-11-07', NULL, 3),
    ('Custo_052', 789.01, '2023-10-29', '2023-11-08', NULL, 1),
    ('Custo_053', 890.12, '2023-10-30', '2023-11-09', NULL, 2),
    ('Custo_054', 901.23, '2023-10-31', '2023-11-10', NULL, 3),
    ('Custo_055', 123.45, '2023-11-01', '2023-11-11', NULL, 1),
    ('Custo_056', 234.56, '2023-11-02', '2023-11-12', NULL, 2),
    ('Custo_057', 345.67, '2023-11-03', '2023-11-13', NULL, 3),
    ('Custo_058', 456.78, '2023-11-04', '2023-11-14', NULL, 1),
    ('Custo_059', 567.89, '2023-11-05', '2023-11-15', NULL, 2),
    ('Custo_060', 678.90, '2023-11-06', '2023-11-16', NULL, 3),
    ('Custo_061', 789.01, '2023-11-07', '2023-11-17', NULL, 1),
    ('Custo_062', 890.12, '2023-11-08', '2023-11-18', NULL, 2),
    ('Custo_063', 901.23, '2023-11-09', '2023-11-19', NULL, 3),
    ('Custo_064', 123.45, '2023-11-10', '2023-11-20', NULL, 1),
    ('Custo_065', 234.56, '2023-11-11', '2023-11-21', NULL, 2),
    ('Custo_066', 345.67, '2023-11-12', '2023-11-22', NULL, 3),
    ('Custo_067', 456.78, '2023-11-13', '2023-11-23', NULL, 1),
    ('Custo_068', 567.89, '2023-11-14', '2023-11-24', NULL, 2),
    ('Custo_069', 678.90, '2023-11-15', '2023-11-25', NULL, 3),
    ('Custo_070', 789.01, '2023-11-16', '2023-11-26', NULL, 1),
    ('Custo_071', 890.12, '2023-11-17', '2023-11-27', NULL, 2),
    ('Custo_072', 901.23, '2023-11-18', '2023-11-28', NULL, 3),
    ('Custo_073', 123.45, '2023-11-19', '2023-11-29', NULL, 1),
    ('Custo_074', 234.56, '2023-11-20', '2023-11-30', NULL, 2),
    ('Custo_075', 345.67, '2023-11-21', '2023-12-01', NULL, 3),
    ('Custo_076', 456.78, '2023-11-22', '2023-12-02', NULL, 1),
    ('Custo_077', 567.89, '2023-11-23', '2023-12-03', NULL, 2),
    ('Custo_078', 678.90, '2023-11-24', '2023-12-04', NULL, 3),
    ('Custo_079', 789.01, '2023-11-25', '2023-12-05', NULL, 1),
    ('Custo_080', 890.12, '2023-11-26', '2023-12-06', NULL, 2),
    ('Custo_81', 901.23, '2023-11-27', '2023-12-07', NULL, 3),
    ('Custo_082', 123.45, '2023-11-28', '2023-12-08', NULL, 1),
    ('Custo_083', 234.56, '2023-11-29', '2023-12-09', NULL, 2),
    ('Custo_084', 345.67, '2023-11-30', '2023-12-10', NULL, 3),
    ('Custo_085', 456.78, '2023-12-01', '2023-12-11', NULL, 1),
    ('Custo_086', 567.89, '2023-12-02', '2023-12-12', NULL, 2),
    ('Custo_087', 678.90, '2023-12-03', '2023-12-13', NULL, 3),
    ('Custo_088', 789.01, '2023-12-04', '2023-12-14', NULL, 1),
    ('Custo_089', 890.12, '2023-12-05', '2023-12-15', NULL, 2),
    ('Custo_090', 901.23, '2023-12-06', '2023-12-16', NULL, 3),
    ('Custo_091', 123.45, '2023-12-07', '2023-12-17', NULL, 1),
    ('Custo_092', 234.56, '2023-12-08', '2023-12-18', NULL, 2),
    ('Custo_093', 345.67, '2023-12-09', '2023-12-19', NULL, 3),
    ('Custo_094', 456.78, '2023-12-10', '2023-12-20', NULL, 1),
    ('Custo_095', 567.89, '2023-12-11', '2023-12-21', NULL, 2),
    ('Custo_096', 678.90, '2023-12-12', '2023-12-22', NULL, 3),
    ('Custo_097', 789.01, '2023-12-13', '2023-12-23', NULL, 1),
    ('Custo_098', 890.12, '2023-12-14', '2023-12-24', NULL, 2),
    ('Custo_099', 901.23, '2023-12-15', '2023-12-25', NULL, 3),
    ('Custo_100', 123.45, '2023-12-16', '2023-12-26', NULL, 1);
   
INSERT INTO `petshop`.`Produtos` (`nome`, `quantidade`, `marca`, `dataVenc`, `valorVenda`, `precoCusto`) VALUES
    ('Ração para Cães', 100.00, 'Royal Canin', '2024-05-01', 49.90, 30.00),
    ('Ração para Gatos', 80.00, 'Hill''s', '2024-06-15', 45.00, 28.00),
    ('Brinquedo para Cães', 200.00, 'Kong', NULL, 15.90, 10.00),
    ('Areia Sanitária para Gatos', 150.00, 'Chalesco', '2024-07-20', 10.50, 7.50),
    ('Coleira Antipulgas para Cães', 50.00, 'Frontline', '2024-09-10', 35.00, 20.00),
    ('Shampoo para Cães', 60.00, 'PetSmile', '2024-08-05', 12.99, 7.00),
    ('Comedouro para Gatos', 100.00, 'Hagen', NULL, 8.50, 5.00),
    ('Tapete Higiênico para Cães', 120.00, 'Petix', '2024-10-12', 18.75, 11.00),
    ('Bolinha de Tênis para Cães', 300.00, 'Kong', NULL, 3.99, 2.50),
    ('Ração para Peixes', 200.00, 'Sera', '2024-11-30', 5.99, 4.00),
    ('Gaiola para Hamsters', 40.00, 'Ferplast', NULL, 39.90, 25.00),
    ('Ração para Pássaros', 250.00, 'Alcon', '2024-12-15', 7.50, 5.00),
    ('Casinha para Cães', 30.00, 'Tramontina', NULL, 85.00, 65.00),
    ('Ração para Tartarugas', 70.00, 'Tetra', '2024-10-01', 12.00, 8.50),
    ('Bolsa de Transporte para Gatos', 20.00, 'Pawise', NULL, 29.99, 18.00),
    ('Escova para Gatos', 90.00, 'Furminator', NULL, 28.50, 16.00),
    ('Roupinha para Cães', 50.00, 'Zee.Dog', NULL, 35.00, 22.00),
    ('Bebedouro para Cães', 80.00, 'PetFeeder', NULL, 14.99, 10.00),
    ('Comedouro para Pássaros', 150.00, 'Alcon', NULL, 6.50, 4.50),
    ('Coleira para Gatos', 70.00, 'Pawise', NULL, 9.50, 6.50),
    ('Casinha para Coelhos', 10.00, 'Ferplast', NULL, 49.90, 30.00),
    ('Shampoo para Gatos', 40.00, 'PetSmile', '2024-09-25', 13.99, 9.50),
    ('Brinquedo para Pássaros', 200.00, 'Zee.Dog', NULL, 4.75, 3.00),
    ('Aquário para Peixes', 15.00, 'Tetra', NULL, 99.99, 70.00),
    ('Coleira Anticarrapatos para Cães', 60.00, 'Frontline', '2024-11-20', 28.00, 15.50),
    ('Ração para Hamsters', 100.00, 'Vitakraft', '2024-07-08', 7.25, 4.50),
    ('Brinquedo para Coelhos', 80.00, 'Chalesco', NULL, 6.99, 4.00),
    ('Ração para Canários', 150.00, 'Alcon', '2024-12-30', 4.25, 3.00),
    ('Arranhador para Gatos', 40.00, 'Furminator', NULL, 22.90, 15.00),
    ('Roupinha para Cães', 70.00, 'Zee.Dog', NULL, 29.90, 18.50),
    ('Comedouro para Peixes', 200.00, 'Sera', NULL, 12.99, 8.00),
    ('Bebedouro para Pássaros', 180.00, 'Alcon', '2024-10-20', 5.50, 3.50),
    ('Bolsa de Transporte para Cães', 25.00, 'Pawise', NULL, 49.50, 35.00),
    ('Shampoo para Hamsters', 50.00, 'Chalesco', '2024-08-18', 9.25, 6.00),
    ('Casinha para Coelhos', 12.00, 'Ferplast', NULL, 64.90, 45.00),
    ('Ração para Periquitos', 120.00, 'Alcon', '2024-11-15', 3.75, 2.50),
    ('Brinquedo para Tartarugas', 90.00, 'Chalesco', NULL, 7.99, 5.00),
    ('Terrário para Répteis', 15.00, 'Exo Terra', NULL, 129.00, 95.00),
    ('Coleira Antipulgas para Gatos', 70.00, 'Frontline', '2024-10-08', 32.50, 20.00),
    ('Ração para Cobaias', 180.00, 'Vitakraft', NULL, 5.75, 3.50),
    ('Arranhador para Gatos', 50.00, 'Zee.Dog', NULL, 19.99, 12.00),
    ('Comedouro para Tartarugas', 30.00, 'Tetra', NULL, 11.50, 7.50),
    ('Gaiola para Calopsitas', 8.00, 'Ferplast', NULL, 99.00, 70.00),
    ('Shampoo para Coelhos', 60.00, 'Chalesco', '2024-09-08', 8.75, 5.50),
    ('Bebedouro para Cobaias', 50.00, 'PetFeeder', NULL, 7.99, 4.50),
    ('Ração para Porquinhos da Índia', 90.00, 'Vitakraft', NULL, 6.25, 4.00),
    ('Brinquedo para Cobaias', 100.00, 'Zee.Dog', NULL, 5.99, 3.50),
    ('Aquário para Tartarugas', 20.00, 'Sera', NULL, 89.90, 60.00),
    ('Coleira Anticarrapatos para Gatos', 50.00, 'Frontline', '2024-12-05', 26.50, 15.50),
    ('Ração para Iguanas', 40.00, 'Exo Terra', NULL, 9.75, 6.50),
    ('Bebedouro para Calopsitas', 30.00, 'PetFeeder', NULL, 5.99, 3.50),
    ('Ração para Jabutis', 80.00, 'ZooMed', '2024-08-30', 8.50, 5.50),
    ('Brinquedo para Porquinhos da Índia', 150.00, 'Chalesco', NULL, 4.99, 3.00),
    ('Aquário para Peixes Tropicais', 15.00, 'Tetra', NULL, 119.00, 85.00),
    ('Coleira Antipulgas para Cães', 70.00, 'Frontline', '2024-07-12', 31.50, 18.00),
    ('Ração para Pássaros Exóticos', 120.00, 'Alcon', NULL, 5.25, 3.50);

INSERT INTO `petshop`.`Venda` (`data`, `valor`, `comissao`, `desconto`, `Cliente_cpf`, `Empregado_cpf`) 
VALUES
('2023-09-01 10:00:00', 550.00, 10.00, 05.00, '017.503.885-61', '444.444.444-44'),
('2023-09-02 11:30:00', 200.00, 15.00, 08.00, '614.784.393-19', '777.777.777-77'),
('2023-09-03 14:45:00', 980.00, 12.00, 06.00, '055.293.993-55', '222.222.222-22'),
('2023-09-04 09:15:00', 220.00, 18.00, 10.00, '064.542.923-63', '123.456.789-01'),
('2023-09-05 16:20:00', 190.00, 13.00, 07.00, '017.503.885-61', '456.789.012-34'),
('2023-09-06 13:10:00', 470.00, 11.00, 05.00, '380.297.822-68', '444.444.444-44'),
('2023-09-07 08:30:00', 210.00, 17.00, 09.00, '075.256.043-39', '111.111.111-11'),
('2023-09-08 12:55:00', 840.00, 20.00, 12.00, '401.366.803-30', '666.666.666-66'),
('2023-09-09 15:40:00', 175.00, 14.00, 06.00, '017.503.885-61', '567.890.123-45'),
('2023-09-10 17:25:00', 995.00, 16.00, 08.00, '805.120.623-15', '444.444.444-44'),
('2023-09-11 09:05:00', 230.00, 19.00, 11.00, '023.959.573-48', '444.444.444-44'),
('2023-09-12 14:15:00', 185.00, 15.00, 07.00, '604.295.233-19', '777.777.777-77'),
('2023-09-13 10:30:00', 215.00, 18.00, 09.00, '088.878.253-51', '222.222.222-22'),
('2023-09-14 08:50:00', 250.00, 21.00, 12.00, '328.373.483-68', '123.456.789-01'),
('2023-09-15 11:10:00', 600.00, 16.00, 08.00, '625.499.783-58', '456.789.012-34'),
('2023-09-16 13:50:00', 170.00, 12.00, 06.00, '017.503.885-61', '444.444.444-44'),
('2023-09-17 15:15:00', 225.00, 20.00, 11.00, '614.784.393-19', '111.111.111-11'),
('2023-09-18 09:45:00', 290.00, 14.00, 07.00, '635.111.523-05', '666.666.666-66'),
('2023-09-19 16:35:00', 205.00, 17.00, 08.00, '034.113.953-03', '567.890.123-45'),
('2023-09-20 12:40:00', 235.00, 19.00, 10.00, '972.287.963-49', '444.444.444-44'),
('2023-09-21 14:20:00', 180.00, 15.00, 07.00, '009.849.462-76', '444.444.444-44'),
('2023-09-22 10:05:00', 210.00, 18.00, 09.00, '304.523.923-49', '777.777.777-77'),
('2023-09-23 08:15:00', 220.00, 20.00, 10.00, '614.784.393-19', '222.222.222-22'),
('2023-09-24 13:30:00', 195.00, 16.00, 08.00, '021.192.333-81', '123.456.789-01'),
('2023-09-25 09:55:00', 175.00, 13.00, 06.00, '614.784.393-19', '456.789.012-34'),
('2023-09-26 11:40:00', 240.00, 21.00, 11.00, '418.178.423-15', '444.444.444-44'),
('2023-09-27 15:05:00', 225.00, 19.00, 10.00, '332.925.233-20', '111.111.111-11'),
('2023-09-28 14:00:00', 300.00, 17.00, 08.00, '332.925.233-20', '666.666.666-66'),
('2023-09-29 12:25:00', 230.00, 20.00, 09.00, '332.925.233-20', '567.890.123-45'),
('2023-09-30 17:20:00', 260.00, 22.00, 12.00, '010.169.993-05', '444.444.444-44'),
('2023-10-01 10:35:00', 175.00, 15.00, 07.00, '604.569.393-00', '444.444.444-44'),
('2023-10-02 08:45:00', 210.00, 18.00, 09.00, '070.762.033-32', '777.777.777-77'),
('2023-10-03 14:20:00', 185.00, 16.00, 08.00, '482.603.983-20', '222.222.222-22'),
('2023-10-04 09:15:00', 220.00, 19.00, 10.00, '604.569.393-00', '123.456.789-01'),
('2023-10-05 16:30:00', 195.00, 17.00, 09.00, '019.659.463-48', '456.789.012-34'),
('2023-10-06 13:05:00', 170.00, 14.00, 07.00, '005.710.583-96', '444.444.444-44'),
('2023-10-07 08:50:00', 230.00, 21.00, 11.00, '003.523.273-08', '111.111.111-11'),
('2023-10-08 12:45:00', 245.00, 20.00, 12.00, '413.281.323-15', '666.666.666-66'),
('2023-10-09 15:55:00', 200.00, 16.00, 08.00, '067.903.783-75', '567.890.123-45'),
('2023-10-10 17:40:00', 265.00, 22.00, 12.00, '003.523.273-08', '444.444.444-44'),
('2023-10-11 09:25:00', 180.00, 15.00, 07.00, '040.409.013-39', '444.444.444-44'),
('2023-10-12 14:15:00', 215.00, 18.00, 09.00, '003.523.273-08', '777.777.777-77'),
('2023-10-13 10:20:00', 225.00, 19.00, 10.00, '714.537.093-04', '222.222.222-22'),
('2023-10-14 08:35:00', 190.00, 17.00, 08.00, '189.249.992-49', '123.456.789-01'),
('2023-10-15 11:05:00', 250.00, 21.00, 11.00, '437.902.888-70', '456.789.012-34'),
('2023-10-16 13:45:00', 175.00, 14.00, 07.00, '874.206.782-00', '444.444.444-44'),
('2023-10-17 15:10:00', 235.00, 20.00, 09.00, '426.607.349-68', '111.111.111-11'),
('2023-10-18 09:40:00', 195.00, 16.00, 08.00, '600.248.883-97', '666.666.666-66'),
('2023-10-19 16:15:00', 220.00, 17.00, 09.00, '001.172.372-64', '567.890.123-45'),
('2023-10-20 12:50:00', 805.00, 18.00, 10.00, '437.902.888-70', '444.444.444-44');

INSERT INTO formapgvenda(tipo, valorpago, venda_idVenda)
VALUES
('CHEQUE'  , 300.00, 01),
('DINHEIRO', 250.00, 01),
('CARTAO'  , 200.00, 02),
('BOLETO'  , 200.00, 03),
('PIX'     , 200.00, 03),
('DINHEIRO', 380.00, 03),
('PIX'     , 200.00, 03),
('CARTAO'  , 200.00, 03),
('CARTAO'  , 220.00, 04),
('PIX'     , 100.00, 05),
('CHEQUE'  , 090.00, 05),
('DINHEIRO', 470.00, 06),
('CHEQUE'  , 010.00, 07),
('PIX'     , 200.00, 07),
('PIX'     , 200.00, 08),
('PIX'     , 200.00, 08),
('BOLETO'  , 400.00, 08),
('CHEQUE'  , 040.00, 08),
('CHEQUE'  , 175.00, 09),
('CHEQUE'  , 405.00, 10),
('CARTAO'  , 590.00, 10),
('CHEQUE'  , 230.00, 11),
('CHEQUE'  , 185.00, 12),
('PIX'     , 215.00, 13),
('DINHEIRO', 250.00, 14),
('DINHEIRO', 300.00, 15),
('PIX'     , 100.00, 15),
('BOLETO'  , 200.00, 15),
('BOLETO'  , 170.00, 16),
('BOLETO'  , 225.00, 17),
('BOLETO'  , 200.00, 18),
('DINHEIRO', 090.00, 18),
('CARTAO'  , 200.00, 19),
('PIX'     , 005.00, 19),
('CHEQUE'  , 235.00, 20),
('PIX'     , 090.00, 21),
('DINHEIRO', 090.00, 21),
('DINHEIRO', 210.00, 22),
('CARTAO'  , 110.00, 23),
('PIX'     , 110.00, 23),
('CARTAO'  , 195.00, 24),
('PIX'     , 175.00, 25),
('PIX'     , 120.00, 26),
('DINHEIRO', 120.00, 26),
('PIX'     , 200.00, 27),
('CARTAO'  , 025.00, 27),
('CARTAO'  , 150.00, 28),
('CARTAO'  , 150.00, 28),
('DINHERIO', 100.00, 29),
('PIX'     , 100.00, 29),
('BOLETO'  , 030.00, 29),
('BOLETO'  , 260.00, 30),
('PIX'     , 175.00, 31),
('PIX'     , 210.00, 32),
('PIX'     , 100.00, 33),
('PIX'     , 085.00, 33),
('CHEQUE'  , 220.00, 34),
('PIX'     , 105.00, 35),
('DINHERIO', 090.00, 35),
('BOLETO'  , 170.00, 36),
('BOLETO'  , 115.00, 37),
('CHEQUE'  , 115.00, 37),
('DINHEIRO', 245.00, 38),
('PIX'     , 100.00, 39),
('CHEQUE'  , 100.00, 39),
('PIX'     , 265.00, 40),
('CHEQUE'  , 180.00, 41),
('PIX'     , 175.00, 42),
('DINHEIRO', 040.00, 42),
('CHEQUE'  , 225.00, 43),
('PIX'     , 190.00, 44),
('PIX'     , 250.00, 45),
('PIX'     , 175.00, 46),
('PIX'     , 235.00, 47),
('PIX'     , 195.00, 48),
('PIX'     , 220.00, 49),
('PIX'     , 805.00, 50);

INSERT INTO itensvendaprod(venda_idVenda, produto_idProduto, quantidade, valor, desconto)
VALUES
(01,01,01,300.00,0),
(01,02,02,250.00,0),
(02,10,03,200.00,0),
(03,11,04,980.00,0),
(04,21,05,100.00,0),
(04,31,06,120.00,0),
(05,14,08,010.00,0),
(05,15,09,050.00,0),
(05,20,10,030.00,0),
(06,01,01,400.00,0),
(06,07,02,070.00,0),
(07,49,03,210.00,0),
(08,44,04,840.00,0),
(09,10,05,175.00,0),
(10,11,06,500.00,0),
(10,13,07,400.00,0),
(10,15,08,095.00,0),
(11,17,09,100.00,0),
(11,33,10,100.00,0),
(11,05,01,015.00,0),
(11,40,02,015.00,0),
(12,19,03,185.00,0),
(13,24,04,215.00,0),
(14,08,05,250.00,0),
(15,01,06,200.00,0),
(15,41,07,400.00,0),
(16,41,08,170.00,0),
(17,21,09,225.00,0),
(18,31,10,290.00,0),
(19,10,01,100.00,0),
(19,20,02,090.00,0),
(19,50,03,015.00,0),
(20,40,04,235.00,0),
(21,30,05,030.00,0),
(21,03,06,050.00,0),
(21,06,07,060.00,0),
(21,47,08,040.00,0),
(22,18,09,200.00,0),
(22,12,10,010.00,0),
(23,01,01,220.00,0),
(24,20,02,195.00,0),
(25,20,03,175.00,0),
(26,50,04,240.00,0),
(27,24,05,200.00,0),
(27,27,06,025.00,0),
(29,23,08,230.00,0),
(30,30,09,100.00,0),
(30,31,10,160.00,0),
(31,31,01,175.00,0),
(33,33,03,185.00,0),
(34,34,04,100.00,0),
(34,35,05,100.00,0),
(34,44,06,020.00,0),
(35,05,07,195.00,0),
(36,07,08,170.00,0),
(37,08,09,230.00,0),
(39,11,01,025.00,0),
(39,12,02,025.00,0),
(39,13,03,025.00,0),
(39,14,04,025.00,0),
(39,15,05,025.00,0),
(39,16,06,025.00,0),
(39,17,07,025.00,0),
(40,50,10,265.00,0),
(41,48,01,180.00,0),
(42,19,04,015.00,0),
(43,19,05,050.00,0),
(43,25,06,050.00,0),
(43,12,08,025.00,0),
(43,10,09,025.00,0),
(44,12,10,190.00,0),
(45,28,01,250.00,0),
(46,24,02,175.00,0),
(47,20,03,100.00,0),
(47,16,04,100.00,0),
(47,28,05,035.00,0),
(48,09,06,195.00,0),
(49,10,07,220.00,0),
(50,12,08,100.00,0),
(50,20,09,050.00,0),
(50,21,10,175.00,0),
(50,10,01,025.00,0),
(50,13,02,020.00,0),
(50,11,03,080.00,0),
(50,05,05,100.00,0),
(50,06,06,100.00,0),
(50,01,07,050.00,0),
(50,15,08,050.00,0);

INSERT INTO itensservico(empregado_cpf, servico_idservico, venda_idVenda, pet_idpet, quantidade, valor, desconto)
VALUES
('333.333.333-33',06, 05,13,07,100.00,0),
('666.666.666-66',13, 28,22,07,300.00,0),
('111.111.111-11',10, 32,20,02,210.00,0),
('999.999.999-99',01, 38,10,10,245.00,0),
('345.678.901-23',25, 39,18,08,025.00,0),
('234.567.890-12',12, 39,19,09,025.00,0),
('999.999.999-99',17, 42,48,02,050.00,0),
('345.678.901-23',11, 42,48,03,150.00,0),
('234.567.890-12',13, 43,06,07,075.00,0),
('333.333.333-33',22, 50,01,01,100.00,0);

-- error incorrect date values 
INSERT INTO compras(dataComp, valorTotal, dataVenc, dataPag, desconto, juros, fornecedor_cpf_cnpj)
VALUES
('2023-09-01 10:00:00', 550.00,'2023-09-01 10:00:00','2023-09-01 10:00:00',10.00, 05.00, '584.184.315-04'    ),
('2023-09-02 11:30:00', 200.00,'2023-09-02 11:30:00','2023-09-02 11:30:00',15.00, 08.00, '452.248.353-80'    ),
('2023-09-03 14:45:00', 980.00,'2023-09-03 14:45:00','2023-09-03 14:45:00',12.00, 06.00, '584.184.315-04'    ),
('2023-09-04 09:15:00', 220.00,'2023-09-04 09:15:00','2023-09-04 09:15:00',18.00, 10.00, '452.248.353-80'    ),
('2023-09-05 16:20:00', 190.00,'2023-09-05 16:20:00','2023-09-05 16:20:00',13.00, 07.00, '824.491.635-49'    ),
('2023-09-06 13:10:00', 470.00,'2023-09-06 13:10:00','2023-09-06 13:10:00',11.00, 05.00, '584.184.315-04'    ),
('2023-09-07 08:30:00', 210.00,'2023-09-07 08:30:00','2023-09-07 08:30:00',17.00, 09.00, '116231880008-17'),
('2023-09-08 12:55:00', 840.00,'2023-09-08 12:55:00','2023-09-08 12:55:00',20.00, 12.00, '116231880008-17'),
('2023-09-09 15:40:00', 175.00,'2023-09-09 15:40:00','2023-09-09 15:40:00',14.00, 06.00, '751.190.485-87'    ),
('2023-09-10 17:25:00', 995.00,'2023-09-10 17:25:00','2023-09-10 17:25:00',16.00, 08.00, '976.372.258-60'    ),
('2023-09-11 09:05:00', 230.00,'2023-09-11 09:05:00','2023-09-11 09:05:00',19.00, 11.00, '751.190.485-87'    ),
('2023-09-12 14:15:00', 185.00,'2023-09-12 14:15:00','2023-09-12 14:15:00',15.00, 07.00, '563.428.350-70'    ),
('2023-09-13 10:30:00', 215.00,'2023-09-13 10:30:00','2023-09-13 10:30:00',18.00, 09.00, '419296600001-29'),
('2023-09-14 08:50:00', 250.00,'2023-09-14 08:50:00','2023-09-14 08:50:00',21.00, 12.00, '515049950001-69'),
('2023-09-15 11:10:00', 600.00,'2023-09-15 11:10:00','2023-09-15 11:10:00',16.00, 08.00, '515049950001-69'),
('2023-09-16 13:50:00', 170.00,'2023-09-16 13:50:00','2023-09-16 13:50:00',12.00, 06.00, '546.744.532-40'    ),
('2023-09-17 15:15:00', 225.00,'2023-09-17 15:15:00','2023-09-17 15:15:00',20.00, 11.00, '171616800001-60'),
('2023-09-18 09:45:00', 290.00,'2023-09-18 09:45:00','2023-09-18 09:45:00',14.00, 07.00, '171616800001-60'),
('2023-09-19 16:35:00', 205.00,'2023-09-19 16:35:00','2023-09-19 16:35:00',17.00, 08.00, '321.763.149-80'    ),
('2023-09-20 12:40:00', 235.00,'2023-09-20 12:40:00','2023-09-20 12:40:00',19.00, 10.00, '287.828.220-50'    ),
('2023-09-21 14:20:00', 180.00,'2023-09-21 14:20:00','2023-09-21 14:20:00',15.00, 07.00, '158.556.623-30'    ),
('2023-09-22 10:05:00', 210.00,'2023-09-22 10:05:00','2023-09-22 10:05:00',18.00, 09.00, '321.763.149-80'    ),
('2023-09-23 08:15:00', 220.00,'2023-09-23 08:15:00','2023-09-23 08:15:00',20.00, 10.00, '158.556.623-30'    ),
('2023-09-24 13:30:00', 195.00,'2023-09-24 13:30:00','2023-09-24 13:30:00',16.00, 08.00, '678.425.124-50'    ),
('2023-09-25 09:55:00', 175.00,'2023-09-25 09:55:00','2023-09-25 09:55:00',13.00, 06.00, '425.848.172-68'    ),
('2023-09-26 11:40:00', 240.00,'2023-09-26 11:40:00','2023-09-26 11:40:00',21.00, 11.00, '425.848.172-68'    ),
('2023-09-27 15:05:00', 225.00,'2023-09-27 15:05:00','2023-09-27 15:05:00',19.00, 10.00, '863.971.842-34'    ),
('2023-09-28 14:00:00', 300.00,'2023-09-28 14:00:00','2023-09-28 14:00:00',17.00, 08.00, '736.566.236-00'    ),
('2023-09-29 12:25:00', 230.00,'2023-09-29 12:25:00','2023-09-29 12:25:00',20.00, 09.00, '437.607.437-30'    ),
('2023-09-30 17:20:00', 260.00,'2023-09-30 17:20:00','2023-09-30 17:20:00',22.00, 12.00, '437.607.437-30'    ),
('2023-10-01 10:35:00', 175.00,'2023-10-01 10:35:00','2023-10-01 10:35:00',15.00, 07.00, '437.607.437-30'    ),
('2023-10-02 08:45:00', 210.00,'2023-10-02 08:45:00','2023-10-02 08:45:00',18.00, 09.00, '693.364.822-20'    ),
('2023-10-03 14:20:00', 185.00,'2023-10-03 14:20:00','2023-10-03 14:20:00',16.00, 08.00, '519072480001-71'),
('2023-10-04 09:15:00', 220.00,'2023-10-04 09:15:00','2023-10-04 09:15:00',19.00, 10.00, '450.793.133-90'    ),
('2023-10-05 16:30:00', 195.00,'2023-10-05 16:30:00','2023-10-05 16:30:00',17.00, 09.00, '450.793.133-90'    ),
('2023-10-06 13:05:00', 170.00,'2023-10-06 13:05:00','2023-10-06 13:05:00',14.00, 07.00, '590.579.720-00'    ),
('2023-10-07 08:50:00', 230.00,'2023-10-07 08:50:00','2023-10-07 08:50:00',21.00, 11.00, '134.030.320-50'    ),
('2023-10-08 12:45:00', 245.00,'2023-10-08 12:45:00','2023-10-08 12:45:00',20.00, 12.00, '132.772.124-40'    ),
('2023-10-09 15:55:00', 200.00,'2023-10-09 15:55:00','2023-10-09 15:55:00',16.00, 08.00, '209.764.295-00'    ),
('2023-10-10 17:40:00', 265.00,'2023-10-10 17:40:00','2023-10-10 17:40:00',22.00, 12.00, '660.932.443-34'    ),
('2023-10-11 09:25:00', 180.00,'2023-10-11 09:25:00','2023-10-11 09:25:00',15.00, 07.00, '302.452.826-10'    ),
('2023-10-12 14:15:00', 215.00,'2023-10-12 14:15:00','2023-10-12 14:15:00',18.00, 09.00, '678.570.432-49'    ),
('2023-10-13 10:20:00', 225.00,'2023-10-13 10:20:00','2023-10-13 10:20:00',19.00, 10.00, '665.165.283-49'    ),
('2023-10-14 08:35:00', 190.00,'2023-10-14 08:35:00','2023-10-14 08:35:00',17.00, 08.00, '320.717.534-10'    ),
('2023-10-15 11:05:00', 250.00,'2023-10-15 11:05:00','2023-10-15 11:05:00',21.00, 11.00, '519.692.112-53'    ),
('2023-10-16 13:45:00', 175.00,'2023-10-16 13:45:00','2023-10-16 13:45:00',14.00, 07.00, '516.927.027-50'    ),
('2023-10-17 15:10:00', 235.00,'2023-10-17 15:10:00','2023-10-17 15:10:00',20.00, 09.00, '909.454.833-00'    ),
('2023-10-18 09:40:00', 195.00,'2023-10-18 09:40:00','2023-10-18 09:40:00',16.00, 08.00, '263.850.021-60'    ),
('2023-10-19 16:15:00', 220.00,'2023-10-19 16:15:00','2023-10-19 16:15:00',17.00, 09.00, '715.350.202-53'    ),
('2023-10-20 12:50:00', 805.00,'2023-10-20 12:50:00','2023-10-20 12:50:00',18.00, 10.00, '715.350.202-53'    );

INSERT INTO itenscompra(compras_idCompra, Produtos_idProduto, valorCompra, quantidade)
VALUES
(01,01,300.00, 01),
(01,02,250.00, 02),
(02,10,200.00, 03),
(03,11,980.00, 04),
(04,21,100.00, 05),
(04,31,120.00, 06),
(05,13,100.00, 07),
(05,14,010.00, 08),
(05,15,050.00, 09),
(05,20,030.00, 10),
(06,01,400.00, 01),
(06,07,070.00, 02),
(07,49,210.00, 03),
(08,44,840.00, 04),
(09,10,175.00, 05),
(10,11,500.00, 06),
(10,13,400.00, 07),
(10,15,095.00, 08),
(11,17,100.00, 09),
(11,33,100.00, 10),
(11,05,015.00, 01),
(11,40,015.00, 02),
(12,19,185.00, 03),
(13,24,215.00, 04),
(14,08,250.00, 05),
(15,01,200.00, 06),
(15,41,400.00, 07),
(16,41,170.00, 08),
(17,21,225.00, 09),
(18,31,290.00, 10),
(19,10,100.00, 01),
(19,20,090.00, 02),
(19,50,015.00, 03),
(20,40,235.00, 04),
(21,30,030.00, 05),
(21,03,050.00, 06),
(21,06,060.00, 07),
(21,47,040.00, 08),
(22,18,200.00, 09),
(22,12,010.00, 10),
(23,01,220.00, 01),
(24,20,195.00, 02),
(25,20,175.00, 03),
(26,50,240.00, 04),
(27,24,200.00, 05),
(27,27,025.00, 06),
(28,22,300.00, 07),
(29,23,230.00, 08),
(30,30,100.00, 09),
(30,31,160.00, 10),
(31,31,175.00, 01),
(32,20,210.00, 02),
(33,33,185.00, 03),
(34,34,100.00, 04),
(34,35,100.00, 05),
(34,44,020.00, 06),
(35,05,195.00, 07),
(36,07,170.00, 08),
(37,08,230.00, 09),
(38,10,245.00, 10),
(39,11,025.00, 01),
(39,12,025.00, 02),
(39,13,025.00, 03),
(39,14,025.00, 04),
(39,15,025.00, 05),
(39,16,025.00, 06),
(39,17,025.00, 07),
(39,18,025.00, 08),
(39,19,025.00, 09),
(40,50,265.00, 10),
(41,48,180.00, 01),
(42,48,050.00, 02),
(42,47,150.00, 03),
(42,19,015.00, 04),
(43,19,050.00, 05),
(43,25,050.00, 06),
(43,06,075.00, 07),
(43,12,025.00, 08),
(43,10,025.00, 09),
(44,12,190.00, 10),
(45,28,250.00, 01),
(46,24,175.00, 02),
(47,20,100.00, 03),
(47,16,100.00, 04),
(47,28,035.00, 05),
(48,09,195.00, 06),
(49,10,220.00, 07),
(50,12,100.00, 08),
(50,20,050.00, 09),
(50,21,175.00, 10),
(50,10,025.00, 01),
(50,13,020.00, 02),
(50,11,080.00, 03),
(50,01,100.00, 04),
(50,05,100.00, 05),
(50,06,100.00, 06),
(50,04,050.00, 07),
(50,15,050.00, 08);

INSERT INTO formapagcompra(tipo, valorpago, compras_idCompra)
VALUES
('CHEQUE'  , 300.00, 01),
('DINHEIRO', 250.00, 01),
('CARTAO'  , 200.00, 02),
('BOLETO'  , 200.00, 03),
('PIX'     , 200.00, 03),
('DINHEIRO', 380.00, 03),
('PIX'     , 200.00, 03),
('CARTAO'  , 200.00, 03),
('CARTAO'  , 220.00, 04),
('PIX'     , 100.00, 05),
('CHEQUE'  , 090.00, 05),
('DINHEIRO', 470.00, 06),
('CHEQUE'  , 010.00, 07),
('PIX'     , 200.00, 07),
('PIX'     , 200.00, 08),
('PIX'     , 200.00, 08),
('BOLETO'  , 400.00, 08),
('CHEQUE'  , 040.00, 08),
('CHEQUE'  , 175.00, 09),
('CHEQUE'  , 405.00, 10),
('CARTAO'  , 590.00, 10),
('CHEQUE'  , 230.00, 11),
('CHEQUE'  , 185.00, 12),
('PIX'     , 215.00, 13),
('DINHEIRO', 250.00, 14),
('DINHEIRO', 300.00, 15),
('PIX'     , 100.00, 15),
('BOLETO'  , 200.00, 15),
('BOLETO'  , 170.00, 16),
('BOLETO'  , 225.00, 17),
('BOLETO'  , 200.00, 18),
('DINHEIRO', 090.00, 18),
('CARTAO'  , 200.00, 19),
('PIX'     , 005.00, 19),
('CHEQUE'  , 235.00, 20),
('PIX'     , 090.00, 21),
('DINHEIRO', 090.00, 21),
('DINHEIRO', 210.00, 22),
('CARTAO'  , 110.00, 23),
('PIX'     , 110.00, 23),
('CARTAO'  , 195.00, 24),
('PIX'     , 175.00, 25),
('PIX'     , 120.00, 26),
('DINHEIRO', 120.00, 26),
('PIX'     , 200.00, 27),
('CARTAO'  , 025.00, 27),
('CARTAO'  , 150.00, 28),
('CARTAO'  , 150.00, 28),
('DINHERIO', 100.00, 29),
('PIX'     , 100.00, 29),
('BOLETO'  , 030.00, 29),
('BOLETO'  , 260.00, 30),
('PIX'     , 175.00, 31),
('PIX'     , 210.00, 32),
('PIX'     , 100.00, 33),
('PIX'     , 085.00, 33),
('CHEQUE'  , 220.00, 34),
('PIX'     , 105.00, 35),
('DINHERIO', 090.00, 35),
('BOLETO'  , 170.00, 36),
('BOLETO'  , 115.00, 37),
('CHEQUE'  , 115.00, 37),
('DINHEIRO', 245.00, 38),
('PIX'     , 100.00, 39),
('CHEQUE'  , 100.00, 39),
('PIX'     , 265.00, 40),
('CHEQUE'  , 180.00, 41),
('PIX'     , 175.00, 42),
('DINHEIRO', 040.00, 42),
('CHEQUE'  , 225.00, 43),
('PIX'     , 190.00, 44),
('PIX'     , 250.00, 45),
('PIX'     , 175.00, 46),
('PIX'     , 235.00, 47),
('PIX'     , 195.00, 48),
('PIX'     , 220.00, 49),
('PIX'     , 805.00, 50);

INSERT INTO telefone(numero, empregado_cpf, departamento_idDepartamento, fornecedor_cpf_cnpj)
VALUES
('99999-9990','111.111.111-11',NULL,NULL),
('99999-9991', '111.111.111-11',1,NULL),
('99999-9992',NULL,2,NULL),
('99999-9993',NULL,3,NULL),
('99999-9994',NULL,NULL,'552.133.957-40'    ),
('99999-9995',NULL,NULL,'397.404.166-40'    ),
('99999-9996',NULL,NULL,'153.076.658-30'    ),
('99999-9997',NULL,NULL,'419296600001-29'),
('99999-9998','222.222.222-22',NULL,NULL);



                                             
                                         