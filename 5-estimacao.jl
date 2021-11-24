### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ f9fb89e0-36a8-11ec-3fa3-d716ca093060
begin
	# carregando pacotes necessários
	using GeoStats, Statistics
	using CSV, DataFrames, Query
    using PlutoUI, Distributions
    using Plots, StatsPlots, Random
	
	# configurações de visualização
	gr(format=:png)
end;

# ╔═╡ 3e70ffa1-2a50-4dc4-a529-e4361ac6ad5f
html"""
<p style="background-color:lightgrey" xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><span property="dct:title">&nbsp&nbsp🎯&nbsp<b>Estimação</b></span> por <span property="cc:attributionName">Franco Naghetini</span> é licenciado sob <a href="http://creativecommons.org/licenses/by/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1"></a></p>
"""

# ╔═╡ 9f8d2a06-275e-4689-8a69-b1f4dec807b3
PlutoUI.TableOfContents(aside=true, title="Sumário",
						indent=true, depth=2)

# ╔═╡ 0d2c1d74-f691-4805-9aa2-e9d42da04284
md"""
![ufmg-logo](https://logodownload.org/wp-content/uploads/2015/02/ufmg-logo-2.png)
"""

# ╔═╡ 84ad4d5f-b3c3-4c21-89f2-d15396e83d05
md"""
# 🎯 Estimação

Você com certeza já ouviu falar sobre **Modelagem Geológica 3D**. Durante esse procedimento, o geólogo utiliza os dados disponíveis (e.g. furos de sondagem, mapa geológico) e faz algumas inferências para gerar um modelo tridimensional da subsuperfície. Após a geração desse modelo (contínuo), ele normalmente é discretizado em pequenos "tijolos" denominados blocos. Por essa razão, o modelo geológico discretizado é chamado de **modelo de blocos**.

Neste módulo, aprenderemos sobre diferentes **estimadores** (i.e. métodos de estimação) que visam atribuir um valor de teor a cada bloco do modelo de blocos. Para realizar essa tarefa, precisamos de amostras (e.g. furos de sondagem, amostras de solo) e do modelo de blocos, onde realizaremos as estimativas. O modelo de blocos, de forma genérica, pode ser chamado de **domínio de estimação** (ou grid de estimação).

Podemos pensar que a estimação consiste na interpolação de amostras com teores conhecidos para atribuir teores (estimados) a regiões que não foram amostradas. A Figura 01 ilustra o problema de estimação de um bloco, em um contexto bidimensional. O objetivo é ponderar e "combinar" os teores das amostras da vizinhança, representadas pelos triângulos, para estimar o teor médio do bloco. Esse procedimento é realizado para cada bloco do modelo de blocos!

![Figura 01](https://i.postimg.cc/mrBQryqN/estimation.png)

_**Figura 01:** Exemplo de estimação de um bloco (2D). O intuito é estimar o teor médio do bloco a partir da ponderação dos teores das amostras circunvizinhas (triângulos). Extraído de Sinclair & Blackwell (2006)._

> ⚠️ Neste módulo, adotaremos uma convenção para facilitar a compreensão do conteúdo. O processo de atribuir valores de teor a unidades discretizadas será chamado de **estimação**, do inglês *estimation*. Por outro lado, os teores resultantes do processo de estimação serão chamados de **estimativas**, do inglês *estimates*. Ressalta-se que, na indústria, o termo *estimativa* é comumente utilizado para se referir tanto ao processo quanto aos valores estimados.

Este módulo é estruturado de forma a seguir o fluxo de trabalho adotado pelo [GeoStats.jl](https://github.com/JuliaEarth/GeoStats.jl):

- **Etapa 1:** Criação do domínio de estimação;
- **Etapa 2:** Definição do problema de estimação;
- **Etapa 3:** Definição do estimador;
- **Etapa 4:** Solução do problema de estimação.

Entraremos em detalhe sobre cada uma das etapas durante o módulo.
"""

# ╔═╡ 035ef186-a067-44c0-b9a0-bdac6f4d770b
md"""
>##### 📚 Sobre
>- Você pode exportar este notebook como PDF ou HTML estático. Para isso, clique no ícone 🔺🔴, localizado no canto superior direito da pagina. Entretanto, ambos os formatos não são compatíveis com os recursos interativos do notebook.
>- Caso deseje executar alguma célula do notebook, clique no ícone ▶️, localizado no canto inferior direito da célula.
>- Algumas células encontram-se ocultadas (e.g. células que geram os plots). Você pode clicar no ícone 👁️, localizado no canto superior esquerdo da célula, para ocultá-la ou exibí-la.
>- A explicação das células que geram os plots está fora do escopo deste notebook. Entretanto, a sintaxe é bem intuitiva e pode ser facilmente compreendida!
>- Você pode ainda clicar no ícone `...`, no canto superior direito de uma célula, para excluí-la do notebook.
>- Algumas células deste notebook encontram-se encapsuladas pela expressão `md"..."` (e.g. esta célula). Essas são células de texto chamadas de *markdown*. Caso deseje aprender um pouco mais sobre a linguagem *markdown*, clique [aqui](https://docs.pipz.com/central-de-ajuda/learning-center/guia-basico-de-markdown#open).
>- No Pluto, todos os pacotes devem ser importados/baixados na primeira célula do notebook. Clique no ícone 👁️ para exibir essa célula ou consulte a seção *Pacotes utilizados* deste notebook para saber mais informações sobre os pacotes.
>- Utilize a macro ` @which` para verificar a qual pacote uma determinada função pertence.
>- Você pode utilizar este notebook da forma que quiser, basta referenciar [este link](https://github.com/fnaghetini/intro-to-geostats). Consulte a [licença]  (https://github.com/fnaghetini/intro-to-geostats/blob/main/LICENSE) para saber mais detalhes.
>- Para mais informações acesse o [README](https://github.com/fnaghetini/intro-to-geostats/blob/main/README.md) do projeto 🚀
"""

# ╔═╡ 564423c2-6a3e-4919-a6fc-32f7d1664f86
md"""
## 1. Conceitos básicos

Nesta primeira seção, teremos uma breve introdução a três dos principais *estimadores lineares ponderados* utilizados na *estimação* de recursos minerais:

- Inverso da Potência da Distância;
- Krigagem Simples;
- Krigagem Ordinária.
"""

# ╔═╡ a069cc27-d08e-47b4-9f75-24dab178b333
md"""
### Estimadores lineares ponderados

Os três métodos listados acima compartilham a mesma equação para calcular estimativas $\hat{z}(x_o)$:

```math
\hat{z}(x_o) = \sum_{i=1}^{n} w_i \cdot z(x_i) = w_1 \cdot z(x_1) + w_2 \cdot z(x_2) + \cdots + w_n \cdot z(x_n)
```

em que $\{z(x_i)\}_{i=1}^{n}$ são os valores das $n$ amostras que serão utilizadas na estimação da posição $x_0$, enquanto $\{w_i\}_{i=1}^{n}$ representam os pesos atribuídos a cada $i$-ésima amostra (*Isaaks & Srivastava, 1989*).

> ⚠️ Na Estatística, é muito comum representar estimativas com o símbolo "^".

Os métodos caracterizados por essa equação são denominados **estimadores lineares ponderados** e se diferenciam entre si na forma que os pesos $w_i$ são atribuídos a cada amostra.
"""

# ╔═╡ 9b31cfec-400a-4068-84b8-8170b3c8ab58
md"""
### Inverso da Potência da Distância (IPD)

Uma abordagem intuitiva para atribuir pesos é pensar que amostras mais distantes do ponto a ser estimado devem receber pesos menores, enquanto amostras próximas devem receber pesos maiores.

>⚠️ De acordo com a 1ª Lei da Geografia, proposta por Waldo Tobler na década de 1970: *"tudo está relacionado a tudo, mas coisas mais próximas são mais parecidas (relacionadas) entre si do que coisas mais distantes"*.

Nesse sentido, no método **Inverso da Potência da Distância (IPD)**, o peso $w_i$ de uma amostra $z(x_i)$ é inversamente proporcional a sua distância Euclidiana $d_i$ até o ponto que está sendo estimado $\hat{z}(x_o)$ (*Isaaks & Srivastava, 1989*). É comum escolhermos uma potência $p$ arbitrária associada à distância:

```math
\hat{z}(x_o) = \frac{\sum_{i=1}^{n}\frac{1}{d_i^p}z(x_i)} {\sum_{i=1}^{n}\frac{1}{d_i^p}}
```

em que $w_i = \frac{1}{d_i^p}$. O denominador da equação acima é uma **condição de fechamento** que garante que a soma dos $n$ pesos sempre totalize em 1.

>⚠️ Na Mineração, é muito comum adotar-se $p=2$. Nesse caso específico, o método pode ser chamado de **Inverso do Quadrado da Distância (IQD)**.

A Figura 02 mostra um gráfico de distância por peso para diferentes potências $p$:
"""

# ╔═╡ 951ca515-39a9-4e95-a53c-6fd7977a4cbb
begin
	# geração dos dados
	ds = collect(1:100)
	ws = [@. 1/(ds^p) for p in 1:5]

	# labels de cada gráfico
	labels = ["p=$p" for p in 1:5]

	# plotagem
	plot(ws, label=hcat(labels...), xlabel="Distância", ylabel="Peso", lw=1.5)
end

# ╔═╡ 28acc648-ac4a-4d1c-86ce-5bb329c6a141
md"""
_**Figura 02:** Relação entre distância e peso para diferentes potências $p$._
"""

# ╔═╡ 25ddae7c-a276-417e-92c8-9fc2076db219
md"""
##### Observações

- Com o aumento da potência $p$, mais rapidamente os pesos diminuem em função do aumento da distância entre as amostras e o ponto a ser estimado.
"""

# ╔═╡ 69c94901-8d49-4fcc-97f4-bf857b04e627
md"""
### Krigagem

**Krigagem** é um termo genérico aplicado a uma família de métodos de estimação que buscam *minimizar o erro (ou resíduo) da estimação*, normalmente pela estratégia de Mínimos Quadrados (*Sinclair & Blackwell, 2006*). Alguns exemplos são: Krigagem Simples (KS), Krigagem Ordinária (KO), Krigagem Universal (KU) e Krigagem com Deriva Externa (KDE). Ainda que todos esses estimadores estejam disponíveis no [GeoStats.jl](https://github.com/JuliaEarth/GeoStats.jl), neste módulo, abordaremos apenas os dois primeiros.

>⚠️ Um **resíduo** (ou erro) consiste na diferença entre o valor estimado e o valor real $r = \hat{z}(x) - z(x)$ para um determinado ponto pertencente ao domínio de estimação.

Os métodos de Krigagem estão associados ao acrônimo **B.L.U.E.** (*Best Linear Unbiased Estimator*). Eles são estimadores **lineares**, pois suas estimativas são combinações lineares ponderadas das amostras disponíveis. Além disso, são **não enviesados**, já que a média dos resíduos é idealmente igual a zero. Por fim, esses métodos são **ótimos**, pois objetivam minimizar a variância dos resíduos $\sigma_r^2$, que pode ser escrita como (*Isaaks & Srivastava, 1989*):

```math
\sigma_r^2 = \frac{1}{n} \sum_{i=1}^{n} [\hat{z}(x_i) - z(x_i)]^2 = E[\hat{z}(x_i) - z(x_i)]^2
```

A minimização de $\sigma_r^2$ é justamente o diferencial dos estimadores da família da Krigagem, já que o método IPD também é linear e não enviesado (*Isaaks & Srivastava, 1989*). A Figura 03 mostra um exemplo de duas distribuições de resíduos hipotéticas...
"""

# ╔═╡ 78866735-d01e-4c9d-abec-3ed54b8ed612
begin
	# semente aleatória
	Random.seed!(1234)

	# N(μ=0, σ²=1)
	𝒩₁ = Normal()
	# N(μ=0, σ²=3)
	𝒩₂ = Normal(0,3)

	# geração de Z₁~ N(μ=0, σ²=1)
	Z₁ = rand(𝒩₁, 2500)
	# geração de Z₂ ~ N(μ=0, σ²=3)
	Z₂ = rand(𝒩₂, 2500)

	# histogramas
	histogram(Z₂, bins=:scott, label="σ² = 3", alpha=0.7)
	histogram!(Z₁, bins=:scott, alpha=0.7, label="σ² = 1",
			   xlabel="Resíduo", ylabel="Freq. Absoluta")
end

# ╔═╡ d5d0ef84-7c79-4d5e-af5c-52090b1dd233
md"""
_**Figura 03:** Exemplos de duas distribuições de resíduos hipotéticas._
"""

# ╔═╡ fa6d5e16-ad13-4e68-8ee8-d846db277917
md"""
##### Observações

- Ambas as distribuições de resíduos são *não enviesadas*, já que apresentam média igual a zero;
- A distribuição azul apresenta uma maior dispersão de resíduos $\sigma_r^2$ do que a distribuição laranja;
- O diferencial dos métodos de Krigagem é justamente minimizar essa dispersão dos resíduos $\sigma_r^2$, ou seja, o erro da estimação.
"""

# ╔═╡ 956f6c67-93f1-41bf-b921-e893111bbebe
md"""
#### Krigagem Simples (KS)

Para se utilizar a **Krigagem Simples (KS)**, um estimador da família da Krigagem, deve-se ter conhecimento, à priori, da média do depósito $\mu$. Esse seria o "maravilhoso caso em que conhecemos a média" (*Chilès & Delfiner, 2012*).

Na KS, ao minimizar a variância da estimação $\sigma_r^2$, obtemos as seguintes equações (*Sinclair & Blackwell, 2006*):

```math
\begin{bmatrix}
	\gamma(x_1,x_1) & \gamma(x_1,x_2) & \cdots & \gamma(x_1,x_n) \\
	\gamma(x_2,x_1) & \gamma(x_2,x_2) & \cdots & \gamma(x_2,x_n) \\
	    \vdots      &     \vdots      & \ddots &      \vdots     \\
	\gamma(x_n,x_1) & \gamma(x_n,x_2) & \cdots & \gamma(x_n,x_n) \\
\end{bmatrix}

\begin{bmatrix}
	  w_1  \\
	  w_2  \\
	\vdots \\
	  w_n  \\
\end{bmatrix}

=

\begin{bmatrix}
	\gamma(x_1,x_0) \\
	\gamma(x_2,x_0) \\
	    \vdots      \\
	\gamma(x_n,x_0) \\
\end{bmatrix}
```
em que $\gamma(x_i, x_j)$ representa o valor do variograma para cada par de amostras $(x_i,x_j)$ utilizadas na estimação; $w_i$ representa os pesos que serão atribuídos às amostras e $\gamma(x_i, x_0)$ é o valor do variograma entre cada amostra $x_i$ e o ponto a ser estimado $x_0$. O passo seguinte é realizar uma simples manipulação algébrica para isolar o vetor de pesos que, por sua vez, é a informação que desejamos obter.

Especificamente na KS, a soma dos pesos $w_i$ não totaliza em 1 e o peso restante é atribuído ao valor da média do depósito. Chamaremos esse peso atribuído a média global de $w_\mu$:

```math
w_\mu = 1 - \sum_{i=1}^{n}w_i
```

>⚠️ A demonstração de como obter o sistema linear acima foge do escopo deste material. Para mais detalhes, consulte *Isaaks & Srivastava (1989)*.

Como raramente temos acesso à média do depósito, a KS não é um método tão utilizado como a Krigagem Ordinária, que veremos a seguir (*Sinclair & Blackwell, 2006*).
"""

# ╔═╡ eab5920c-fd1f-4e03-a6f3-90e3ce731b6e
md"""
#### Krigagem Ordinária (KO)

Ao contrário da KS, na **Krigagem Ordinária (KO)**, a média do depósito não precisa ser conhecida. Nesse método, a minimização de $\sigma_r^2$ é realizada com uma restrição de que a soma dos pesos $w_i$ deve totalizar em 1 (*Sinclair & Blackwell, 2006*).

Essa restrição é introduzida no processo de minimização a partir da criação de uma variável artificial, o *parâmetro de Lagrange* $\lambda$. Portanto, uma equação adicional, equivalente a zero, é introduzida no sistema linear da KO (*Sinclair & Blackwell, 2006*):

```math
\begin{bmatrix}
	\gamma(x_1,x_1) & \gamma(x_1,x_2) & \cdots & \gamma(x_1,x_n) &    1   \\
	\gamma(x_2,x_1) & \gamma(x_2,x_2) & \cdots & \gamma(x_2,x_n) &    1   \\
	    \vdots      &     \vdots      & \ddots &      \vdots     & \vdots \\
	\gamma(x_n,x_1) & \gamma(x_n,x_2) & \cdots & \gamma(x_n,x_n) &    1   \\
	       1        &         1       & \cdots &        1        &    0   \\
\end{bmatrix}

\begin{bmatrix}
	  w_1   \\
	  w_2   \\
	\vdots  \\
	  w_n   \\
	\lambda \\
\end{bmatrix}

=

\begin{bmatrix}
	\gamma(x_1,x_0) \\
	\gamma(x_2,x_0) \\
	    \vdots      \\
	\gamma(x_n,x_0) \\
	       1        \\
\end{bmatrix}
```

>⚠️ Note que o sistema linear da KO é muito similar àquele da KS. A única diferença é que adicionamos uma equação extra para garantir o fechamento.

Como a soma dos pesos $w_i$ totaliza em 1, não é necessário atribuir um peso $w_\mu$ à média real e, consequentemente, não precisamos ter conhecimento desse parâmetro. Isso corrobora o fato de a KO ser o estimador mais utilizado na indústria.
"""

# ╔═╡ 5a9f4bbf-202f-4191-b59d-f2bed05347ae
md"""
## 2. Criação do domínio de estimação

Assim como no módulo anterior, também utilizaremos a base de dados [Walker Lake](https://github.com/fnaghetini/intro-to-geostats/blob/main/data/Walker_Lake.csv). Primeiramente, vamos importar e georreferenciar esses dados. Novamente, apenas a variável `Pb` (em %) será considerada...
"""

# ╔═╡ 669d757d-dc19-43e1-b96f-8c1aa31f7579
begin
	# variáveis de interesse
	VARS = [:X,:Y,:Pb]
	# diretório dos dados
	DIR = "data/Walker_Lake.csv"
	
	# importação dos dados
	walkerlake = CSV.File(DIR, type = Float64) |> DataFrame
	
	# seleção das variáveis de interesse e remoção dos valores faltantes
	f1(dados) = select(dados, VARS)
	f2(dados) = dropmissing(dados)
	wl = walkerlake |> f1 |> f2 |> DataFrame
	
	# georreferenciamento dos dados
	geowl = georef(wl, (:X,:Y))
end

# ╔═╡ 207ca8d7-08df-47dd-943b-7f7846684e3b
md"""
Agora, podemos criar o nosso **domínio de estimação**, ou seja, um grid 2D onde calcularemos as estimativas. Para definirmos esse domínio, precisamos informar três parâmetros à função `CartesianGrid`:

- Coordenada do ponto de origem do domínio (vértice inferior esquerdo);
- Coordenada do ponto de término do domínio (vértice superior direito);
- Número de células em cada direção (X e Y).

Definiremos a "caixa delimitadora" do grid por meio da criação de um retângulo aderente à malha amostral, utilizando a função `boundingbox`. Dessa forma, podemos encontrar as coordenadas de origem e término do domínio, obtendo as coordenadas mínima e máxima do retângulo, respectivamente.

Ao invés de informarmos o número de células em cada direção, é mais conveniente informarmos as dimensões que cada uma das células deve ter, ou seja, o *tamanho da célula*. Para isso, basta fazermos algumas manipulações, como veremos a seguir.

>⚠️ Aqui o termo *célula* foi adotado simplesmente por se tratar de um problema 2D. Em contextos 3D, o termo *bloco* é mais comum, como veremos no próximo módulo.

O tamanho da célula (ou bloco) é um parâmetro crucial quando o objetivo é realizar uma *Krigagem de blocos*. Como neste módulo realizaremos uma *Krigagem de pontos*, ou seja, estimaremos o centroide de cada célula, não iremos discutir sobre esse parâmetro com tanto rigor. Definiremos o tamanho das células como ½ do espaçamento médio entre amostras vizinhas que, no nosso caso, é de 10 m x 10 m.

>⚠️ Na estimação 3D de recursos, uma [heurística](https://en.wikipedia.org/wiki/Heuristic) comumente adotada é definir o tamanho do bloco como ⅓ a ½ do espaçamento médio entre amostras vizinhas (*Abzalov, 2016*). Caso queira investigar as diferenças entre Krigagem de pontos e Krigagem de blocos, consulte *Isaaks & Srivastava (1989)*.
"""

# ╔═╡ b14c6b92-81cc-482f-9746-d9a011cff5cd
begin
	# caixa delimitadora das amostras
    bbox = boundingbox(geowl)
	
	# lados da caixa delimitadora
	extent = maximum(bbox) - minimum(bbox)
	
	# Tamanho dos blocos em cada direção
	blocksizes = (10., 10.)
	
	# Número de blocos em cada direção
	nblocks = ceil.(Int, extent ./ blocksizes)

	# Modelo de blocos para realização de estimativas
    grid = CartesianGrid(minimum(bbox), maximum(bbox), dims = Tuple(nblocks))
end

# ╔═╡ 9055d652-1c6c-4d73-9302-d58a35ffb975
md"""
A Figura 04 ilustra a distribuição espacial das amostras de Pb (%) sobre o grid de estimação definido acima. O nosso objetivo, neste módulo, é estimar valores de `Pb` para cada centroide das células.
"""

# ╔═╡ 37462572-3c3d-46e1-8e2d-266e86470b6a
begin
	# plotagem do domínio de estimação
	plot(grid, lw=0.5, alpha=0.5, grid=false)

	# plotagem das amostras
	plot!(geowl, marker=(:jet,:circle,3), markerstrokewidth=0.3,
		  title="Pb (%)", xlims=(0,280), ylims=(0, 300), size=(500,500))
end

# ╔═╡ 4469f1a2-6054-4ba0-b402-03892d3a90e4
md"""
_**Figura 04:** Amostras de Pb (%) plotadas sobre o domínio de estimação (grid)._
"""

# ╔═╡ 2531eee8-72c5-4056-879c-b1b65273d51a
md"""
## 3. Definição do problema de estimação

O passo seguinte é definir o **problema de estimação**. Para isso, basta informarmos três parâmetros à função `EstimationProblem`:

- Amostras georreferenciadas;
- Domínio de estimação;
- Variável que será estimada.

No nosso caso, conforme mencionado anteriormente, estamos interessados em estimar os centroides das células e, para isso, utilizaremos a função `centroid`.

> ⚠️ *Centroide* é um termo genérico para se referir ao ponto central de uma célula.
"""

# ╔═╡ 36033c09-267c-48df-b6cd-ce2ee2a5eac6
begin
	# centroides das células
	centroides = Collection(centroid.(grid))

	# definição do problema de estimação
	problema = EstimationProblem(geowl, centroides, :Pb)
end

# ╔═╡ 3a034b2e-97a2-4a4f-bc60-c6634082254a
md"""
##### Observações

- Note que a saída da célula acima fornece um resumo do nosso problema de estimação:
    - `data`: amostras (469 amostras);
    - `domain`: domínio de estimação (725 centroides de células);
    - `variables`: variável a ser estimada (Pb).
"""

# ╔═╡ 22b5fc9a-9d08-4e36-a500-329e5036081f
function sph2cart(azi)
	θ = deg2rad(azi)
	sin(θ), cos(θ)
end;

# ╔═╡ 8aaca25b-8ebc-418c-ad48-344a31ba8ed9
md"""
## 4. Definição do estimador

Além de escolhermos qual estimador utilizaremos e obtermos o modelo de variograma (apenas no caso da Krigagem), devemos definir os chamados *parâmetros de vizinhança* ou, simplesmente, **vizinhança**. A vizinhança restringe o número de amostras que serão utilizadas na estimação de um ponto.

Segundo *Chilès & Delfiner (2012)*, a teoria sempre foi construída considerando todas as $n$ amostras disponíveis para calcular cada uma das estimativas. Entretanto, na prática, $n$ pode ser suficientemente grande a ponto do cálculo das estimativas não ser computacionalmente viável. Nesse sentido, uma prática comum é definir um **número mínimo e máximo de amostras** que serão utilizadas para estimar cada ponto. Essas informações são exemplos de parâmetros de vizinhança e são representados pelos argumentos `minneighbors` e `maxneighbors`, respectivamente.

Outro parâmetro importante é a **área de busca**, que, normalmente, é representada por uma elipse. Durante a estimação, o centroide da elipse coincide com a posição do ponto a ser estimado. Dessa forma, apenas as amostras que se situarem no interior da área de busca poderão ser utilizadas na estimação. A elipse (ou elipsoide) de busca é representada pelo parâmetro `neighborhood`.

> ⚠️ As dimensões de uma elipse são definidas por dois eixos principais ortogonais entre si, enquanto sua orientação é definida por uma rotação em relação ao Norte (i.e. azimute). É comum utilizar a elipse de anisotropia (obtida durante a variografia) como elipse de busca, uma vez que ela nos indica até qual distância duas amostras apresentam interdependência espacial.
"""

# ╔═╡ 07175b65-bf21-49c4-9bfa-be5cf000f2ba
begin
	# variância amostral (definindo o patamar)
	σ² = var(geowl[:Pb])

	# elipsoide de anisotropia
	elp = Ellipsoid([100.0,35.0],[0], convention = GSLIB)

	# modelo de variograma
	γ = SphericalVariogram(nugget = 3.0,
					  	   sill = Float64(σ²),
					       distance = metric(elp))
end;

# ╔═╡ 045cdf16-d264-4b5d-990b-c1bd2acb5613
md"""
Considerere uma estimação em que os números mínimo e máximo de amostras são iguais a 2 e 5, respectivamente. A elipse de busca apresenta uma rotação de 45°, ou seja, seu maior eixo está alinhado ao azimute 045°. A Figura 05 mostra três situações distintas que podem ocorrer durante a estimação do centroide de um bloco. As amostras em vermelho são externas à área de busca e não podem ser utilizadas na estimação, enquanto as amostras verdes, por se situarem dentro da elipse de busca, podem.

- No **Cenário A**, como existem 4 amostras no interior da elipse e o máximo permitido é de 5 amostras, todas elas serão utilizadas na estimação do centroide;

- No **Cenário B**, as 2 amostras internas à área de busca serão utilizadas na estimação;

- No **Cenário C**, como apenas 1 amostra está inserida dentro da elipse de busca e o mínimo de amostras é igual a 2, o centroide do bloco *não* será estimado.

![Figura_05](https://i.postimg.cc/HLgMG7Sr/elipses.jpg)

_**Figura 05:** Estimação do centroide de um bloco. (A) As quatro amostras internas à elipse de busca são utilizadas na estimação. (B) As duas amostras internas à elipse de busca são utilizadas na estimação. (C) Como não há amostras suficientes, o centroide não é estimado. Figura elaborada pelo autor._
"""

# ╔═╡ 79c812cf-849a-4eea-93d2-b08a3844d5a7
md"""
No nosso exemplo, iremos definir três estimadores distintos: IQD, KS e KO. Os números máximo e mínimo de amostras serão 4 e 8, respectivamente.

No caso dos estimadores KS e KO, utilizaremos o modelo de variograma `γ` e uma elipse de busca `elp` igual à elipse de anisotropia. A média , que deve ser informada no caso da KS, será definida como o valor da média desagrupada de Pb `μₚ`.

> ⚠️ O modelo de variograma `γ` utilizado apresenta o eixo primário alinhado N-S, com um alcance de 100 metros e um eixo segundário alinhado E-W, com um alcance de 35 metros. O efeito pepita considerado foi de 3.0, e corresponde a $\approx$ 30% do valor do patamar.
"""

# ╔═╡ b2cb5618-72ba-43a3-9b04-cb2a8821bfa9
begin
	# média desagrupada
    μₚ = mean(geowl, :Pb, 25.)
	
	# IQD
	IQD = IDW(:Pb => (power=2, neighbors=8))

	# KS
    KS = Kriging(
		:Pb => (variogram=γ, mean=μₚ, neighborhood=elp,
			    minneighbors=4, maxneighbors=8)
	)

	# KO
    KO = Kriging(
		:Pb => (variogram=γ, neighborhood=elp,
			    minneighbors=4, maxneighbors=8)
	)
end;

# ╔═╡ 14ba26ab-db0d-4993-9b98-56309ff23389
md"""
## 5. Solução do problema de estimação

Para gerar as de estimativas de Pb (%), resolvemos o problema definido com os três estimadores. Para isso, devemos passar o problema de estimação e o estimador como parâmetros da função `solve`. Clique na caixa abaixo para calcular as estimativas...

Calcular estimativas: $(@bind run CheckBox())
"""

# ╔═╡ d5977fdd-c9bc-4589-ae0e-f6cac6973fbb
if run
	sol_iqd = solve(problema, IQD)
end

# ╔═╡ e570281a-39e3-438f-9c4a-395f321f12d4
if run
	sol_ks = solve(problema, KS)
end

# ╔═╡ 4af2bbf9-fc03-49d0-a19f-f34356c897f7
if run
	sol_ko = solve(problema, KO)
end

# ╔═╡ 73b54c21-7b69-429b-a088-fba3d0c09459
if run
	md"""
	Agora que os teores de Pb foram estimados, clique na caixa abaixo para visualizar o resultado (Figura 06). Em seguida, utilize a lista suspensa abaixo para selecionar a solução que deseja visualizar...

	Visualizar estimativas: $(@bind viz CheckBox())
	"""
end

# ╔═╡ 5f90093b-4b1e-4e0d-b84c-4232bd3c1b1a
if run && viz
	md"""
	Solução: $(@bind solucao Select(["IQD", "KS", "KO"], default="KO"))
	"""
end

# ╔═╡ a49e5f8d-09cf-4baf-b7b4-d43858df8089
if run && viz	
	if solucao == "IQD"
		sol = sol_iqd
	elseif solucao == "KS"
		sol = sol_ks
	elseif solucao == "KO"
		sol = sol_ko
	end
end;

# ╔═╡ 60db4fd5-f06c-4821-a7ed-2f63033653ff
if run && viz
	ẑ = sol |> @map({Pb = _.Pb, geometry = _.geometry}) |> GeoData
end;

# ╔═╡ 2e9b95c5-a687-4881-b69e-6567ade520cb
begin
	if run && viz
		# plotagem das estimativas		
		plot(ẑ, color=:jet, xlabel="X", ylabel="Y",
			 xlims=(0,280), ylims=(0, 300),clims = (0,12),
			 marker=(:square,10), markerstrokewidth=0.2,
			 title="Pb (%)", size=(500,500))

		# plotagem de amostras
		plot!(geowl, color=:jet, marker=(:circle,3),
			  markerstrokecolor=:black, markerstrokewidth=0.5,
		      title="Pb (%)")
	end
end

# ╔═╡ 981efb6c-b1ea-4577-9c40-f3f374a23ba1
if run && viz
	md"""
	_**Figura 06:** Visualização das estimativas de Pb por $solucao._
	"""
end

# ╔═╡ 4ce1c65d-701c-4615-90aa-9f6469e47211
if run && viz
	md"""
	##### Observações

	- Visualmente, as estimativas geradas por KO são muito similares àquelas geradas por KS, mas distintas daquelas produzidas pelo IQD;
	- As estimativas geradas por Krigagem são muito mais contínuas na direção N-S do que na direção E-W. Esse resultado reflete o modelo de variograma informado e é coerente com a distribuição espacial dos teores de Pb (%) que, por sua vez, são também mais contínuos na direção N-S;
	- Como discutido no módulo anterior, essa base de dados foi gerada a partir do modelo digital de elevação da região de Walker Lake, nos EUA. Nessa região, há uma serra orientada na direção N-S, o que valida a nossa hipótese de que os dados são mais contínuos ao longo dessa direção;
	- Como não é possível informar um modelo de variograma na estimação por IQD, esse estimador não apresentou um desempenho tão bom ao reproduzir a maior continuidade do fenômeno (i.e. mineralização de Pb) na direção N-S;
	- Esse exemplo enfatiza a importância do modelo de variograma na estimação. É justamente esse parâmetro que nos permite inserir o conhecimento geológico no cálculo das estimativas!
	"""
end

# ╔═╡ a2e173e6-fe66-44e6-b371-3ae194d7b0f9
md"""
## 6. Validação das estimativas

Uma etapa tão importante quanto a própria estimação é a **validação das estimativas** resultantes.

Existem diferentes abordagens de validação das estimativas, sendo a principal delas a **inspeção visual**, já realizada na seção anterior. Esse procedimento permite avaliar se as estimativas geradas fazem sentido geológico, ou seja, se elas são coerentes com as direções principais do(s) fenômeno(s) que controla(m) a mineralização (e.g. zonas de cisalhamento, estratos mineralizados). Além disso, durante essa inspeção, devemos verificar se "ilhas de altos teores" indesejadas foram geradas. Essa situação é muito comum em depósitos erráticos (e.g. Au), em função da presença de poucos valores extremamente altos no depósito que podem resultar em estimativas superotimistas.

Uma outra inspeção que deve ser realizada é a **validação global das estimativas**. Para isso, devemos comparar as estatísticas desagrupadas das amostras com as estatísticas associadas às estimativas obtidas. Segundo *Sinclair & Blackwell (2006)*, os métodos de Krigagem levam em consideração a redundância de informação ao atribuir pesos às amostras. Em outras palavras, amostras muito próximas entre si são consideradas redundantes e recebem pesos menores. Portanto, como a Krigagem realiza um desagrupamento intrínseco, é mais conveniente comparar as estatísticas das estimativas resultantes com as estatísticas desagrupadas.

A seguir, compararemos quatro sumários estatísticos da variável Pb (%):
- Teores amostrais desagrupados;
- Teores estimados por IQD;
- Teores estimados por KS;
- Teores estimados por KO.
"""

# ╔═╡ e49569b3-0231-4b8e-98d9-21c68c4b1160
if run
	# tamanho da janela de desagrupamento
	s = 25.0

	# sumário estatístico de Pb desagrupado
	sum_desag = DataFrame(teor = "Pb (desagrupado)",
					  	  X̄    = mean(geowl, :Pb, s),
					  	  S²   = var(geowl, :Pb, s),
					  	  q10  = quantile(geowl, :Pb, 0.1, s),
					  	  md   = quantile(geowl, :Pb, 0.5, s),
					  	  q90  = quantile(geowl, :Pb, 0.9, s))
end;

# ╔═╡ 260d5fa1-b2d9-4e9d-9154-c07f2959bce5
md"""
> ⚠️ Para visualizar os sumários estatísticos, a caixa *Calcular estimativas* deve estar marcada.
"""

# ╔═╡ 6b4e35a1-4f1a-4745-9370-f982762af210
function sumario_est(est, id::String)
	q10 = quantile(est[:Pb], 0.1)
	q90 = quantile(est[:Pb], 0.9)
	
	df = DataFrame(teor = id,
                   X̄    = mean(est[:Pb]),
                   S²   = var(est[:Pb]),
                   q10  = q10,
				   md   = median(est[:Pb]),
				   q90  = q90)
				
	return df
end;

# ╔═╡ b657f40a-b586-4011-ad48-aa18b0a46dc3
if run
	[sum_desag
 	 sumario_est(sol_iqd, "Pb (IQD)")
 	 sumario_est(sol_ks, "Pb (KS)")
 	 sumario_est(sol_ko, "Pb (KO)")]
end

# ╔═╡ b8589ac8-7305-48c1-8dff-880a7c659059
if run
	md"""
	##### Observações

	- Vamos focar nas estatísticas `X̅` e `S²`, que representam média e variância, respectivamente;
	- Os três métodos produziram estimativas cujas médias são próximas ao valor da média desagrupada;
	- Os três métodos produziram estimativas suavizadas (i.e. com menores dispersões), fato evidenciado pelos valores de variância que, por sua vez, são sempre inferiores à variância desagrupada. A KS foi o estimador que gerou estimativas mais suavizadas;
	- Veja como a inspeção visual é uma abordagem de validação importante. Se avaliássemos apenas os sumários estatísticos, provavelmente, chegaríamos à conclusão que o IQD era o método mais adequado, quando, na verdade, suas estimativas não representam, de forma fiel, a direção preferencial N-S da mineralização;
	- A seguir, discutiremos outra abordagem de validação para avaliar (qualitativamente) o grau de suavização das estimativas obtidas.
	"""
end

# ╔═╡ 466c7891-f632-4c02-990a-b5a99c1c162a
md"""
Um outro ponto que merece a nossa atenção é o **grau de suavização** das estimativas produzidas. Para isso, utilizaremos um gráfico que já conhecemos, o Q-Q Plot.

O Q-Q plot entre os teores amostrais e os teores estimados pode ser utilizado para realizar uma comparação entre ambas as distribuições. Podemos analisar, visualmente, o grau de suavização dos diferentes estimadores a partir desse gráfico bivariado.

A Figura 07 mostra os Q-Q plots entre os teores amostrais de Pb e os teores estimados de Pb pelos três métodos. Quanto mais distantes forem os pontos plotados da função identidade $X=Y$, mais suaves são as estimativas em relação à distribuição amostral.

> ⚠️ Para visualizar os Q-Q plots, a caixa *Calcular estimativas* deve estar marcada.
"""

# ╔═╡ 03d1da66-8202-4415-a44d-8c204e740960
if run
	qq_iqd = qqplot(
				   geowl[:Pb], sol_iqd[:Pb],
		           legend=:false, line=:red,
				   marker=(:red, :circle, 3),
                   xlabel="Pb amostral (%)",
		           ylabel="Pb estimado (%)",
                   title="IQD"
                   )
	
    qq_ks = qqplot(
				   geowl[:Pb], sol_ks[:Pb],
				   marker=(:blue, :circle, 3),
                   line=:blue, legend=:false,
		           xlabel="Pb amostral (%)",
                   title="KS"
                   )
 
    qq_ko = qqplot(
				   geowl[:Pb], sol_ko[:Pb],
		           line=:green, legend=:false,
				   marker=(:green, :circle, 3),
                   xlabel="Pb amostral (%)",
                   title="KO"
				  )

    plot(qq_iqd, qq_ks, qq_ko, layout=(1,3), size=(700,500))

end

# ╔═╡ 5b07d44b-af44-425b-9e3e-9a5f643e840d
if run
	md"""
	_**Figura 07:** Q-Q plots entre os teores amostrais e estimados de Pb (%)._
	"""
end

# ╔═╡ 817bf734-d8a0-43cd-9553-a7980152afe5
if run
	md"""
	##### Observações

	- Os três métodos geraram estimativas suavizadas. Note que, pela rotação dos pontos em relação à reta $X=Y$, os teores de Pb estimados apresentam sempre dispersões inferiores em relação à dispersão dos teores de Pb amostrais. Esse fato é ligeiramente mais evidente no caso da KS;
	- Em geral, há uma superestimação dos teores mais baixos e uma subestimação dos teores mais altos;
	- Os estimadores da família da Krigagem tendem a gerar estimativas que não honram a real variabilidade do depósito (i.e. mais suavizadas). Uma alternativa seria a utilização de técnicas de **Simulação Geoestatística**. Para ter uma breve introdução a esse tópico, confira este [notebook](https://github.com/juliohm/CBMina2021/blob/main/notebook2.jl) e esta [videoaula](https://www.youtube.com/watch?v=3cLqK3lR56Y&list=PLG19vXLQHvSB-D4XKYieEku9GQMQyAzjJ) do Prof. Michael Pyrcz, da University of Texas.
	"""
end

# ╔═╡ b1b823ac-f9cf-4e5b-a622-4274f3785567
md"""
## Referências

*Abzalov, M. [Applied mining geology](https://www.google.com.br/books/edition/Applied_Mining_Geology/Oy3RDAAAQBAJ?hl=pt-BR&gbpv=0). Switzerland: Springer International Publishing, 2016*

*Chilès, J. P.; Delfiner, P. [Geostatistics: modeling spatial uncertainty](https://www.google.com.br/books/edition/Geostatistics/CUC55ZYqe84C?hl=pt-BR&gbpv=0). New Jersey: John Wiley & Sons, 2012.*

*Isaaks, E. H.; Srivastava, M. R. [Applied geostatistics](https://www.google.com.br/books/edition/Applied_Geostatistics/gUXQzQEACAAJ?hl=pt-BR). New York: Oxford University Press, 1989.*

*Sinclair, A. J.; Blackwell, G. H. [Applied mineral inventory estimation](https://www.google.com.br/books/edition/Applied_Mineral_Inventory_Estimation/oo7rCrFQJksC?hl=pt-BR&gbpv=0). New York: Cambridge University Press, 2006.*
"""

# ╔═╡ 9cd2e572-23fc-4f7a-9b91-a5d3d13a9b48
md"""
## Recursos adicionais

Abaixo, são listados alguns recursos complementares a este notebook:

> [Videoaula Krigagem - LPM/UFRGS](https://www.youtube.com/watch?v=c8GKKsbAmxU)

> [Videoaula Krigagem - University of Texas](https://www.youtube.com/watch?v=CVkmuwF8cJ8&list=PLG19vXLQHvSB-D4XKYieEku9GQMQyAzjJ)

Além dos dois recursos mencionados acima, sugere-se a leitura do Capítulo 10 do livro de *Sinclair & Blackwell (2006)* que, por sua vez, aborda uma série de discussões práticas sobre a Krigagem no contexto da estimação de recursos minerais.
"""

# ╔═╡ c8ced4cd-a74f-48bc-8cca-fb3971930390
md"""
## Pacotes utilizados

Os seguintes pacotes foram utilizados neste notebook:

|                       Pacote                             |        Descrição        |
|:--------------------------------------------------------:|:-----------------------:|
|[GeoStats](https://github.com/JuliaEarth/GeoStats.jl)     | Rotinas geoestatísticas |
|[CSV](https://github.com/JuliaData/CSV.jl)                | Arquivos CSV            |
|[DataFrames](https://github.com/JuliaData/DataFrames.jl)  | Manipulação de tabelas  |
|[Query](https://github.com/queryverse/Query.jl)           | Realização de consultas |
|[Statistics](https://docs.julialang.org/en/v1/)           | Cálculo de estatísticas |
|[PlutoUI](https://github.com/fonsp/PlutoUI.jl)            | Widgets interativos     |
|[Distributions](https://github.com/JuliaStats/Distributions.jl) | Distribuições de probabilidade |
|[Plots](https://github.com/JuliaPlots/Plots.jl)           | Visualização dos dados  |
|[StatsPlots](https://github.com/JuliaPlots/StatsPlots.jl) | Visualização dos dados  |
|[Random](https://docs.julialang.org/en/v1/)               | Números aleatórios      |
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
GeoStats = "dcc97b0b-8ce5-5539-9008-bb190f959ef6"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Query = "1a8c2f83-1ff3-5112-b086-8aa67b057ba1"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsPlots = "f3b207a7-027a-5e70-b257-86293d7955fd"

[compat]
CSV = "~0.9.9"
DataFrames = "~1.2.2"
Distributions = "~0.25.23"
GeoStats = "~0.27.0"
Plots = "~1.23.1"
PlutoUI = "~0.7.16"
Query = "~1.0.0"
StatsPlots = "~0.14.28"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgCheck]]
git-tree-sha1 = "dedbbb2ddb876f899585c4ec4433265e3017215a"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.1.0"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Arpack]]
deps = ["Arpack_jll", "Libdl", "LinearAlgebra"]
git-tree-sha1 = "2ff92b71ba1747c5fdd541f8fc87736d82f40ec9"
uuid = "7d9fca2a-8960-54d3-9f78-7d1dccf2cb97"
version = "0.4.0"

[[Arpack_jll]]
deps = ["Libdl", "OpenBLAS_jll", "Pkg"]
git-tree-sha1 = "e214a9b9bd1b4e1b4f15b22c0994862b66af7ff7"
uuid = "68821587-b530-5797-8361-c406ea357684"
version = "3.5.0+3"

[[ArrayInterface]]
deps = ["Compat", "IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "a8101545d6b15ff1ebc927e877e28b0ab4bc4f16"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.1.36"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[AverageShiftedHistograms]]
deps = ["LinearAlgebra", "RecipesBase", "Statistics", "StatsBase", "UnicodePlots"]
git-tree-sha1 = "8bdad2055f64dd71a25826d752e0222726f25f20"
uuid = "77b51b56-6f8f-5c3a-9cb4-d71f9594ea6e"
version = "0.8.7"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "d127d5e4d86c7680b20c35d40b503c74b9a39b5e"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.4"

[[BangBang]]
deps = ["Compat", "ConstructionBase", "Future", "InitialValues", "LinearAlgebra", "Requires", "Setfield", "Tables", "ZygoteRules"]
git-tree-sha1 = "0ad226aa72d8671f20d0316e03028f0ba1624307"
uuid = "198e06fe-97b7-11e9-32a5-e1d131e6ad66"
version = "0.3.32"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Baselet]]
git-tree-sha1 = "aebf55e6d7795e02ca500a689d326ac979aaf89e"
uuid = "9718e550-a3fa-408a-8086-8db961cd8217"
version = "0.1.1"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "c0a735698d1a0a388c5c7ae9c7fb3da72fd5424e"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.9.9"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f2202b55d816427cd385a9a4f3ffb226bee80f99"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+0"

[[CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "fbc5c413a005abdeeb50ad0e54d85d000a1ca667"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.1"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "3533f5a691e60601fe60c90d8bc47a27aa2907ec"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.0"

[[CircularArrays]]
deps = ["OffsetArrays"]
git-tree-sha1 = "0598a9ea22c65bfde7f07f21485ebf60deee3302"
uuid = "7a955b69-7140-5f4e-a0ed-f168c5e2e749"
version = "1.3.0"

[[Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "75479b7df4167267d75294d14b58244695beb2ac"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.14.2"

[[CoDa]]
deps = ["AxisArrays", "Distances", "Distributions", "FillArrays", "LinearAlgebra", "Printf", "Random", "ScientificTypes", "StaticArrays", "Statistics", "StatsBase", "TableOperations", "Tables", "UnicodePlots"]
git-tree-sha1 = "110c70f633e0358ab5f71b54684d71a7e8fc3831"
uuid = "5900dafe-f573-5c72-b367-76665857777b"
version = "0.6.6"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "31d0151f5716b655421d9d75b7fa74cc4e744df2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.39.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[CompositionsBase]]
git-tree-sha1 = "455419f7e328a1a2493cabc6428d79e951349769"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.1"

[[ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f74e9d5388b8620b4cee35d4c5a618dd4dc547f4"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.3.0"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[CpuId]]
deps = ["Markdown"]
git-tree-sha1 = "32d125af0fb8ec3f8935896122c5e345709909e5"
uuid = "adafc99b-e345-5852-983c-f28acb93d879"
version = "0.3.0"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "d785f42445b63fc86caa08bb9a9351008be9b765"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.2"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[DataValues]]
deps = ["DataValueInterfaces", "Dates"]
git-tree-sha1 = "d88a19299eba280a6d062e135a43f00323ae70bf"
uuid = "e7dc6d0d-1eca-5fa6-8ad6-5aecde8b7ea5"
version = "0.4.13"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DefineSingletons]]
git-tree-sha1 = "77b4ca280084423b728662fe040e5ff8819347c5"
uuid = "244e2a9f-e319-4986-a169-4d1fe445cd52"
version = "0.1.1"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[DensityRatioEstimation]]
deps = ["LinearAlgebra", "Parameters", "Requires", "Statistics", "StatsBase"]
git-tree-sha1 = "9fd052a2fab80e2e033c9c28dc014a35aaf7da4b"
uuid = "ab46fb84-d57c-11e9-2f65-6f72e4a7229f"
version = "0.4.3"

[[Dictionaries]]
deps = ["Indexing", "Random"]
git-tree-sha1 = "743cd00ae2a87c338c32bf604e83219b8272ad98"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.3.14"

[[DiffResults]]
deps = ["StaticArrays"]
git-tree-sha1 = "c18e98cba888c6c25d1c3b048e4b3380ca956805"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.0.3"

[[DiffRules]]
deps = ["NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "7220bc21c33e990c14f4a9a319b1d242ebc5b269"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.3.1"

[[Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "09d9eaef9ef719d2cd5d928a191dc95be2ec8059"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.5"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns"]
git-tree-sha1 = "d249ebaa67716b39f91cf6052daf073634013c0f"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.23"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[EllipsisNotation]]
deps = ["ArrayInterface"]
git-tree-sha1 = "8041575f021cba5a099a456b4163c9a08b566a02"
uuid = "da5c29d0-fa7d-589e-88eb-ea29b0a81949"
version = "1.1.0"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "463cb335fa22c4ebacfd1faba5fde14edb80d96c"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.5"

[[FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[FilePathsBase]]
deps = ["Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "d962b5a47b6d191dbcd8ae0db841bc70a05a3f5b"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.13"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "8756f9935b7ccc9064c6eef0bff0ad643df733a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.7"

[[FiniteDiff]]
deps = ["ArrayInterface", "LinearAlgebra", "Requires", "SparseArrays", "StaticArrays"]
git-tree-sha1 = "8b3c09b56acaf3c0e581c66638b85c8650ee9dca"
uuid = "6a86dc24-6348-571c-b903-95158fe2bd41"
version = "2.8.1"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "63777916efbcb0ab6173d09a658fb7f2783de485"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.21"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "0c603255764a1fa0b61752d2bec14cfbd18f7fe8"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+1"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "d189c6d2004f63fd3c91748c458b09f26de0efaa"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.61.0"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "cafe0823979a5c9bff86224b3b8de29ea5a44b2e"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.61.0+0"

[[GeoClustering]]
deps = ["CategoricalArrays", "Clustering", "Distances", "GeoStatsBase", "LinearAlgebra", "MLJModelInterface", "Meshes", "SparseArrays", "Statistics", "TableDistances", "TableOperations", "Tables"]
git-tree-sha1 = "ef73e439d7ab2bd317600e5fb3bdbd8ac049c86a"
uuid = "7472b188-6dde-460e-bd07-96c4bc049f7e"
version = "0.2.5"

[[GeoEstimation]]
deps = ["Distances", "GeoStatsBase", "KrigingEstimators", "LinearAlgebra", "Meshes", "NearestNeighbors", "Variography"]
git-tree-sha1 = "c62b273af5154e0e27383abb1aca09ead6994818"
uuid = "a4aa24f8-9f24-4d1a-b848-66d123bfa54d"
version = "0.8.2"

[[GeoLearning]]
deps = ["Distributions", "GeoStatsBase", "MLJModelInterface", "Meshes", "TableOperations", "Tables"]
git-tree-sha1 = "98cf61e86b2c4511bdc875b4bdd8ed770726fb6f"
uuid = "90c4468e-a93e-43b4-8fb5-87d804bc629f"
version = "0.1.5"

[[GeoSimulation]]
deps = ["CpuId", "Distributions", "FFTW", "GeoStatsBase", "KrigingEstimators", "LinearAlgebra", "Meshes", "Statistics", "Variography"]
git-tree-sha1 = "728892f1ddc46df1e59da0f56b521a40ca526659"
uuid = "220efe8a-9139-4e14-a4fa-f683d572f4c5"
version = "0.4.1"

[[GeoStats]]
deps = ["DensityRatioEstimation", "Distances", "GeoClustering", "GeoEstimation", "GeoLearning", "GeoSimulation", "GeoStatsBase", "KrigingEstimators", "LossFunctions", "Meshes", "PointPatterns", "Reexport", "Variography"]
git-tree-sha1 = "0ae88763877d21f1aae4e185bce203245ba59686"
uuid = "dcc97b0b-8ce5-5539-9008-bb190f959ef6"
version = "0.27.0"

[[GeoStatsBase]]
deps = ["AverageShiftedHistograms", "CSV", "CategoricalArrays", "Combinatorics", "DensityRatioEstimation", "Distances", "Distributed", "Distributions", "LinearAlgebra", "LossFunctions", "MLJModelInterface", "Meshes", "Optim", "Parameters", "RecipesBase", "ScientificTypes", "StaticArrays", "Statistics", "StatsBase", "TableOperations", "Tables", "Transducers", "TypedTables"]
git-tree-sha1 = "1f84ae3fe77f06b9569fae9da25ed233e70dfb65"
uuid = "323cb8eb-fbf6-51c0-afd0-f8fba70507b2"
version = "0.21.13"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "7bf67e9a481712b3dbe9cb3dac852dc4b1162e02"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+0"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "14eece7a3308b4d8be910e265c724a6ba51a9798"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.16"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "8a954fed8ac097d5be04921d595f741115c1b2ad"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+0"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "5efcf53d798efede8fee5b2c8b09284be359bf24"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.2"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[IfElse]]
git-tree-sha1 = "28e837ff3e7a6c3cdb252ce49fb412c8eb3caeef"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.0"

[[Indexing]]
git-tree-sha1 = "ce1566720fd6b19ff3411404d4b977acd4814f9f"
uuid = "313cdc1a-70c2-5d6a-ae34-0150d3930a38"
version = "1.1.1"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InitialValues]]
git-tree-sha1 = "7f6a4508b4a6f46db5ccd9799a3fc71ef5cad6e6"
uuid = "22cec73e-a1b8-11e9-2c92-598750a2cf9c"
version = "0.2.11"

[[InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "19cb49649f8c41de7fea32d089d37de917b553da"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.0.1"

[[IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "61aa005707ea2cebf47c8d780da8dc9bc4e0c512"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.4"

[[IntervalSets]]
deps = ["Dates", "EllipsisNotation", "Statistics"]
git-tree-sha1 = "3cc368af3f110a767ac786560045dceddfc16758"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.5.3"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "f0c6489b12d28fb4c2103073ec7452f3423bd308"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.1"

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IterableTables]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Requires", "TableTraits", "TableTraitsUtils"]
git-tree-sha1 = "70300b876b2cebde43ebc0df42bc8c94a144e1b4"
uuid = "1c8ee90f-4401-5389-894e-7a04a3dc0f4d"
version = "1.0.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "591e8dc09ad18386189610acafb970032c519707"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.3"

[[KrigingEstimators]]
deps = ["Combinatorics", "GeoStatsBase", "LinearAlgebra", "Meshes", "Statistics", "Variography"]
git-tree-sha1 = "9a7807a56384477d476835b432a9813eac104626"
uuid = "d293930c-a38c-56c5-8ebb-12008647b47a"
version = "0.8.2"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "c7f1c695e06c01b95a67f0cd1d34994f3e7db104"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.2.1"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a8f4f279b6fa3c3c4f1adadd78a621b13a506bce"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.9"

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[LearnBase]]
git-tree-sha1 = "a0d90569edd490b82fdc4dc078ea54a5a800d30a"
uuid = "7f8f8fb0-2700-5f03-b4bd-41f8cfc144b6"
version = "0.4.1"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LineSearches]]
deps = ["LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "Printf"]
git-tree-sha1 = "f27132e551e959b3667d8c93eae90973225032dd"
uuid = "d3d80556-e9d4-5f37-9878-2ab0fcc64255"
version = "7.1.1"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "6193c3815f13ba1b78a51ce391db8be016ae9214"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.4"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[LossFunctions]]
deps = ["InteractiveUtils", "LearnBase", "Markdown", "RecipesBase", "StatsBase"]
git-tree-sha1 = "0f057f6ea90a84e73a8ef6eebb4dc7b5c330020f"
uuid = "30fc2ffe-d236-52d8-8643-a9d8f7c094a7"
version = "0.7.2"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "5455aef09b40e5020e1520f551fa3135040d4ed0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+2"

[[MLJModelInterface]]
deps = ["Random", "ScientificTypesBase", "StatisticalTraits"]
git-tree-sha1 = "0174e9d180b0cae1f8fe7976350ad52f0e70e0d8"
uuid = "e80e1ace-859a-464e-9ed9-23947d8ae3ea"
version = "1.3.3"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "5a5bc6bf062f0f95e62d0fe0a2d99699fed82dd9"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.8"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Meshes]]
deps = ["CategoricalArrays", "CircularArrays", "Distances", "IterTools", "IteratorInterfaceExtensions", "LinearAlgebra", "NearestNeighbors", "Random", "RecipesBase", "ReferenceFrameRotations", "SimpleTraits", "SparseArrays", "SpecialFunctions", "StaticArrays", "StatsBase", "TableTraits", "Tables"]
git-tree-sha1 = "75673970b35c198d1ebe81f0ff17d126820a9c97"
uuid = "eacbb407-ea5a-433e-ab97-5258b1ca43fa"
version = "0.17.20"

[[MicroCollections]]
deps = ["BangBang", "Setfield"]
git-tree-sha1 = "4f65bdbbe93475f6ff9ea6969b21532f88d359be"
uuid = "128add7d-3638-4c79-886c-908ea0c25c34"
version = "0.1.1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[MultivariateStats]]
deps = ["Arpack", "LinearAlgebra", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "8d958ff1854b166003238fe191ec34b9d592860a"
uuid = "6f286f6a-111f-5878-ab1e-185364afe411"
version = "0.8.0"

[[NLSolversBase]]
deps = ["DiffResults", "Distributed", "FiniteDiff", "ForwardDiff"]
git-tree-sha1 = "144bab5b1443545bc4e791536c9f1eacb4eed06a"
uuid = "d41bc354-129a-5804-8e4c-c37616107c6c"
version = "7.8.1"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "16baacfdc8758bc374882566c9187e785e85c2f0"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.9"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "c0e9e582987d36d5a61e650e6e543b9e44d9914b"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.7"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

[[OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Optim]]
deps = ["Compat", "FillArrays", "LineSearches", "LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "PositiveFactorizations", "Printf", "SparseArrays", "StatsBase"]
git-tree-sha1 = "7863df65dbb2a0fa8f85fcaf0a41167640d2ebed"
uuid = "429524aa-4258-5aef-a3af-852621145aeb"
version = "1.4.1"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "4dd403333bcf0909341cfe57ec115152f937d7d8"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.1"

[[Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "f19e978f81eca5fd7620650d7dbea58f825802ee"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.0"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "b084324b4af5a438cd63619fd006614b3b20b87b"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.15"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs"]
git-tree-sha1 = "25007065fa36f272661a0e1968761858cc880755"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.23.1"

[[PlutoUI]]
deps = ["Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "4c8a7d080daca18545c56f1cac28710c362478f3"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.16"

[[PointPatterns]]
deps = ["Distributions", "GeoStatsBase", "Meshes"]
git-tree-sha1 = "3debcdc078d2cda0eaaa64750b8a1665f93f1ade"
uuid = "e61b41b6-3414-4803-863f-2b69057479eb"
version = "0.3.9"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a193d6ad9c45ada72c14b731a318bedd3c2f00cf"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.3.0"

[[PositiveFactorizations]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "17275485f373e6673f7e7f97051f703ed5b15b20"
uuid = "85a6dd25-e78a-55b7-8502-1745935b8125"
version = "0.2.4"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "d940010be611ee9d67064fe559edbb305f8cc0eb"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.2.3"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[Query]]
deps = ["DataValues", "IterableTables", "MacroTools", "QueryOperators", "Statistics"]
git-tree-sha1 = "a66aa7ca6f5c29f0e303ccef5c8bd55067df9bbe"
uuid = "1a8c2f83-1ff3-5112-b086-8aa67b057ba1"
version = "1.0.0"

[[QueryOperators]]
deps = ["DataStructures", "DataValues", "IteratorInterfaceExtensions", "TableShowUtils"]
git-tree-sha1 = "911c64c204e7ecabfd1872eb93c49b4e7c701f02"
uuid = "2aef5ad7-51ca-5a8f-8e88-e75cf067b44b"
version = "0.9.3"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[Ratios]]
deps = ["Requires"]
git-tree-sha1 = "01d341f502250e81f6fec0afe662aa861392a3aa"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.2"

[[RecipesBase]]
git-tree-sha1 = "44a75aa7a527910ee3d1751d1f0e4148698add9e"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.2"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[ReferenceFrameRotations]]
deps = ["Crayons", "LinearAlgebra", "Printf", "StaticArrays"]
git-tree-sha1 = "b2fc23750e12df6c8bc72cbb328020ed9a572e90"
uuid = "74f56ac7-18b3-5285-802d-d4bd4f104033"
version = "2.0.0"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[ScientificTypes]]
deps = ["CategoricalArrays", "ColorTypes", "Dates", "Distributions", "PrettyTables", "Reexport", "ScientificTypesBase", "StatisticalTraits", "Tables"]
git-tree-sha1 = "b58ef9adeba0d96ae1add87e8df5a7128342e312"
uuid = "321657f4-b219-11e9-178b-2701a2544e81"
version = "2.3.2"

[[ScientificTypesBase]]
git-tree-sha1 = "185e373beaf6b381c1e7151ce2c2a722351d6637"
uuid = "30f210dd-8aff-4c5f-94ba-8e64358c1161"
version = "2.3.0"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "f45b34656397a1f6e729901dc9ef679610bd12b5"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.8"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "Requires"]
git-tree-sha1 = "def0718ddbabeb5476e51e5a43609bee889f285d"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "0.8.0"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "f0bccf98e16759818ffc5d97ac3ebf87eb950150"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.8.1"

[[SplitApplyCombine]]
deps = ["Dictionaries", "Indexing"]
git-tree-sha1 = "3cdd86a92737fa0c8af19aecb1141e71057dc2db"
uuid = "03a91e81-4c3e-53e1-a0a4-9c0c8f19dd66"
version = "1.1.4"

[[SplittablesBase]]
deps = ["Setfield", "Test"]
git-tree-sha1 = "39c9f91521de844bad65049efd4f9223e7ed43f9"
uuid = "171d559e-b47b-412a-8079-5efa626c420e"
version = "0.1.14"

[[Static]]
deps = ["IfElse"]
git-tree-sha1 = "e7bc80dc93f50857a5d1e3c8121495852f407e6a"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.4.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[StatisticalTraits]]
deps = ["ScientificTypesBase"]
git-tree-sha1 = "730732cae4d3135e2f2182bd47f8d8b795ea4439"
uuid = "64bff920-2084-43da-a3e6-9bb72801c0c9"
version = "2.1.0"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "eb35dcc66558b2dda84079b9a1be17557d32091a"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.12"

[[StatsFuns]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "95072ef1a22b057b1e80f73c2a89ad238ae4cfff"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.12"

[[StatsPlots]]
deps = ["Clustering", "DataStructures", "DataValues", "Distributions", "Interpolations", "KernelDensity", "LinearAlgebra", "MultivariateStats", "Observables", "Plots", "RecipesBase", "RecipesPipeline", "Reexport", "StatsBase", "TableOperations", "Tables", "Widgets"]
git-tree-sha1 = "eb007bb78d8a46ab98cd14188e3cec139a4476cf"
uuid = "f3b207a7-027a-5e70-b257-86293d7955fd"
version = "0.14.28"

[[StringDistances]]
deps = ["Distances", "StatsAPI"]
git-tree-sha1 = "00e86048552d34bb486cad935754dd9516bdb46e"
uuid = "88034a9c-02f8-509d-84a9-84ec65e18404"
version = "0.11.1"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableDistances]]
deps = ["CategoricalArrays", "CoDa", "Distances", "ScientificTypes", "Statistics", "StringDistances", "TableOperations", "Tables"]
git-tree-sha1 = "4f72aef044ab8dcebb29a0349b415734231a1747"
uuid = "e5d66e97-8c70-46bb-8b66-04a2d73ad782"
version = "0.1.0"

[[TableOperations]]
deps = ["SentinelArrays", "Tables", "Test"]
git-tree-sha1 = "e383c87cf2a1dc41fa30c093b2a19877c83e1bc1"
uuid = "ab02a1b2-a7df-11e8-156e-fb1833f50b87"
version = "1.2.0"

[[TableShowUtils]]
deps = ["DataValues", "Dates", "JSON", "Markdown", "Test"]
git-tree-sha1 = "14c54e1e96431fb87f0d2f5983f090f1b9d06457"
uuid = "5e66a065-1f0a-5976-b372-e0b8c017ca10"
version = "0.2.5"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[TableTraitsUtils]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Missings", "TableTraits"]
git-tree-sha1 = "78fecfe140d7abb480b53a44f3f85b6aa373c293"
uuid = "382cd787-c1b6-5bf2-a167-d5b971a19bda"
version = "1.0.2"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "fed34d0e71b91734bf0a7e10eb1bb05296ddbcd0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[Transducers]]
deps = ["Adapt", "ArgCheck", "BangBang", "Baselet", "CompositionsBase", "DefineSingletons", "Distributed", "InitialValues", "Logging", "Markdown", "MicroCollections", "Requires", "Setfield", "SplittablesBase", "Tables"]
git-tree-sha1 = "bccb153150744d476a6a8d4facf5299325d5a442"
uuid = "28d57a85-8fef-5791-bfe6-a80928e7c999"
version = "0.4.67"

[[TypedTables]]
deps = ["Adapt", "Dictionaries", "Indexing", "SplitApplyCombine", "Tables", "Unicode"]
git-tree-sha1 = "f91a10d0132310a31bc4f8d0d29ce052536bd7d7"
uuid = "9d95f2ec-7b3d-5a63-8d20-e2491e220bb9"
version = "1.4.0"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnicodePlots]]
deps = ["Crayons", "Dates", "SparseArrays", "StatsBase"]
git-tree-sha1 = "f1d09f14722f5f3cef029bcb031be91a92613ae9"
uuid = "b8865327-cd53-5732-bb35-84acbb429228"
version = "2.4.6"

[[Variography]]
deps = ["Distances", "GeoStatsBase", "InteractiveUtils", "LinearAlgebra", "Meshes", "NearestNeighbors", "Optim", "Parameters", "Printf", "Random", "RecipesBase", "Setfield", "SpecialFunctions", "Transducers"]
git-tree-sha1 = "97817eb256ae53195bbe85e3e2fbc9b61b709186"
uuid = "04a0146e-e6df-5636-8d7f-62fa9eb0b20c"
version = "0.12.22"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll"]
git-tree-sha1 = "2839f1c1296940218e35df0bbb220f2a79686670"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.18.0+4"

[[WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "c69f9da3ff2f4f02e811c3323c22e5dfcb584cfa"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.1"

[[Widgets]]
deps = ["Colors", "Dates", "Observables", "OrderedCollections"]
git-tree-sha1 = "80661f59d28714632132c73779f8becc19a113f2"
uuid = "cc8bc4a8-27d6-5769-a93b-9d913e69aa62"
version = "0.6.4"

[[WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[ZygoteRules]]
deps = ["MacroTools"]
git-tree-sha1 = "8c1a8e4dfacb1fd631745552c8db35d0deb09ea0"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.2"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "c45f4e40e7aafe9d086379e5578947ec8b95a8fb"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+0"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─f9fb89e0-36a8-11ec-3fa3-d716ca093060
# ╟─3e70ffa1-2a50-4dc4-a529-e4361ac6ad5f
# ╟─9f8d2a06-275e-4689-8a69-b1f4dec807b3
# ╟─0d2c1d74-f691-4805-9aa2-e9d42da04284
# ╟─84ad4d5f-b3c3-4c21-89f2-d15396e83d05
# ╟─035ef186-a067-44c0-b9a0-bdac6f4d770b
# ╟─564423c2-6a3e-4919-a6fc-32f7d1664f86
# ╟─a069cc27-d08e-47b4-9f75-24dab178b333
# ╟─9b31cfec-400a-4068-84b8-8170b3c8ab58
# ╟─951ca515-39a9-4e95-a53c-6fd7977a4cbb
# ╟─28acc648-ac4a-4d1c-86ce-5bb329c6a141
# ╟─25ddae7c-a276-417e-92c8-9fc2076db219
# ╟─69c94901-8d49-4fcc-97f4-bf857b04e627
# ╟─78866735-d01e-4c9d-abec-3ed54b8ed612
# ╟─d5d0ef84-7c79-4d5e-af5c-52090b1dd233
# ╟─fa6d5e16-ad13-4e68-8ee8-d846db277917
# ╟─956f6c67-93f1-41bf-b921-e893111bbebe
# ╟─eab5920c-fd1f-4e03-a6f3-90e3ce731b6e
# ╟─5a9f4bbf-202f-4191-b59d-f2bed05347ae
# ╠═669d757d-dc19-43e1-b96f-8c1aa31f7579
# ╟─207ca8d7-08df-47dd-943b-7f7846684e3b
# ╠═b14c6b92-81cc-482f-9746-d9a011cff5cd
# ╟─9055d652-1c6c-4d73-9302-d58a35ffb975
# ╟─37462572-3c3d-46e1-8e2d-266e86470b6a
# ╟─4469f1a2-6054-4ba0-b402-03892d3a90e4
# ╟─2531eee8-72c5-4056-879c-b1b65273d51a
# ╠═36033c09-267c-48df-b6cd-ce2ee2a5eac6
# ╟─3a034b2e-97a2-4a4f-bc60-c6634082254a
# ╟─22b5fc9a-9d08-4e36-a500-329e5036081f
# ╟─8aaca25b-8ebc-418c-ad48-344a31ba8ed9
# ╟─07175b65-bf21-49c4-9bfa-be5cf000f2ba
# ╟─045cdf16-d264-4b5d-990b-c1bd2acb5613
# ╟─79c812cf-849a-4eea-93d2-b08a3844d5a7
# ╠═b2cb5618-72ba-43a3-9b04-cb2a8821bfa9
# ╟─14ba26ab-db0d-4993-9b98-56309ff23389
# ╠═d5977fdd-c9bc-4589-ae0e-f6cac6973fbb
# ╠═e570281a-39e3-438f-9c4a-395f321f12d4
# ╠═4af2bbf9-fc03-49d0-a19f-f34356c897f7
# ╟─73b54c21-7b69-429b-a088-fba3d0c09459
# ╟─5f90093b-4b1e-4e0d-b84c-4232bd3c1b1a
# ╟─a49e5f8d-09cf-4baf-b7b4-d43858df8089
# ╟─60db4fd5-f06c-4821-a7ed-2f63033653ff
# ╟─2e9b95c5-a687-4881-b69e-6567ade520cb
# ╟─981efb6c-b1ea-4577-9c40-f3f374a23ba1
# ╟─4ce1c65d-701c-4615-90aa-9f6469e47211
# ╟─a2e173e6-fe66-44e6-b371-3ae194d7b0f9
# ╟─e49569b3-0231-4b8e-98d9-21c68c4b1160
# ╟─260d5fa1-b2d9-4e9d-9154-c07f2959bce5
# ╟─6b4e35a1-4f1a-4745-9370-f982762af210
# ╟─b657f40a-b586-4011-ad48-aa18b0a46dc3
# ╟─b8589ac8-7305-48c1-8dff-880a7c659059
# ╟─466c7891-f632-4c02-990a-b5a99c1c162a
# ╟─03d1da66-8202-4415-a44d-8c204e740960
# ╟─5b07d44b-af44-425b-9e3e-9a5f643e840d
# ╟─817bf734-d8a0-43cd-9553-a7980152afe5
# ╟─b1b823ac-f9cf-4e5b-a622-4274f3785567
# ╟─9cd2e572-23fc-4f7a-9b91-a5d3d13a9b48
# ╟─c8ced4cd-a74f-48bc-8cca-fb3971930390
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
