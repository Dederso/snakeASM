# 🐍 Snake Competitivo (Assembly x86)

![Assembly](https://img.shields.io/badge/Language-Assembly_x86-red?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-DOSBox-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)

> Um jogo Snake competitivo para dois jogadores, desenvolvido inteiramente em Assembly de baixo nível com acesso direto à memória de vídeo.

---

## 👥 Autores

* **André Guimarães Barros**
* **Klarine Mendonça Silva**

---

## 🎮 Sobre o Jogo

Nesta versão competitiva do clássico Snake, dois jogadores disputam espaço na mesma tela.
### Mecânicas Principais
* **Multiplayer Local:** Dois jogadores simultâneos.
* **Sistema de Cores:** Cada jogador deve comer apenas a maçã da sua cor. Comer a errada pune você e ajuda o oponente.
* **Vidas:** Sistema de 3 vidas para cada jogador.
* **Dificuldade:** Seletor de velocidade no menu inicial (Fácil, Médio, Difícil).

---

## 🕹️ Controles

| Jogador | Cor da Cobra | Teclas de Movimento | Objetivo (Maçã) |
| :--- | :--- | :---: | :--- |
| **Jogador 1** | 🟩 Verde | `W` `A` `S` `D` | Comer Maçã **Verde** |
| **Jogador 2** | 🟥 Vermelha | `Setas` (↑ ↓ ← →) | Comer Maçã **Vermelha** |

**Outros Comandos:**
* `P` - Pausa o jogo
* `Q` - Sair do jogo
* `Enter` - Confirmar no Menu

---

## 🛠️ Instalação e Requisitos

Para rodar este projeto, você precisará de:
1.  **DOSBox** (Emulador DOS)
2.  **Make** (Automação de compilação)

---

## 🚀 Como Executar

### 🪟 No Windows

1. Abra o terminal na pasta `snake WIN`.
2. Execute o comando de automação:
   ```cmd
   make run
   ```
   > **Nota:** Se o DOSBox não abrir, edite o arquivo `makefile` e ajuste a linha `DOSBOX=` para o caminho correto do executável no seu PC.

### 🐧 No Linux

1. Abra o terminal na pasta `snake LIN`.
2. Execute o comando:
   ```bash
   make all
   ```

---
🤖Texto produzido com ajuda de inteligência artificial.

<div align="center">
  <sub>Projeto desenvolvido para a disciplina de Sistemas Embarcados </sub>
</div>
