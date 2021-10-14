### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 9aed0800-1e13-11ec-2780-69699771cc17
begin
	# carregando pacotes necessários
	using CSV, DataFrames, Query
	using StatsBase, Statistics, Random
	using GeoStats, PlutoUI
	using Plots, StatsPlots
	
	# configurações de plotagem
	gr(format=:png)
end;

# ╔═╡ 67ed7bd0-32cc-49bf-8c30-6c34ad29c88a
html"""
<p style="background-color:lightgrey" xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><span property="dct:title">&nbsp&nbsp<b>Análise Exploratória</b></span> por <span property="cc:attributionName">Franco Naghetini</span> é licenciado sob <a href="http://creativecommons.org/licenses/by/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1"></a></p>
"""

# ╔═╡ 5e44a696-0a3e-40f1-b125-2dec95b5cf79
PlutoUI.TableOfContents(aside=true, title="Sumário",
						indent=true, depth=2)

# ╔═╡ cfc649b3-e423-4aa9-925b-763e2986e2f5
md"""

![ufmg-logo](https://logodownload.org/wp-content/uploads/2015/02/ufmg-logo-2.png)

"""

# ╔═╡ b53bfda4-60de-43c8-9852-faa1051050e2
md""" # 📊 Análise Exploratória

A **Análise Exploratória dos Dados (AED)** consiste em uma abordagem para organizar e sumarizar um determinado conjunto de dados, a partir de estatísticas descritivas e técnicas de visualização de dados. Segundo *Tukey (1977)*, pesquisador que propôs o termo, a AED pode ser comparada ao trabalho de investigação realizado por um detetive.

De forma mais descontraída, pode-se dizer que:

> *A AED é a arte de torturar os dados até que eles confessem informações escondidas!*

A AED é uma etapa crucial do fluxo de trabalho de estimativa de recursos, pois é quando se *transforma dados em informações*. Portanto, neste módulo, iremos aprender sobre algumas das técnicas de AED mais utilizadas no contexto de estimativa de recursos.

"""

# ╔═╡ f7756000-3e37-436e-b070-6d57afe142d7
md"""
#### ⚠️ Informações sobre o notebook

- Este notebook é constituído por várias células individuais:
    - Para executá-las, pasta clicar no ícone ▶️, localizado no canto inferior direito da célula.
    - Algumas células encontram-se ocultadas. Você pode clicar no ícone 👁️, localizado no canto superior esquerdo da célula, para ocultá-la ou exibí-la.
    - Você pode ainda clicar no ícone `...`, no canto superior direito, para excluir uma célula do notebook.

- Algumas células deste notebook encontram-se encapsuladas pela expressão `md"..."`. Elas são chamadas de **markdown** e representam as células de texto do notebook. Caso deseje aprender um pouco mais sobre a linguagem markdown, clique [aqui](https://docs.pipz.com/central-de-ajuda/learning-center/guia-basico-de-markdown#open).

- Você pode utilizar este notebook da forma que quiser! 🙂 Caso deseje utilizá-lo em algum trabalho, apenas referencie [este link](https://github.com/fnaghetini/intro-to-geostats).
"""

# ╔═╡ e28a9056-d62d-4ab6-be00-0174180a73c5
md"""
## 1. Conceitos Básicos

Nesta primeira seção, iremos aprender/revisar alguns conceitos básicos sobre Estatística Clássica.
"""

# ╔═╡ a8c53b89-634b-4526-be62-f51f22c3c607
md"""
### População x Amostra

A **população** é o conjunto exaustivo e finito de todos os elementos ou resultados sob investigação. Em outras palavras, é a realidade física (*Bussab & Morettin, 2017*).

Por outro lado, a **amostra** é qualquer subconjunto da população formado por elementos que foram medidos (*Bussab & Morettin, 2017*).

No contexto de estimativa de recursos, a **amostra** seria formada pelo conjunto de furos de sondagem disponíveis, enquanto a **população** seria o depósito/jazida/mina sob investigação.

Assim como em várias áreas, não temos informações sobre toda a população (i.e. depósito), mas apenas sobre um subconjunto dela (i.e. furos de sondagem) (Figura 01). Segundo *Rossi & Deutsch (2013)*, em média, apenas $\frac{1}{10^9}$ de um depósito é amostrado. Isso se deve ao fato de a sondagem ser uma atividade de elevado custo ao empreendimento.

"""

# ╔═╡ b8576b51-2a2b-4614-ae62-280394944319
md"""
![Figura_01](https://i.postimg.cc/dVwQj93Q/Figura-01.png)

**Figura 01:** A população é representada pelo depósito, enquanto a amostra é representada pelos furos de sondagem disponíveis. Figura elaborada pelo autor.
"""

# ╔═╡ b517b327-27e9-4e7c-a721-3ff8c991ff08
md"""
### Parâmetros x Estimadores

Os **parâmetros** são as quantidades da população sobre as quais temos interesse. Normalmente são representadas por letras gregas, como $\mu$ (média populacional), $\sigma^2$ (variância populacional) e $\sigma$ (desvio padrão populacional) (*Magalhães & De Lima, 2015*).

Por outro lado, os **estimadores**, às vezes chamados de **estatísticas**, correspondem à combinação dos elementos da amostra construída com a finalidade de representar ou estimar um parâmetro de interesse na população. São representados por letras do alfabeto latino, como X̅ (média amostral), $S^2$ (variância amostral) e $S$ (desvio padrão amostral) (*Magalhães & De Lima, 2015*).

Como só temos acesso à amostra (e.g. furos de sondagem), iremos trabalhar com estimadores (i.e. estatísticas).

"""

# ╔═╡ c08e9281-bbc8-4328-b005-b867c77f725c
md"""
### Tipos de variáveis

As **variáveis qualitativas** apresentam como possíveis realizações uma qualidade ou atributo de um indivíduo pesquisado. Essas variáveis podem ainda ser divididas em **nominais**, quando não existe uma ordenação nas possíveis realizações, e **ordinais**, quando existe uma ordem nos seus resultados (*Bussab & Morettin, 2017*). Litologia e grau de alteração são exemplos de variáveis qualitativas nominais e ordinais, respectivamente.

As **variáveis quantitativas** também estão sujeitas a uma classificação dicotômica. As variáveis **discretas** são aquelas cujos possíveis valores formam um conjunto finito ou enumerável de números (1, 2, ...). Já as variáveis **contínuas** apresentam possíveis valores pertencentes a um intervalo de números reais resultantes de uma mensuração (*Bussab & Morettin, 2017*). Zona mineralizada e teor são exemplos de variáveis quantitativas discretas e contínuas, respectivamente.

A Figura 02 mostra um esquema com os tipos de variáveis existentes.
"""

# ╔═╡ 01280f05-2fc2-4860-add3-8b40d9bd546e
md"""
![Figura_02](https://i.postimg.cc/MGvTF2fZ/Figura-02.jpg)

**Figura 02:** Tipos de variáveis. Modificado de *Bussab & Morettin (2017)*.
"""

# ╔═╡ 966a59b1-f8b8-4612-ab4d-ff7ec2a569d9
md"""

## 2. Importação dos dados

Neste módulo, iremos trabalhar com o banco de dados [Jura](https://rdrr.io/cran/gstat/man/jura.html) do excelente livro de *Goovaerts (1997)*. Esse banco de dados é constituído por amostras de solo que possuem os seguintes atributos:

- `Xloc` e `Yloc`: coordenadas locais X e Y.
- `Landuse` e `Rock`: tipo de uso do solo e tipo de rocha, respectivamente.
- `cadmium`, `cobalt`, `Cr`, `Cu`, `nickel`, `lead` e `Zn`: concentração de elementos no solo em ppm.

> **Nota:** algumas modificações no banco de dados foram realizadas pelo autor para exemplificar algumas rotinas típicas da AED.

Os dados estão no formato CSV no arquivo `data/jura.csv`. Para carregá-los no notebook, utilizaremos os pacotes [CSV.jl](https://github.com/JuliaData/CSV.jl) e [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl).

Especificamos o caminho do arquivo e redirecionamos o resultado para uma tabela `DataFrame` utilizando o operador `|>`, conhecido como *pipe*.

"""

# ╔═╡ 6ded7ce7-4239-4a17-a048-c02982dae5f9
jura = CSV.File("data/jura.csv") |> DataFrame

# ╔═╡ e34b3cdf-736d-40b8-8289-bfe968925b17
md"""

Podemos usar a função `describe()` para obter algumas informações gerais...

"""

# ╔═╡ 2d16b0e1-ce43-46a5-a4ce-eced1d88d4e6
describe(jura)

# ╔═╡ 778ce45e-1486-433b-8c0a-1b5beddaf352
md"""
##### Observações

- Cada atributo (coluna) tem um tipo de elemento `eltype`;

- Todos os elementos (exceto `Ni` e `Pb`) têm valores faltantes. Elementos faltantes, neste caso, têm o tipo `Union{Missing,Float64}` que representa a união do tipo `Float64` com o tipo `Missing`;

- Os valores dos elementos amostrados encontram-se em escalas distintas;

- As coordenadas `Xloc` e `Yloc` são variáveis quantitativas contínuas;

- Os elementos químicos amostrados são variáveis quantitativas contínuas;

- As colunas `Landuse` e `Rock` podem ser classificadas como variáveis qualitativas nominais.

"""

# ╔═╡ 71004e57-95c2-403d-992e-4cf0875a6d2e
md"""

## 3. Limpeza dos dados

O próximo passo é a limpeza dos dados, uma das etapas que mais demandam tempo do fluxo de trabalho. Usaremos o pacote [Query.jl](https://github.com/queryverse/Query.jl) para manipular os dados de forma sucinta e performática. O pacote introduz um conjunto de operações que podem ser facilmente concatenadas para produzir novas tabelas, como:

```julia
dados |> @rename(...) |> @filter(...)
```

Nesse sentido, iremos eliminar as linhas da tabela que contenham valores faltantes a partir da operação `@dropna`. Em seguida, algumas colunas serão renomeadas para fins de padronização. Nesse caso, a operação `@rename` é utilizada:

"""

# ╔═╡ 1014b88e-9aad-4e89-ba9d-f7701fc1a812
dados = jura |> @dropna() |> @rename(:Xloc => :X, :Yloc => :Y,
								     :cadmium => :Cd, :cobalt => :Co,
									 :nickel => :Ni, :lead => :Pb) |> DataFrame

# ╔═╡ f25cb0bc-e063-4ff1-9521-50c9e72fcbbe
md"""
##### Observações

- Após a limpeza, não há mais dados com valores faltantes;

- Os nomes das variáveis que representam os elementos químicos amostrados foram atualizados para as siglas correspondentes.
"""

# ╔═╡ f5bf9985-62be-48d1-8399-ecde710e1dd5
md"""

## 4. Descrição univariada

Diferentemente de outras áreas do conhecimento, como Medicina e Física, em problemas geoespaciais, devemos nos atentar dois **tipos de espaço** distintos:

1. Espaço de atributos
2. Espaço geográfico

O **espaço geográfico** é constituído pelas coordenadas espaciais da região de estudo. No nosso caso, esse espaço é representado pelas variáveis `X` e `Y`.

Por outro lado, o **espaço de atributos** é formado pelos valores das variáveis de interesse do estudo. No nosso exemplo, esse espaço é constituído pelos elementos químicos amostrados e pelas variáveis `Landuse` e `Rock`.

Nesta seção, as principais técnicas de sumarização e visualização univariadas (i.e. uma variável por vez) e, portanto, estaremos interessados no espaço de atributos.
"""

# ╔═╡ b7820679-6ec3-4580-a502-4e4315ed44f9
md"""
### Medidas-resumo

Segundo *Isaaks & Srivastava (1989)*, as **medidas-resumo** podem ser classificadas em:

> **Medidas de posição:** trazem informações sobre várias porções de uma distribuição (e.g. centro, caudas).

> **Medidas de dispersão:** descrevem a variabilidade/erraticidade dos valores assumidos pelas variáveis.

> **Medidas de forma:** descrevem a forma de uma distribuição.

Essas medidas, em conjunto, fornecem informações valiosas acerca das variáveis de interesse do estudo.
"""

# ╔═╡ e1ff515f-c0d2-4e4b-b768-8d5611347e2d
md"""
#### Medidas de Posição

Três medidas de posição serão apresentadas:
- Média aritmética
- Mediana
- Quantis

A **média aritmética**, ou simplesmente média, consiste na soma das observações dividida pelo número delas (*Bussab & Morettin, 2017*) e, portanto, traz informação sobre o centro de uma distribuição:

```math
\overline{X} = \frac{1}{n} \sum_{i=1}^{n} x_i
```

Podemos utilizar a função `mean` para computar a média da variável `Cr`...

"""

# ╔═╡ 17cdccaf-a34e-4b49-8156-01f6221ae00b
mean(dados.Cr)

# ╔═╡ 476e5bc7-5d9c-43fe-ac84-ead5bbbfe4b9
md"""
A **mediana** consiste no ponto médio dos valores observados, desde que as observações estejam organizadas em ordem crescente (*Isaaks & Srivastava, 1989*). Portanto, assim como a média, a mediana também traz informação sobre o centro da distribuição:

```math
\begin{equation}
  md(X) =
    \begin{cases}
      x_{\frac{n+1}{2}} & \text{se $n$ é ímpar}\\
      \frac{x_{\frac{n}{2}} + x_{\frac{n}{2}+1}}{2} & \text{se $n$ é par}\\
    \end{cases}       
\end{equation}
```

Podemos utilizar a função `median` para computar a mediana da variável `Cr`...
"""

# ╔═╡ 98b6bce7-8cc4-4d7f-b947-21feb4b43bf0
median(dados.Cr)

# ╔═╡ 581459c4-312a-4022-a87c-35887f625d6d
md"""
Os **quantis**, assim como a mediana, também se baseiam na ideia de separar os dados (em ordem crescente) em subconjuntos com o mesmo número de observações (*Isaaks & Srivastava, 1989*). Enquanto a mediana separa os dados em duas metades, os percentis subdividem os dados em 100 subconjuntos com o mesmo número de amostras. Nesse sentido, os percentis trazem informações sobre todas as partes de uma distribuição (i.e. centro e caudas).

Podemos utilizar a função `quantile` para computar os quantis `q(0.10)`, `q(0.50)` e `q(0.90)` da variável `Cr`...
"""

# ╔═╡ 79ff3f1a-9bf6-421e-8ab9-7a592fa21bbd
quantile(dados.Cr, [0.1,0.5,0.9])

# ╔═╡ 9b546155-55ad-4927-8f94-b021bf58934e
md"""
> **Nota:** tanto a média quanto a mediana, por conterem informações sobre o centro de uma distribuição, são também classificadas como **medidas de tendência central**. A principal diferença entre essas duas estatísticas é que a média é muito sensível à presença de valores extremos, enquanto a mediana não. Nesse sentido, diz-se que a **média** é uma estatística **pouco robusta** e a **mediana** é uma medida **robusta**.
"""

# ╔═╡ 45735824-f693-47e8-b771-2553fb968605
md"""
#### Medidas de dispersão

Quatro medidas de dispersão serão apresentadas:
- Variância
- Desvio padrão
- Distância interquartil
- Coeficiente de variação

A **variância** consiste na diferença quadrática média entre os valores observados para uma variável e sua média (*Isaaks & Srivastava, 1989*). Como há termos ao quadrado, pode-se dizer que a variância é uma estatística pouco robusta (i.e. muito sensível a valores extremos) e que não se encontra na unidade da variável de interesse.

```math
S^2 = \frac{1}{n-1} \sum_{i=1}^{n} (x_i - \overline{X})^2
```

> **Nota:** a equação acima representa a **variância amostral**.

Podemos utilizar a função `var` para computar a variância da variável `Cr`...

"""

# ╔═╡ 16ba02e8-e555-4dd7-a197-fc4b1b6a7fe3
var(dados.Cr)

# ╔═╡ e23f2abb-37a2-483f-80f1-c24312de1adb
md"""
O **desvio padrão** é simplesmente a raíz quadrada da variância. Normalmente, essa estatística é utilizada para substituir a variância, uma vez que se encontra na mesma unidade de medida da variável de interesse (*Isaaks & Srivastava, 1989*). O desvio padrão também é uma estatística pouco robusta.

```math
S = \sqrt{\frac{1}{n-1} \sum_{i=1}^{n} (x_i - \overline{X})^2} = \sqrt{S^2}
```
> **Nota:** a equação acima representa ao **desvio padrão amostral**.

Podemos utilizar a função `std` para computar a variância da variável `Cr`...

"""

# ╔═╡ 746d33e3-448c-45e4-974c-093e3e001553
std(dados.Cr)

# ╔═╡ b3fb81b8-8f00-4fe5-877c-3c6a1f7ded77
md"""
A **distância interquartil**, comumente chamada de IQR (*interquartile range*), é uma medida de dispersão assim como a variância e o desvio padrão, mas, por ser baseada em quantis, é uma estatística robusta. O IQR consiste na diferença entre o quantil superior $Q_3$ e o quantil inferior $Q_1$ (*Isaaks & Srivastava, 1989*):

```math
IQR = Q_3 - Q_1 = q(0.75) - q(0.25)
```

Podemos calcular o IQR da variável `Cr` utilizando a função `quantile`...

"""

# ╔═╡ 82a219b0-d1ca-4db0-8738-6b3f8e27189b
quantile(dados.Cr, 0.75) - quantile(dados.Cr, 0.25)

# ╔═╡ 3e2ea93f-0219-4766-b550-4d3788608ca4
md"""
O **coeficiente de variação** é uma medida de dispersão que, diferentemente das outras medidas apresentadas anteriormente, é uma estatística **portável**. Isso significa que podemos utilizar o coeficiente de variação para saber qual das variáveis presentes no banco de dados é a mais errática (i.e. apresenta a maior variabilidade).

O coeficiente de variação consiste na razão entre o desvio padrão e a média da variável de interesse:

```math
C_v = \frac{\overline{X}}{S}
```

> **Nota:** O coeficiente de variação é de suma importância, uma vez que fornece avisos sobre eventuais dificuldades na estimativa. Caso essa estatística seja superior a 1, possivelmente as estimativas finais terão uma grande incerteza associada em função da alta variabilidade natural da variável (*Isaaks & Srivastava, 1989*).

Podemos utilizar a função `variation` para computar o coeficiente de variação da variável `Cr`...

"""

# ╔═╡ 1c851dd2-7e85-4c94-a806-2afea3199291
variation(dados.Cr)

# ╔═╡ 2ed2fe35-8b11-41cc-8106-cddad3891b89
md""" #### Medidas de forma

Apenas uma medida de forma será apresentada, o coeficiente de assimetria.

O **coeficiente de assimetria**, também chamado de *skewness*, traz informações sobre a simetria de uma distribuição. Como apresenta termos elevados ao cubo, essa estatística é extremamente sensível à presença de valores extremos (*Isaaks & Srivastava, 1989*). Essa medida pode ser representada como:

```math
skew(X) = \frac{\frac{1}{n-1} \sum_{i=1}^{n} (x_i - \overline{X})^3}{S^3}
```

Com base no coeficiente de assimetria, as distribuições podem ser classificadas como:

> **Assimétrica positiva**: $skew(X) > 0$

> **Simétrica**: $skew(X) = 0$

> **Assimétrica negativa**: $skew(X) < 0$

Podemos utilizar a função `skewness` para o cálculo do coeficiente de assimetria da variável `Cr`...

"""

# ╔═╡ 57414e29-2eee-49a6-8678-94d2fdabb70a
skewness(dados.Cr)

# ╔═╡ 7f94f1b4-9ac8-4137-9787-a722670508bb
md"""
#### Sumário estatístico

Agora que já aprendemos sobre as principais estatísticas univariadas, podemos criar uma função `sumario` que retornará o sumário estatístico de uma determinada variável `teor`...
"""

# ╔═╡ cecf023e-5002-48ca-8ea5-0cb294f2e419
function sumario(teor::String)
	Q₃ = quantile(dados[!,teor], 0.75)
	Q₁ = quantile(dados[!,teor], 0.25)
	
	df = DataFrame(teor = teor,
                   X̄    = mean(dados[!,teor]),
				   md   = median(dados[!,teor]),
				   min  = minimum(dados[!,teor]),
			       max  = maximum(dados[!,teor]),
                   S²   = var(dados[!,teor]),
				   S    = std(dados[!,teor]),
                   IQR  = Q₃ - Q₁,
                   Cᵥ   = variation(dados[!,teor]),
                   skew = skewness(dados[!,teor]))
				
	return df
end

# ╔═╡ 4fcf13f4-7f79-4c6d-b365-052c1fb9bb5d
md"""
Agora podemos aplicar a função `sumario` para calcular as estatísticas de cada uma das variáveis contínuas de interesse (i.e. elementos químicos amostrados)...
"""

# ╔═╡ 2dfad787-72a2-4414-849d-fbab7aa4c40f
[sumario("Cd")
 sumario("Co")
 sumario("Cr")
 sumario("Cu")
 sumario("Ni")
 sumario("Pb")
 sumario("Zn")]

# ╔═╡ 64b87701-bf9e-46c9-8700-89d2ef546621
md"""
##### Observações

- Os elementos químicos amostrados encontram-se em escalas distintas;
- Todas as variáveis apresentam distribuições assimétricas positivas ($skew > 0$), com exceção do `Co` que, por sua vez, mostra uma distribuição levemente assimétrica negativa ($skew < 0$);
- Os elementos químicos amostrados apresentam distribuições pouco erráticas, com $C_v < 1$;
- O `Cu` é a variável mais errática, ou seja, aquela que apresenta o maior $C_v$.
"""

# ╔═╡ bf03e7f7-82a1-413c-bc6b-3bd19242f65d
md"""
### Histograma

O **histograma** é um gráfico de barras contíguas com as bases proporcionais aos intervalos das classes e a área de cada retângulo proporcional à respectiva frequência (*Bussab & Morettin, 2017*). Esse gráfico univariado é, provavelmente, o mais utilizado na AED que precede a estimativa de recursos.

> **Nota:** o histograma é um gráfico utilizado para representar a distribuição de variáveis contínuas.

Selecione, na lista suspensa abaixo, uma variável de teor para que seu histograma correspondente seja exibido.

Teor: $(@bind teor1 Select(["Cd","Co","Cr","Cu","Ni","Pb","Zn"]))

"""

# ╔═╡ ad7306da-0936-4208-9963-b3af1815b43b
begin
	X̅ = mean(dados[!,teor1])
	md = median(dados[!,teor1])
	
	histogram(dados[!,teor1], bins=:scott, label=false,
			  color=:honeydew2, alpha=0.75,
			  xlabel="$teor1 (ppm)", ylabel="Freq. Absoluta")
	
	vline!([X̅], color=:red, label="Média")
	vline!([md], color=:green, label="Mediana")
end

# ╔═╡ 155f6b0f-5156-4f42-93c2-6f867415ef37
md"""
##### Observações
- As variáveis que apresentam distribuições assimétricas positivas possuem caudas alongadas à direita. Essa forma de distribuição é típica de elementos menores;
- A variável `Co`, que possui distribuição ligeiramente assimétrica negativa, exibe uma distribuição com cauda alongada à esquerda. Esse tipo de assimetria é mais comum em elementos maiores (e.g. Fe₂O₃+FeO, Al₂O₃);
- A variável `Cr` mostra uma distribuição aproximadamente simétrica, o que não é algo típico de metais.
"""

# ╔═╡ 0acf95ad-4bd9-4022-b9f9-ce9a886ed1ed
md"""
### Boxplot

O **boxplot**, assim como o histograma, é um gráfico univariado que visa representar a distribuição de uma variável contínua. Essa visualização dá uma ideia da posição, dispersão, simetria e valores extremos de uma variável de interesse (*Bussab & Morettin, 2017*). A Figura 03 ilustra os elementos que constituem o boxplot.

![Figura 03](https://i.postimg.cc/HnRG8289/Figura-03.png)

**Figura 03:** Exemplo de boxplot e seus elementos. Figura elaborada pelo autor.

Selecione, na lista suspensa abaixo, uma variável de teor para que seu boxplot correspondente seja exibido.

Teor: $(@bind teor2 Select(["Cd","Co","Cr","Cu","Ni","Pb","Zn"]))

"""

# ╔═╡ 6c227179-d25f-4b13-86b1-f69e3f74bb8f
begin
	media = mean(dados[!,teor2])
	q1 = quantile(dados[!,teor2], 0.25)
	q2 = median(dados[!,teor2])
	q3 = quantile(dados[!,teor2], 0.75)
	iqr = q3 - q1
	min = minimum(dados[!,teor2])
	LS = q3 + (1.5 * iqr)
	
	boxplot(dados[!,teor2], label=false, alpha=0.75,
			color=:lightcyan, ylabel="$teor2 (ppm)",
			xticks=false, xaxis=false)
	
	plot!([media], seriestype = :scatter, color=:red,
		  marker=(:star5,5), label="Média")
end

# ╔═╡ c42132cd-b4e6-4561-a71b-13b276793f13
md"""
##### Observações

- Uma outra forma de descrever a assimetria de uma distribuição é por meio da comparação entre média e mediana:
    - Se $\overline{X} > md(X)$ $\rightarrow$ assimetria positiva;
    - Se $\overline{X} < md(X)$ $\rightarrow$ assimetria é negativa;
    - Se $\overline{X} = md(X)$ $\rightarrow$ simetria.
- O boxplot, pode ser entendido como uma "vista em planta" do histograma.
"""

# ╔═╡ a2b3a946-5ff3-4127-a797-be2fa4a2b9bf
md"""
### Gráfico de barras

O **gráfico de barras**, assim como o histograma, visa representar a distribuição de uma variável de interesse. Entretanto, esse tipo de gráfico é apropriado para a representação de variáveis qualitativas e discretas, como é o caso de `Rock` e `Landuse`.

Selecione, na lista suspensa abaixo, uma variável nominal para que seu gráfico de barras correspondente seja exibido.
"""

# ╔═╡ 85ac468b-452a-48b9-ae61-73a6e970c8c8
begin
	df_landuse = dados |>
			 	 @groupby(_.Landuse) |>
			 	 @map({classe=key(_), contagem=length(_)}) |>
			 	 DataFrame
	
	df_rock = dados |>
			  @groupby(_.Rock) |>
			  @map({classe=key(_), contagem=length(_)}) |>
			  DataFrame
end;

# ╔═╡ 9093aff6-4dac-4847-96e1-d6ef2c50cce7
md"""Variável nominal: $(@bind var_nom Select(["Landuse","Rock"]))"""

# ╔═╡ 4dbd3eca-9a4c-4aa5-8c15-2f294e33e814
begin
	if var_nom == "Landuse"
		bar(df_landuse.classe, df_landuse.contagem,
			label=false, color=:navajowhite1,
			alpha=0.75, ylabel="Freq. Absoluta")
	else
		bar(df_rock.classe, df_rock.contagem,
			label=false, color=:navajowhite1,
			alpha=0.75, ylabel="Freq. Absoluta")
	end
end

# ╔═╡ 98c18d0a-95fe-4949-9507-240bb90a02b9
md"""
##### Observações

- A maior parte da área é composta por regiões de `Campo`;

- Há um grande desbalanceamento na distribuição das litologias. As rochas pertencentes ao `Kimmeridgiano` e ao `Sequentiano` são predominantes na área, enquanto litotipos associados ao Portlandiano são escassos.
"""

# ╔═╡ c42c2eb0-2047-4490-9ebb-9b0203466836
md"""
## 5. Descrição bivariada

A **descrição bivariada** consiste em um conjunto de estatísticas e técnicas de visualização que visam descrever a relação entre duas variáveis por vez. Segundo *Isaaks & Srivastava (1989)*, grande parte das informações presentes em conjuntos de dados geoespaciais estão associadas às relações entre variáveis.
"""

# ╔═╡ cbec4c3f-198e-4334-ba18-55d2fbcc8a0d
md"""
### Coeficiente de Pearson

O **coeficiente de Pearson** é a estatística mais comum para descrever a relação entre duas variáveis (*Isaaks & Srivastava, 1989*). Essa medida pode ser calculada como:

```math
r = \frac{\frac{1}{n} \sum_{i=1}^{n} (x_i - \overline{X})(y_i - \overline{Y})}{S_x S_y}
```

> **Nota:** o numerador da equação acima é uma estatística denominada **covariância**. Portanto, podemos dizer que o coeficiente de Pearson é a covariância normalizada.

O coeficiente de Pearson mede um tipo especial de relação, a **correlação linear**. Basicamente, existem três tipos de padrões:

- **$r > 0$** → correlação linear positiva;

- **$r < 0$** → correlação linear negativa;

- **$r \approx 0$** → ausência de correlação.

> **Nota:** esse coeficiente assume valores no intervalo **[-1, 1]**. Desse modo, quanto maior é o módulo do coeficiente, maior é a força da correlação linear, seja ela positiva ou negativa.

Podemos utilizar a função `cor` para computar o coeficiente de correlação de Pearson entre os teores de `Cr` e `Co`...

"""

# ╔═╡ e7a33281-7f6d-45cc-bb27-d7d9d2774bee
cor(dados.Cr, dados.Co)

# ╔═╡ 1f684b7d-3cfb-4ede-aadd-e82b131e017d
md"""
Como nossos dados contém sete elementos químicos, podemos calcular uma **matriz de correlação** para facilitar a visualização das relações entre todas as variáveis de uma só vez.

Selecione as variáveis de interesse nas listas suspensas abaixo para que o coeficiente de Pearson entre elas seja computado:
"""

# ╔═╡ 98912d9a-d1bb-4b4d-a7eb-f98963bf790d
begin
	TEORES = ["Cd","Co","Cr","Cu","Ni","Pb","Zn"]
	
	md"""Variáveis: $(@bind V₁ Select(TEORES)) e $(@bind V₂ Select(TEORES))"""
end

# ╔═╡ fce35de6-7f4c-4817-8554-397d2bb19778
begin
	mtz = Matrix(dados[!,TEORES])
	cor_mtz = cor(mtz)
	cc = round(cor(dados[!,V₁], dados[!,V₂]), digits=2)
	
	heatmap(TEORES, TEORES, cor_mtz, color=:coolwarm, clims=(0,1),
			title="r($V₁, $V₂) = $cc")
end

# ╔═╡ d2956461-9a8f-4123-9243-523f623e1f21
md"""
##### Observações

- Todos os elementos químicos do banco de dados apresentam correlações lineares positivas entre si;
- Os elementos `Pb` e `Cu` apresentam a correlação linear mais forte ($r = 0.78$);
- Os elementos `Cu` e `Cd` apresentam a correlação linear mais fraca ($r = 0.13$).
"""

# ╔═╡ ab709b9f-a06a-4bed-a36b-f3c5d6e46265
md"""
### Diagrama de dispersão

O **diagrama de dispersão**, também chamado de *scatterplot*, é um o dispositivo útil para se verificar a associação entre duas variáveis (*Bussab & Morettin, 2017*). No eixo horizontal é representado pelos valores de uma variável, enquanto o eixo vertical é rotulado com os valores da outra variável.

> **Nota:** é sempre interessante visualizar o diagrama de dispersão (gráfico) em conjunto com o coeficiente de Pearson (estatística) para analisar a relação de um par de variáveis.

Nas listas suspensas abaixo, selecione as variáveis de interesse para visualizar o diagrama de dispersão.

Variáveis: $(@bind var₁ Select(TEORES)) e $(@bind var₂ Select(TEORES))
"""

# ╔═╡ 3a75e14e-9ddb-423b-99a5-d7280218b41e
begin
	x = dados[!,var₁]
	y = dados[!,var₂]
	r = round(cor(x,y), digits=2)
	
	scatter(x, y, xlabel="$var₁ (ppm)", ylabel="$var₂ (ppm)",
			label="r = $r", color=:black, markersize=2)
	
	vline!([mean(x)], color=:red, ls=:dash, label="Média")
	hline!([mean(y)], color=:red, ls=:dash, label=false)
	plot!([mean(x)],[mean(y)], marker=(:square, 4, :red), label=false)
end

# ╔═╡ a5fd7cc5-9460-48d1-ae90-c1a0f0dff265
md"""
## 6. Descrição espacial

"""

# ╔═╡ e6a85185-8188-42e7-b639-34e8c9a8c515


# ╔═╡ 447ead1b-53a3-42a3-ad9d-6bc7c099c40f


# ╔═╡ fbeade43-7a37-4d16-bc24-eb857799a732


# ╔═╡ 5f177c03-cb3d-4268-8c33-3aa7610e337b
md"""
## 7. Recursos adicionais

Abaixo, são listados alguns recursos complementares a este notebook:

> [Videoaula Descrição Univariada - LPM/UFRGS](https://www.youtube.com/watch?v=ZRh9d_GHfqM)

> [Videoaula Descrição Bivariada - LPM/UFRGS](https://www.youtube.com/watch?v=U0sqVJY_mzA)

> [Videoaula Estatística Univariada - University of Texas](https://www.youtube.com/watch?v=wAcbA2cIqec&list=PLG19vXLQHvSB-D4XKYieEku9GQMQyAzjJ)

> [Minicurso de Geoestatística CBMina 2021](https://github.com/juliohm/CBMina2021)
"""

# ╔═╡ 47cf20cd-62f6-43c2-b531-31eab994aa15
md"""
## Referências

*Bussab, W. O.; Morettin, P. A. [Estatística básica](https://www.google.com.br/books/edition/ESTAT%C3%8DSTICA_B%C3%81SICA/vDhnDwAAQBAJ?hl=pt-BR&gbpv=0). 9ª ed. São Paulo: Saraiva, 2017.*

*Goovaerts, P. [Geostatistics for natural resources evaluation](https://www.google.com.br/books/edition/Geostatistics_for_Natural_Resources_Eval/CW-7tHAaVR0C?hl=pt-BR&gbpv=0). New York: Oxford University Press, 1997.*

*Isaaks, E. H.; Srivastava, M. R. [Applied geostatistics](https://www.google.com.br/books/edition/Applied_Geostatistics/gUXQzQEACAAJ?hl=pt-BR). New York: Oxford University Press, 1989.*

*Magalhães, M. N.; De Lima, A. C. P. [Noções de probabilidade e estatística](https://www.google.com.br/books/edition/No%C3%A7%C3%B5es_de_Probabilidade_e_Estat%C3%ADstica/-BAuPwAACAAJ?hl=pt-BR). 7ª ed. São Paulo: Editora da Universidade de São Paulo, 2015.*

*Rossi, M. E.; Deutsch, C. V. [Mineral resource estimation](https://www.google.com.br/books/edition/Mineral_Resource_Estimation/gzK_BAAAQBAJ?hl=pt-BR&gbpv=0). New York: Springer Science & Business Media, 2013.*

*Tukey, J. W. [Exploratory data analysis](https://www.google.com.br/books/edition/Exploratory_Data_Analysis/UT9dAAAAIAAJ?hl=pt-BR&gbpv=0&bsq=exploratory%20data%20analysis). Princeton: Addison-Wesley Publishing Company, 1977.*

"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
GeoStats = "dcc97b0b-8ce5-5539-9008-bb190f959ef6"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Query = "1a8c2f83-1ff3-5112-b086-8aa67b057ba1"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
StatsPlots = "f3b207a7-027a-5e70-b257-86293d7955fd"

[compat]
CSV = "~0.9.4"
DataFrames = "~1.2.2"
GeoStats = "~0.27.0"
Plots = "~1.22.2"
PlutoUI = "~0.7.11"
Query = "~1.0.0"
StatsBase = "~0.33.11"
StatsPlots = "~0.14.27"
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
git-tree-sha1 = "b8d49c34c3da35f220e7295659cd0bab8e739fed"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.1.33"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[AverageShiftedHistograms]]
deps = ["LinearAlgebra", "RecipesBase", "Statistics", "StatsBase", "UnicodePlots"]
git-tree-sha1 = "8bdad2055f64dd71a25826d752e0222726f25f20"
uuid = "77b51b56-6f8f-5c3a-9cb4-d71f9594ea6e"
version = "0.8.7"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "a4d07a1c313392a77042855df46c5f534076fab9"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.0"

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

[[BinaryProvider]]
deps = ["Libdl", "Logging", "SHA"]
git-tree-sha1 = "ecdec412a9abc8db54c0efc5548c64dfce072058"
uuid = "b99e7846-7c00-51b0-8f62-c81ae34c0232"
version = "0.5.10"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "3a877c2fc5c9b88ed7259fd0bdb7691aad6b50dc"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.9.4"

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
git-tree-sha1 = "bd4afa1fdeec0c8b89dad3c6e92bc6e3b0fec9ce"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.6.0"

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

[[CorpusLoaders]]
deps = ["CSV", "DataDeps", "Glob", "InternedStrings", "LightXML", "MultiResolutionIterators", "StringEncodings", "WordTokenizers"]
git-tree-sha1 = "9e0ffdcccf38ef5f601bb73672d88c014d2ea2cf"
uuid = "214a0ac2-f95b-54f7-a80b-442ed9c2c9e8"
version = "0.3.3"

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

[[DataDeps]]
deps = ["BinaryProvider", "HTTP", "Libdl", "Reexport", "SHA", "p7zip_jll"]
git-tree-sha1 = "4f0e41ff461d42cfc62ff0de4f1cd44c6e6b3771"
uuid = "124859b0-ceae-595e-8997-d05f6a7a8dfe"
version = "0.7.7"

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
git-tree-sha1 = "4b1cea8bbbc46367b0c551bb22bd2debb083b303"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.3.12"

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
git-tree-sha1 = "9f46deb4d4ee4494ffb5a40a27a2aced67bdd838"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.4"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns"]
git-tree-sha1 = "f4efaa4b5157e0cdb8283ae0b5428bc9208436ed"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.16"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

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
git-tree-sha1 = "6d4b609786127030d09e6b1ee0e2044ec20eb403"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.11"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "29890dfbc427afa59598b8cfcc10034719bd7744"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.6"

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
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "NaNMath", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "b5e930ac60b613ef3406da6d4f42c35d8dc51419"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.19"

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
git-tree-sha1 = "dba1e8614e98949abfa60480b13653813d8f0157"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+0"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "c2178cfbc0a5a552e16d097fae508f2024de61a3"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.59.0"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "ef49a187604f865f4708c90e3f431890724e9012"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.59.0+0"

[[GeoClustering]]
deps = ["Clustering", "Distances", "LinearAlgebra", "Meshes", "SparseArrays", "Statistics", "TableOperations", "Tables"]
git-tree-sha1 = "70daa513ef151d46a5b40b027a23080fcd62a529"
uuid = "7472b188-6dde-460e-bd07-96c4bc049f7e"
version = "0.2.2"

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
git-tree-sha1 = "88aae34ed0d2f6bb95ce13ee09a9a1970cd647b9"
uuid = "323cb8eb-fbf6-51c0-afd0-f8fba70507b2"
version = "0.21.12"

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

[[Glob]]
git-tree-sha1 = "4df9f7e06108728ebf00a0a11edee4b29a482bb2"
uuid = "c27321d9-0574-5035-807b-f59d2c89b15c"
version = "1.3.0"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTML_Entities]]
deps = ["StrTables"]
git-tree-sha1 = "c4144ed3bc5f67f595622ad03c0e39fa6c70ccc7"
uuid = "7693890a-d069-55fe-a829-b4a6d304f0ee"
version = "1.0.1"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "MbedTLS", "Sockets"]
git-tree-sha1 = "c7ec02c4c6a039a98a15f955462cd7aea5df4508"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.8.19"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "8a954fed8ac097d5be04921d595f741115c1b2ad"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+0"

[[HypertextLiteral]]
git-tree-sha1 = "72053798e1be56026b81d4e2682dbe58922e5ec9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.0"

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
git-tree-sha1 = "26c8832afd63ac558b98a823265856670d898b6c"
uuid = "22cec73e-a1b8-11e9-2c92-598750a2cf9c"
version = "0.2.10"

[[IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InternedStrings]]
deps = ["Random", "Test"]
git-tree-sha1 = "eb05b5625bc5d821b8075a77e4c421933e20c76b"
uuid = "7d512f48-7fb1-5a58-b986-67e6dc259f01"
version = "0.7.0"

[[Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "61aa005707ea2cebf47c8d780da8dc9bc4e0c512"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.4"

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[IrrationalConstants]]
git-tree-sha1 = "f76424439413893a832026ca355fe273e93bce94"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.0"

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
git-tree-sha1 = "a4b12a1bd2ebade87891ab7e36fdbce582301a92"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.6"

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
git-tree-sha1 = "761a393aeccd6aa92ec3515e428c26bf99575b3b"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+0"

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

[[LightXML]]
deps = ["BinaryProvider", "Libdl"]
git-tree-sha1 = "be855e3c975b89746b09952407c156b5e4a33a1d"
uuid = "9c8b4983-aa76-5018-a973-4c85ecc9e179"
version = "0.8.1"

[[LineSearches]]
deps = ["LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "Printf"]
git-tree-sha1 = "f27132e551e959b3667d8c93eae90973225032dd"
uuid = "d3d80556-e9d4-5f37-9878-2ab0fcc64255"
version = "7.1.1"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "34dc30f868e368f8a17b728a1238f3fcda43931a"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.3"

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
git-tree-sha1 = "91ef121a2c458806973c8aaeb502c57b2f0d74b3"
uuid = "e80e1ace-859a-464e-9ed9-23947d8ae3ea"
version = "1.3.2"

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
git-tree-sha1 = "70403f6fe58a3c6bdb3bc8e3de9719f95c52dede"
uuid = "eacbb407-ea5a-433e-ab97-5258b1ca43fa"
version = "0.17.7"

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

[[MultiResolutionIterators]]
deps = ["IterTools", "Random", "Test"]
git-tree-sha1 = "27fa99913e031afaf06ea8a6d4362fd8c94bb9fb"
uuid = "396aa475-d5af-5b65-8c11-5c82e21b2380"
version = "0.5.0"

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
git-tree-sha1 = "9d8c00ef7a8d110787ff6f170579846f776133a9"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.4"

[[PersistenceDiagramsBase]]
deps = ["Compat", "Tables"]
git-tree-sha1 = "ec6eecbfae1c740621b5d903a69ec10e30f3f4bc"
uuid = "b1ad91c1-539c-4ace-90bd-ea06abc420fa"
version = "0.1.1"

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
git-tree-sha1 = "2537ed3c0ed5e03896927187f5f2ee6a4ab342db"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.14"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs"]
git-tree-sha1 = "457b13497a3ea4deb33d273a6a5ea15c25c0ebd9"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.22.2"

[[PlutoUI]]
deps = ["Base64", "Dates", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "0c3e067931708fa5641247affc1a1aceb53fff06"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.11"

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
git-tree-sha1 = "0d1245a357cc61c8cd61934c07447aa569ff22e6"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.1.0"

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
git-tree-sha1 = "d526371cec370888f485756a4bf8284ab531860b"
uuid = "74f56ac7-18b3-5285-802d-d4bd4f104033"
version = "1.0.1"

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
deps = ["CategoricalArrays", "ColorTypes", "CorpusLoaders", "Dates", "Distributions", "PersistenceDiagramsBase", "PrettyTables", "Reexport", "ScientificTypesBase", "StatisticalTraits", "Tables"]
git-tree-sha1 = "cf596b0378c45642b76b7a60ab608a25c7236506"
uuid = "321657f4-b219-11e9-178b-2701a2544e81"
version = "2.2.2"

[[ScientificTypesBase]]
git-tree-sha1 = "9c1a0dea3b442024c54ca6a318e8acf842eab06f"
uuid = "30f210dd-8aff-4c5f-94ba-8e64358c1161"
version = "2.2.0"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "54f37736d8934a12a200edea2f9206b03bdf3159"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.7"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "Requires"]
git-tree-sha1 = "fca29e68c5062722b5b4435594c3d1ba557072a3"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "0.7.1"

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
deps = ["ChainRulesCore", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "ad42c30a6204c74d264692e633133dcea0e8b14e"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.6.2"

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
git-tree-sha1 = "a8f30abc7c64a39d389680b74e749cf33f872a70"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.3.3"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3240808c6d463ac46f1c1cd7638375cd22abbccb"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.12"

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
git-tree-sha1 = "65fb73045d0e9aaa39ea9a29a5e7506d9ef6511f"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.11"

[[StatsFuns]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "46d7ccc7104860c38b11966dd1f72ff042f382e4"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.10"

[[StatsPlots]]
deps = ["Clustering", "DataStructures", "DataValues", "Distributions", "Interpolations", "KernelDensity", "LinearAlgebra", "MultivariateStats", "Observables", "Plots", "RecipesBase", "RecipesPipeline", "Reexport", "StatsBase", "TableOperations", "Tables", "Widgets"]
git-tree-sha1 = "233bc83194181b07b052b4ee24515564b893faf6"
uuid = "f3b207a7-027a-5e70-b257-86293d7955fd"
version = "0.14.27"

[[StrTables]]
deps = ["Dates"]
git-tree-sha1 = "5998faae8c6308acc25c25896562a1e66a3bb038"
uuid = "9700d1a9-a7c8-5760-9816-a99fda30bb8f"
version = "1.0.1"

[[StringEncodings]]
deps = ["Libiconv_jll"]
git-tree-sha1 = "50ccd5ddb00d19392577902f0079267a72c5ab04"
uuid = "69024149-9ee7-55f6-a4c4-859efe599b68"
version = "0.3.5"

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

[[TableOperations]]
deps = ["SentinelArrays", "Tables", "Test"]
git-tree-sha1 = "019acfd5a4a6c5f0f38de69f2ff7ed527f1881da"
uuid = "ab02a1b2-a7df-11e8-156e-fb1833f50b87"
version = "1.1.0"

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
git-tree-sha1 = "1162ce4a6c4b7e31e0e6b14486a6986951c73be9"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.5.2"

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
git-tree-sha1 = "dec7b7839f23efe21770b3b1307ca77c13ed631d"
uuid = "28d57a85-8fef-5791-bfe6-a80928e7c999"
version = "0.4.66"

[[TypedTables]]
deps = ["Adapt", "Dictionaries", "Indexing", "SplitApplyCombine", "Tables", "Unicode"]
git-tree-sha1 = "f91a10d0132310a31bc4f8d0d29ce052536bd7d7"
uuid = "9d95f2ec-7b3d-5a63-8d20-e2491e220bb9"
version = "1.4.0"

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
git-tree-sha1 = "bf82907bb1e41c0a69beccf2e035df49d4368920"
uuid = "b8865327-cd53-5732-bb35-84acbb429228"
version = "2.4.5"

[[Variography]]
deps = ["Distances", "GeoStatsBase", "InteractiveUtils", "LinearAlgebra", "Meshes", "NearestNeighbors", "Optim", "Parameters", "Printf", "RecipesBase", "Setfield", "SpecialFunctions", "Transducers"]
git-tree-sha1 = "07d6f8e560a8392c6e99ac4a4a7eb3b4bb17b248"
uuid = "04a0146e-e6df-5636-8d7f-62fa9eb0b20c"
version = "0.12.16"

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
deps = ["DataAPI", "Parsers"]
git-tree-sha1 = "4a4cfb1ae5f26202db4f0320ac9344b3372136b0"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.3.0"

[[Widgets]]
deps = ["Colors", "Dates", "Observables", "OrderedCollections"]
git-tree-sha1 = "80661f59d28714632132c73779f8becc19a113f2"
uuid = "cc8bc4a8-27d6-5769-a93b-9d913e69aa62"
version = "0.6.4"

[[WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "59e2ad8fd1591ea019a5259bd012d7aee15f995c"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.3"

[[WordTokenizers]]
deps = ["DataDeps", "HTML_Entities", "StrTables", "Unicode"]
git-tree-sha1 = "01dd4068c638da2431269f49a5964bf42ff6c9d2"
uuid = "796a5d58-b03d-544a-977e-18100b691f6e"
version = "0.5.6"

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
git-tree-sha1 = "9e7a1e8ca60b742e508a315c17eef5211e7fbfd7"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.1"

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
# ╟─9aed0800-1e13-11ec-2780-69699771cc17
# ╟─67ed7bd0-32cc-49bf-8c30-6c34ad29c88a
# ╟─5e44a696-0a3e-40f1-b125-2dec95b5cf79
# ╟─cfc649b3-e423-4aa9-925b-763e2986e2f5
# ╟─b53bfda4-60de-43c8-9852-faa1051050e2
# ╟─f7756000-3e37-436e-b070-6d57afe142d7
# ╟─e28a9056-d62d-4ab6-be00-0174180a73c5
# ╟─a8c53b89-634b-4526-be62-f51f22c3c607
# ╟─b8576b51-2a2b-4614-ae62-280394944319
# ╟─b517b327-27e9-4e7c-a721-3ff8c991ff08
# ╟─c08e9281-bbc8-4328-b005-b867c77f725c
# ╟─01280f05-2fc2-4860-add3-8b40d9bd546e
# ╟─966a59b1-f8b8-4612-ab4d-ff7ec2a569d9
# ╠═6ded7ce7-4239-4a17-a048-c02982dae5f9
# ╟─e34b3cdf-736d-40b8-8289-bfe968925b17
# ╠═2d16b0e1-ce43-46a5-a4ce-eced1d88d4e6
# ╟─778ce45e-1486-433b-8c0a-1b5beddaf352
# ╟─71004e57-95c2-403d-992e-4cf0875a6d2e
# ╠═1014b88e-9aad-4e89-ba9d-f7701fc1a812
# ╟─f25cb0bc-e063-4ff1-9521-50c9e72fcbbe
# ╟─f5bf9985-62be-48d1-8399-ecde710e1dd5
# ╟─b7820679-6ec3-4580-a502-4e4315ed44f9
# ╟─e1ff515f-c0d2-4e4b-b768-8d5611347e2d
# ╠═17cdccaf-a34e-4b49-8156-01f6221ae00b
# ╟─476e5bc7-5d9c-43fe-ac84-ead5bbbfe4b9
# ╠═98b6bce7-8cc4-4d7f-b947-21feb4b43bf0
# ╟─581459c4-312a-4022-a87c-35887f625d6d
# ╠═79ff3f1a-9bf6-421e-8ab9-7a592fa21bbd
# ╟─9b546155-55ad-4927-8f94-b021bf58934e
# ╟─45735824-f693-47e8-b771-2553fb968605
# ╠═16ba02e8-e555-4dd7-a197-fc4b1b6a7fe3
# ╟─e23f2abb-37a2-483f-80f1-c24312de1adb
# ╠═746d33e3-448c-45e4-974c-093e3e001553
# ╟─b3fb81b8-8f00-4fe5-877c-3c6a1f7ded77
# ╠═82a219b0-d1ca-4db0-8738-6b3f8e27189b
# ╟─3e2ea93f-0219-4766-b550-4d3788608ca4
# ╠═1c851dd2-7e85-4c94-a806-2afea3199291
# ╟─2ed2fe35-8b11-41cc-8106-cddad3891b89
# ╠═57414e29-2eee-49a6-8678-94d2fdabb70a
# ╟─7f94f1b4-9ac8-4137-9787-a722670508bb
# ╠═cecf023e-5002-48ca-8ea5-0cb294f2e419
# ╟─4fcf13f4-7f79-4c6d-b365-052c1fb9bb5d
# ╠═2dfad787-72a2-4414-849d-fbab7aa4c40f
# ╟─64b87701-bf9e-46c9-8700-89d2ef546621
# ╟─bf03e7f7-82a1-413c-bc6b-3bd19242f65d
# ╟─ad7306da-0936-4208-9963-b3af1815b43b
# ╟─155f6b0f-5156-4f42-93c2-6f867415ef37
# ╟─0acf95ad-4bd9-4022-b9f9-ce9a886ed1ed
# ╟─6c227179-d25f-4b13-86b1-f69e3f74bb8f
# ╟─c42132cd-b4e6-4561-a71b-13b276793f13
# ╟─a2b3a946-5ff3-4127-a797-be2fa4a2b9bf
# ╟─85ac468b-452a-48b9-ae61-73a6e970c8c8
# ╟─9093aff6-4dac-4847-96e1-d6ef2c50cce7
# ╟─4dbd3eca-9a4c-4aa5-8c15-2f294e33e814
# ╟─98c18d0a-95fe-4949-9507-240bb90a02b9
# ╟─c42c2eb0-2047-4490-9ebb-9b0203466836
# ╟─cbec4c3f-198e-4334-ba18-55d2fbcc8a0d
# ╠═e7a33281-7f6d-45cc-bb27-d7d9d2774bee
# ╟─1f684b7d-3cfb-4ede-aadd-e82b131e017d
# ╟─98912d9a-d1bb-4b4d-a7eb-f98963bf790d
# ╟─fce35de6-7f4c-4817-8554-397d2bb19778
# ╟─d2956461-9a8f-4123-9243-523f623e1f21
# ╟─ab709b9f-a06a-4bed-a36b-f3c5d6e46265
# ╟─3a75e14e-9ddb-423b-99a5-d7280218b41e
# ╟─a5fd7cc5-9460-48d1-ae90-c1a0f0dff265
# ╠═e6a85185-8188-42e7-b639-34e8c9a8c515
# ╠═447ead1b-53a3-42a3-ad9d-6bc7c099c40f
# ╠═fbeade43-7a37-4d16-bc24-eb857799a732
# ╟─5f177c03-cb3d-4268-8c33-3aa7610e337b
# ╟─47cf20cd-62f6-43c2-b531-31eab994aa15
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
