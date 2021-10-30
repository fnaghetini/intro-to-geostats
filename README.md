<p align="left">
  <img src="https://logodownload.org/wp-content/uploads/2015/02/ufmg-logo-2.png" height="80"><br>
</p>

# Introdução à Geoestatística aplicada à Avaliação de Recursos Minerais
### Departamento de Geologia - Instituto de Geociências - UFMG

Geoestatística não é _Estatística aplicada a dados geológicos_. Bom, pelo menos era o que pensava quando ouvia falar sobre o tema nos corredores da faculdade. Na realidade, a **Geoestatística**, ou Estatística Espacial, é *Estatística aplicada a dados que possuem uma posição no espaço*, ou seja, uma ferramenta que pode ser aplicada em diferentes áreas que lidam com dados geoespaciais, desde Sensoriamento Remoto até Avaliação de Recursos Minerais, que é o foco deste material.

Na Geoestatística, trabalhamos com as chamadas **Variáveis Regionalizadas**, ou seja, variáveis que descrevem fenômenos naturais cujas amostras possuem certa estrutura ou interdependência espacial. Já parou para pensar que depósitos minerais não ocorrem de forma aleatória na natureza? Existem uma série de processos metalogenéticos, sejam eles de natureza geoquímica, estrutural e/ou petrológica, que controlam a distribuição espacial dos metais que despertam interesse econômico. Veremos que as Variáveis Regionalizadas podem assumir características não consideradas pela Estatística Clássica, como: _posição no espaço_, _suporte_, _continuidade espacial_ e _anisotropia_.

Este material busca fornecer uma introdução interativa e interessante sobre ferramentas e conceitos geoestatísticos amplamente aplicados na **Avaliação de Recursos Minerais**. Para isso, utilizaremos a linguagem de programação aberta [Julia](https://julialang.org/), o framework geoestatístico open-source [GeoStats.jl](https://juliaearth.github.io/GeoStats.jl/stable/) e o ambiente interativo e responsivo [Pluto.jl](https://github.com/fonsp/Pluto.jl).

<p align="center">
  <img alt="Julia Lang" src="https://github.com/JuliaLang/julia-logo-graphics/blob/master/images/julia-logo-color.svg" height="100"><br><br>
  <img alt="GeoStats.jl" src="https://github.com/JuliaEarth/GeoStats.jl/blob/master/docs/src/assets/logo-text.svg?raw=true" height="120"><br><br>
  <img alt="Pluto.jl" src="https://raw.githubusercontent.com/fonsp/Pluto.jl/dd0ead4caa2d29a3a2cfa1196d31e3114782d363/frontend/img/logo_white_contour.svg" height="80">
</p>

## Estrutura

Este material é dividido em seis módulos:

1. **[💻 Lógica de Programação](https://github.com/fnaghetini/intro-to-geostats/blob/main/1-logica_de_programacao.jl)**

2. **[🛠️ Preparação de Amostras](https://github.com/fnaghetini/intro-to-geostats/blob/main/2-preparacao_de_amostras.jl)**

3. **[🔎 Análise Exploratória](https://github.com/fnaghetini/intro-to-geostats/blob/main/3-analise_exploratoria.jl)**

4. **[📈 Variografia](https://github.com/fnaghetini/intro-to-geostats/blob/main/4-variografia.jl)**

5. **[🎯 Estimação](https://github.com/fnaghetini/intro-to-geostats/blob/main/5-estimacao.jl)**

6. **[🏆 Projeto Final](https://github.com/fnaghetini/intro-to-geostats/blob/main/6-projeto_final.jl)**

No módulo de **Lógica de Programação**, teremos uma breve introdução a alguns conceitos relacionados à lógica de programação (e.g. funções, estruturas condicionais, laços de repetição) e aos recursos interativos do [PlutoUI.jl](https://github.com/JuliaPluto/PlutoUI.jl). No módulo **Preparação de Amostras**, aprenderemos como gerar furos de sondagem a partir das tabelas de Collar, Survey e Assay e a compositar amostras. Já no módulo seguinte, **Análise Exploratória**, abordaremos técnicas de descrição univariada, bivariada e espacial, além de métodos de desagrupamento de amostras. No módulo **Variografia**, teremos nosso primeiro contato com uma das principais ferramentas geoestatísticas, o variograma. No módulo **Estimação**, aprenderemos sobre os principais métodos de estimação utilizados na Avaliação de Recursos Minerais: _Inverso da Potência da Distância (IPD)_, _Krigagem Simples (KS)_ e _Krigagem Ordinária (KO)_. Por fim, no módulo **Projeto Final**, colocaremos em prática todos os conceitos aprendidos nos módulos anteriores e executaremos um projeto de Avaliação de Recursos desde a geração dos furos de sondagem até a validação das estimativas obtidas.

**Nota:** os dados utilizados ao longo dos módulos encontram-se na pasta [data](https://github.com/fnaghetini/intro-to-geostats).

## Instruções

Não se preocupe! Para acessar o conteúdo deste material é bem simples, basta seguir o passo-a-passo abaixo:

1. Baixe o instalador da Linguagem Julia, clicando [aqui](https://julialang.org/downloads/). É necessário que a versão do instalador seja **igual ou superior à versão 1.6.3**;

2. Execute o instalador. A instalação é bem tranquila, basta clicar em _Next/Avançar_ até a conclusão do procedimento;

3. No menu Iniciar, procure por "Julia" e, em seguida, execute este aplicativo. Ele é chamado de **Julia REPL**;

![image](https://user-images.githubusercontent.com/63740520/139559000-5d0123ad-5fe8-4318-b721-8745e880cf1d.png)

4. No Julia REPL, execute os seguintes comandos para instalar o ambiente [Pluto.jl](https://github.com/fonsp/Pluto.jl):
```julia
julia> using Pkg
julia> Pkg.add("Pluto")
```
**Nota:** tenha paciência, esse procedimento pode levar alguns minutos. Você saberá que a instalação terminou ao aparecer `julia>` no Julia REPL.

5. Verifique qual é a versão instalada do Pluto, digitando o seguinte comando no Julia REPL:

```julia
julia> Pkg.status()
```
6. Caso a versão seja igual ou superior à versão **0.17.0**, siga para o passo 7. Caso contrário, digite o seguinte comando, no Julia REPL, para atualizar a versão do Pluto:

```julia
julia> Pkg.update("Pluto")
```

7. Feche o Julia REPL e faça o download deste material, clicando em: **Code > Download ZIP**. Essa opção está localizada no canto superior direito desta página;

![image](https://user-images.githubusercontent.com/63740520/139559269-dbca805f-0b8f-4280-bdad-7f21dfbf3aea.png)

8. Após a conclusão do download, descompacte o arquivo e mova a pasta resultante **intro-to-geostats-main** para algum diretório a sua escolha;

9. Novamente, abra o Julia REPL e execute os comandos a seguir para abrir o ambiente Pluto. Uma janela será aberta no seu navegador;

```julia
julia> using Pluto
julia> Pluto.run()
```

**Nota:** toda vez que quiser abrir qualquer um dos módulos deste material, você deverá executar esses dois comandos.

10. Copie o caminho da pasta **intro-to-geostats-main**, cole-o no campo **Open from file** da janela do Pluto e adicione o sufixo `\nome_do_modulo.jl` ao caminho para abrir o módulo de interesse. Em seguida, clique em **Open**. Aguarde alguns minutos até o conteúdo do módulo carregar. Na figura abaixo, por exemplo, o módulo **Variografia** será aberto:

![image](https://user-images.githubusercontent.com/63740520/139559509-8f699d90-632c-45da-8577-8ad45ac92d2f.png)

**Nota:** os seguintes sufixos abrirão os seis módulos deste material: `\1-logica_de_programacao.jl`, `\2-preparacao_de_amostras.jl`, `\3-analise_exploratoria.jl`, `\4-variografia.jl`, `\5-estimacao.jl` e `\6-projeto_final.jl`. Perceba que esses prefixos se referem aos nomes dos módulos.

**Nota:** tenha paciência, esta etapa pode demorar alguns minutos. Na primeira vez que um determinado módulo é executado, todos os pacotes utilizados nele serão baixados.

**Nota:** você não precisará executar todos esses passos quando quiser abrir um dos módulos. Se você já tiver seguido este passo-a-passo completo em algum momento, para abrir um dos módulos, basta seguir os **passos 9 e 10**.

## Licença

Este repositório encontra-se sob a licença MIT:

```bash
"Uma licença permissiva, curta e simples com condições que exigem apenas a preservação de direitos
autorais e avisos de licença. Trabalhos licenciados, modificações e trabalhos maiores podem ser
distribuídos em termos diferentes e sem código-fonte."
```

Para mais detalhes, consulte o arquivo de [licença](https://github.com/fnaghetini/intro-to-geostats/blob/main/LICENSE).
