CREATE DATABASE UFABCar;

USE UFABCar;

CREATE TABLE usuario (
    id INT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(200) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    genero VARCHAR(1) NOT NULL,
    avaliacao FLOAT DEFAULT 5.0,
    foto_perfil VARCHAR(255),
    PRIMARY KEY (id)
);

CREATE TABLE viagem (
    id INT NOT NULL AUTO_INCREMENT,
    idMotorista INT NOT NULL,
    origem VARCHAR(255) NOT NULL,
    destino VARCHAR(255) NOT NULL,
    data_hora DATETIME NOT NULL,
    vagas_disponiveis INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (idMotorista) REFERENCES usuario(id)
);

CREATE TABLE viagem_passageiros (
    idViagem INT NOT NULL,
    idPassageiro INT NOT NULL,
    FOREIGN KEY (idViagem) REFERENCES viagem(id),
    FOREIGN KEY (idPassageiro) REFERENCES usuario(id),
    PRIMARY KEY (idViagem, idPassageiro)
);

CREATE TABLE chat (
    id INT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(255),
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

CREATE TABLE chat_participantes (
    idChat INT NOT NULL,
    idUsuario INT NOT NULL,
    FOREIGN KEY (idChat) REFERENCES chat(id),
    FOREIGN KEY (idUsuario) REFERENCES usuario(id),
    PRIMARY KEY (idChat, idUsuario)
);

CREATE TABLE mensagem (
    id INT NOT NULL AUTO_INCREMENT,
    idChat INT NOT NULL,
    idRemetente INT NOT NULL,
    mensagem TEXT NOT NULL,
    data_envio DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (idChat) REFERENCES chat(id),
    FOREIGN KEY (idRemetente) REFERENCES usuario(id)
);

CREATE TABLE avaliacao (
    id INT NOT NULL AUTO_INCREMENT,
    idAvaliador INT NOT NULL,
    idAvaliado INT NOT NULL,
    nota FLOAT NOT NULL CHECK (nota BETWEEN 0 AND 5),
    comentario TEXT,
    PRIMARY KEY (id),
    FOREIGN KEY (idAvaliador) REFERENCES usuario(id),
    FOREIGN KEY (idAvaliado) REFERENCES usuario(id)
);

CREATE TABLE historico_viagem (
    id INT NOT NULL AUTO_INCREMENT,
    idUsuario INT NOT NULL,
    idViagem INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (idUsuario) REFERENCES usuario(id),
    FOREIGN KEY (idViagem) REFERENCES viagem(id)
);

CREATE TABLE uber_compartilhado (
    id INT NOT NULL AUTO_INCREMENT,
    idCriador INT NOT NULL,
    origem VARCHAR(255) NOT NULL,
    destino VARCHAR(255) NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    data_hora DATETIME NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (idCriador) REFERENCES usuario(id)
);

CREATE TABLE uber_passageiros (
    idUber INT NOT NULL,
    idPassageiro INT NOT NULL,
    FOREIGN KEY (idUber) REFERENCES uber_compartilhado(id),
    FOREIGN KEY (idPassageiro) REFERENCES usuario(id),
    PRIMARY KEY (idUber, idPassageiro)
);

CREATE TABLE despesas (
    id INT NOT NULL AUTO_INCREMENT,
    idDevedor INT NOT NULL,
    idCredor INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    pago BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (id),
    FOREIGN KEY (idDevedor) REFERENCES usuario(id),
    FOREIGN KEY (idCredor) REFERENCES usuario(id)
);

CREATE TABLE reportes (
    id INT NOT NULL AUTO_INCREMENT,
    idReportador INT NOT NULL,
    idReportado INT NOT NULL,
    motivo TEXT NOT NULL,
    data_envio DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (idReportador) REFERENCES usuario(id),
    FOREIGN KEY (idReportado) REFERENCES usuario(id)
);