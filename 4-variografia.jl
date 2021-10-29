### A Pluto.jl notebook ###
# v0.17.0

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

# ╔═╡ 1991a290-cfbf-11eb-07b6-7b3c8543dd28
begin
	# carregando pacotes necessários
	using GeoStats, GeoStatsImages
	using CSV, DataFrames, Query
    using Statistics, Random
	using PlutoUI
    using Plots
	
	# configurações de visualização
	gr(format=:png)
end;

# ╔═╡ f8909bd5-9167-42ea-a302-a7a50bdc365c
html"""
<p style="background-color:lightgrey" xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><span property="dct:title">&nbsp&nbsp📈&nbsp<b>Variografia</b></span> por <span property="cc:attributionName">Franco Naghetini</span> é licenciado sob <a href="http://creativecommons.org/licenses/by/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1"></a></p>
"""

# ╔═╡ 3bd915e1-2f58-451c-a0fb-8aec6d6f75d9
PlutoUI.TableOfContents(aside=true, title="Sumário",
						indent=true, depth=2)

# ╔═╡ faa9d295-ae72-4912-bfca-925c4e7b9b35
md"""
![ufmg-logo](https://logodownload.org/wp-content/uploads/2015/02/ufmg-logo-2.png)
"""

# ╔═╡ 029c1951-054b-4f48-bc05-341250ce9f6a
md"""
# 📈 Variografia

Um aspecto fundamental da modelagem geoestatística é o estabelecimento de medidas quantitativas de **continuidade espacial** que são utilizadas posteriormente na estimativa e/ou simulação. Nas últimas décadas, a modelagem da continuidade espacial se tornou uma prática essencial para qualquer geólogos de recursos (*Rossi & Deutsch, 2013*).

Diferentemente do [módulo 3](https://github.com/fnaghetini/intro-to-geostats/blob/main/3-analise_exploratoria.jl), em que aprendemos sobre técnicas da Estatística Clássica, neste módulo, teremos uma breve introdução sobre uma ferrameta geoestatística amplamente utilizada na descrição da variabilidade espacial, o **variograma**.

> ⚠️ Enfatiza-se que, como a variografia é um assunto muito amplo, neste módulo, focaremos apenas em seus aspectos mais básicos. Caso deseje se aprofundar no tema, consulte as seções *Referências* e *Recursos adicionais* deste notebook. Por esse mesmo motivo, as células de código não serão discutidas em profundidade neste notebook.

Ao final da variografia (i.e. modelagem da continuidade de valores), teremos em mãos um **modelo de variograma** representativo da estrutura espacial de uma variável de interesse e que será utilizado como entrada para a estimativa. Veremos que a variografia permite inserir interpretações geológicas na estimativa de recursos.
"""

# ╔═╡ 1e211855-33b8-429f-a4e1-b01e8ad88bab
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
>- Você pode utilizar este notebook da forma que quiser, basta referenciar [este link](https://github.com/fnaghetini/intro-to-geostats). Consulte a [licença]  (https://creativecommons.org/licenses/by/4.0/?ref=chooser-v1) para saber mais detalhes.
>- Para mais informações acesse o [README](https://github.com/fnaghetini/intro-to-geostats/blob/main/README.md) do projeto 🚀
"""

# ╔═╡ 363b1ca8-1cb4-465d-89b3-a15570d5dc7f
md"""
## 1. Conceitos básicos

Nesta primeira seção, iremos aprender sobre conceitos cruciais para o entendimento de variogramas: *continuidade espacial* e *anisotropia*. Veremos que essas propriedades estão intimamente ligadas às características geológicas dos depósitos minerais. Além disso, discutiremos um pouco sobre o principal banco de dados utilizado neste módulo.
"""

# ╔═╡ e1502221-f2ee-4f76-b442-f83dbf454743
md"""
### Continuidade espacial

Segundo *Sinclair & Blackwell (2006)*, o termo **continuidade espacial** é comumente utilizado de forma ambígua para se referir tanto às ocorrências físicas de características geológicas que controlam a mineralização (e.g. zonas de cisalhamento, veios, falhas), quanto aos teores metalíferos.

Na tentativa de clarear essa ambiguidade, *Sinclair & Vallée (1994)* definem dois tipos de continuidade espacial:

> **Continuidade geológica:** manifestações físicas de características geológicas, como veios, zonas de cisalhamento e estratos mineralizados. Esse tipo de continuidade é interpretada durante a modelagem geológica e impacta diretamente toda a estimativa de recursos.

> **Continuidade de valores:** distribuição espacial de caracteristicas quantitativamente mensuradas, como teores metalíferos, densidade e espessura das mineralizações. Esse tipo de continuidade é quantificada a partir de alguma função de autocorrelação (e.g. variograma).

Neste módulo, aprenderemos sobre a continuidade de valores. Da mesma forma que um depósito mineral não ocorre aleatoriamente na natureza, a distribuição de teores metalíferos, por ser resultado da interação entre diversos processos metalogenéticos, também apresenta uma certa estrutura (ou organização) espacial.
"""

# ╔═╡ faee9091-89aa-46ff-9a90-42eb71dcdd6a
md"""
### Anisotropia

Se você já teve aulas de Mineralogia, provavelmente já se deparou com o termo **anisotropia**. Nas aulas dessa disciplina, aprendemos que a dureza da cianita, um aluminossilicato típico de rochas metamórficas de média a alta pressão, é anisotrópica. Isso quer dizer que, se testada paralelamente à sua maior elongação, a dureza é de 4,5 a 5 na escala de Mohs, enquanto que, se testada perpendicularmente à essa direção, a dureza é de 6,5 a 7.

> Quando uma propriedade assume valores distintos para diferentes direções, diz-se que essa propriedade é **anisotrópica**. Por outro lado, uma propriedade que não varia com a direção é dita **isotrópica**.

A distribuição de teores nos depósitos minerais é frequentemente anisotrópica e, portanto, precisamos de ferramentas de modelagem da continuidade que reconheçam anisotropia (e.g. variograma). Imagine um extenso platô de bauxita. É intuitivo pensar que os teores de Al₂O₃ são mais contínuos lateralmente e menos contínuos verticalmente. Nesse exemplo, a distribuição do teor de Al₂O₃ é um fenômeno anisotrópico.
"""

# ╔═╡ 12770ca7-be19-4b11-88b5-0b65a05cefd6
md"""
### Banco de dados

Neste módulo, iremos trabalhar com o banco de dados [Walker Lake]() do excelente livro de *Isaaks & Srivastava (1989)*. Segundo os autores, esse banco de dados foi gerado a partir de um modelo digital de elevação da região de Walker Lake, situada no estado de Nevada (EUA).

Originalmente, *Isaaks & Srivastava (1989)* adaptaram essa informação de elevação para gerar duas variáveis anônimas `U` e `V`. Entretanto, ao realizar manipulações nessa base de dados, o autor deste material irá se referir a essas variáveis como teores fictícios de `Ag` (em ppm) e `Pb` (em %), respectivamente.

Vamos importar e georreferenciar essa base de dados. Para isso, iremos utilizar apenas as colunas `X`, `Y` e `Pb` e removeremos os valores faltantes...
"""

# ╔═╡ 57bf7106-7316-43f7-8578-f59f01f04b79
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

# ╔═╡ 51107168-29ca-40b1-a658-9361199be3b1
md"""
## 2. Variograma

O **variograma** é uma função matemática que mapeia/descreve a continuidade espacial de uma variável regionalizada (i.e. variável que exibe certa estrutura espacial). Podemos utilizar o variograma, por exemplo, para descrever a continuidade espacial dos teores de Au em um depósito.

Matematicamente, a função variograma pode ser definida como a diferença quadrática média entre dois valores amostrais separados por um vetor distância $h$ (*Rossi & Deutsch, 2013*):

```math
\gamma(h) = \frac{1}{2n} \sum_{i=1}^{n} [Z(x_i) - Z(x_i + h)]^2
```

em que $γ(h)$ é o valor do variograma para uma distância $h$ entre dois pontos, $n$ é o número de pares de amostras, $Z(x_i)$ é o valor da variável $Z$ na posição $(x_i)$ e $Z(x_i + h)$ é valor da variável $Z$ na posição $(x_i+h)$.

> ⚠️ Em seus estudos, você provavelmente irá se deparar (ou já se deparou) com o termo **semivariograma**, por vezes utilizado para enfatizar o termo $\frac{1}{2n}$ da equação mostrada. Entretanto, para fins de simplificação, adotaremos o termo variograma para se referir a essa mesma equação.

A função variograma pode ser anisotrópica, sendo sensível à direção, mas não ao sentido. Por exemplo, um variograma de orientação 000° é diferente de um variograma 045°, mas igual a um variograma 180°.

> ⚠️ Utilizaremos o pacote [GeoStats.jl](https://github.com/JuliaEarth/GeoStats.jl) para o cálculo de variogramas que, por sua vez, conta com um algoritmo sofisticado capaz de lidar de forma eficiente com um grande volume de dados (*Hoffimann & Zadrozny, 2019*).
"""

# ╔═╡ ea67e941-496f-45a3-8b0f-058d573291d8
md"""

### Elementos do variograma

O variograma apresenta alguns elementos que o descreve. São eles:
1. Alcance
2. Patamar
3. Efeito Pepita

"""

# ╔═╡ 03a46b21-c522-4036-a710-bd6ce0a26a1b
md"""
À medida que a distância $h$ entre duas amostras aumenta, o valor de $\gamma$ correspondente tende também a aumentar. Entretanto, a partir de determinado $h$, o aumento da distância entre duas amostras não é mais acompanhado pelo aumento dos valores de $\gamma$ e o variograma atinge seu platô (*Isaaks & Srivastava, 1989*).

O **alcance** $a$, também chamado de amplitude ou *range*, é definido como a distância $h$ para a qual o variograma atinge seu platô (*Isaaks & Srivastava, 1989*). Pode-se pensar que o alcance é a distância máxima até onde se consegue estabelecer alguma interdependência espacial entre pares de amostras. Em outras palavras, para $h > a$, os pares de amostras não possuem mais correlação espacial entre si.

O **patamar** $C_0+C$, também chamado de *sill*, corresponde ao valor de $\gamma$ para o qual o variograma atinge seu platô (*Samson & Deutsch, 2021*). Durante a modelagem do variograma, que iremos discutir mais a frente, o patamar é normalmente definido como a o valor da variância amostral da variável de interesse.

> ⚠️ Caso queira se aprofundar mais sobre o patamar do variograma, confira *Samson & Deutsch (2021)*.

O **efeito pepita** $C_0$, também chamado de *nugget effect*, graficamente, é entendido como a descontinuidade na origem do variograma (*Morgan, 2011*). Ressalta-se, entretanto, que o efeito pepita corresponde ao valor de $\gamma$ quando $h$ *tende* a zero, uma vez que o valor de $\gamma$ é zero quando $h=0$ (*Camana & Deutsch, 2019*).

> ⚠️ O efeito pepita também pode ser definido como um fenômeno presente em variáveis regionalizadas que representa uma variabilidade adicional a curtas distâncias. Para mais detalhes, confira *Camana & Deutsch (2019)*.

Utilize os sliders abaixo para modificar os elementos do variograma mostrado pela Figura 01...
"""

# ╔═╡ 3a03cb21-0dd0-488d-9950-92ee2ed8d697
md"""
Ef. Pepita: $(@bind c₀ Slider(0.0:0.1:0.5, default=0.1, show_value=true))

Patamar: $(@bind cₜ Slider(0.5:0.1:1.0, default=1.0, show_value=true))

Alcance: $(@bind a Slider(5.0:10:45.0, default=25.0, show_value=true)) m
"""

# ╔═╡ 8519999f-2062-41b7-a8ae-4e190b2df860
begin
	# modelo de variograma
	γ_ = SphericalVariogram(nugget=Float64(c₀),
							sill=Float64(cₜ),
							range=Float64(a))
	
	# plotagem do modelo de variograma
	plot(γ_, color = :black, lw = 2, label = false,
		 legend = :topleft, ylims = (0.,1.5), xlims = (0.,65.))
	
	# plotagem ef. pepita
	hline!([c₀], color = :red, ls = :dash, label = "Ef. Pepita")
	annotate!(55,c₀+0.05,text("C₀",10,:red))
	
	# plotagem patamar
	hline!([cₜ], color = :green, ls = :dash, label = "Patamar")
	annotate!(55,cₜ+0.05,text("C + C₀",10,:green))
	
	# plotagem alcance
	vline!([a], color = :blue, ls = :dash, label = "Alcance")
	annotate!(a,-0.05,text("a",10,:blue))
end

# ╔═╡ 59c0673a-e117-4669-8156-6d3a8eb861e8
md" **Figura 01:** Elementos do variograma."

# ╔═╡ 0c00aee8-9db5-4fca-b92d-e19aa4fe5c1b
md"""
## 3. Variograma experimental

Podemos utilizar a equação apresentada acima para calcular diversos valores de variograma para diferentes distâncias $h$. Essa informação é sumarizada graficamente a partir do **variograma experimental** (Figura 02).

Cada ponto do variograma experimental representa a média das diferenças quadráticas entre pares de amostras separados por uma distância $h$. Quanto maior é o número de pares de amostras, maior é a altura das barras e mais representativo é o valor de $\gamma(h)$ encontrado.

Note que, no variograma experimental, o valor de $\gamma$ é calculado apenas para um número limitado de distâncias $h$. Para fins de visualização, é comum unir os pontos do variograma experimental por segmentos de reta. Clique na caixa abaixo, caso queira unir os pontos do gráfico.

> ⚠️ Ainda que a ligação dos pontos seja um recurso comum na maioria dos softwares geoestatísticos, devemos lembrar que o variograma experimental é discreto, ou seja, a partir dele, sabemos apenas alguns valores de $\gamma$ para $h$ específicos.

"""

# ╔═╡ 4b12eecc-0645-4f46-b3be-8b8a095af599
begin
	# importação de dados de uma imagem
	image = geostatsimage("Gaussian30x10")

	# cálculo do variograma experimental
	γ₁ = EmpiricalVariogram(image, :Z, maxlag=60., nlags = 6)
end;

# ╔═╡ b23b047e-1c02-40c5-ba88-825da85ba75c
md"""

Unir pontos do variograma: $(@bind join_points CheckBox())

"""

# ╔═╡ 8cfef844-5e4d-44c8-817c-0021eecbcaa2
# Ploting experimental variogram
plot(γ₁, legend = false, ylims = (0,1.0), xlims = (0,60),
	 color = :orange, line = join_points)

# ╔═╡ 528f0bb5-4030-4006-a323-29f9cbc1efc0
md"""
**Figura 02:** Exemplo de variograma experimental.
"""

# ╔═╡ 5e623ea7-03f9-46a9-ba54-6d48d1a64057
md"""
Os valores $\gamma(h)$ podem ser entendidos como uma medida de **variabilidade espacial** entre pares de amostras. Nesse sentido, é intuitivo pensar que, quanto maior é a distância $h$ entre duas amostras, mais diferentes são os seus respectivos teores. Esse padrão pode ser observado na Figura 01 e é típico dos variogramas experimentais.
"""

# ╔═╡ 4b136ca1-f46f-43dc-9a1d-0659f1ef5e61
md""" ### Parâmetros para cálculo do variograma experimental

Para calcular variogramas experimentais, devemos definir alguns parâmetros:

- Direção;
- Tamanho do passo;
- Tolerância do passo;
- Largura da banda.

> ⚠️ Um outro parâmetro frequentemente utilizado em softwares geoestatísticos é a *tolerância angular*. Como o GeoStats.jl não adota esse parâmetro, ele não será abordado neste módulo. Caso deseje saber mais sobre a tolerância angular, confira *Deutsch (2015)* ou [este notebook](https://github.com/fnaghetini/Variograms).
"""

# ╔═╡ c782a92c-cc4d-44bc-8521-2f70ad222bd5
md"""
#### Direção

Processos naturais não levam a distribuições espaciais isotrópicas. Normalmente, há um plano de maior continuidade (e.g. estrato ou zona de cisalhamento mineralizada) e uma direção de menor continuidade perpendicular a esse plano. Portanto, em contextos 3D, devemos encontrar as três direções principais de um fenômeno (ortogonais entre si) que descrevem a sua continuidade (*Deutsch, 2015*). Essas direções são chamadas de *primária*, *secundária* e *terciária* e definem um **elipsoide de anisotropia**.

Por outro lado, em contextos 2D, precisamos encontrar apenas as duas direções principais (também ortogonais entre si) que descrevem a continuidade espacial do fenômeno. Essas direções, denominadas *primária* e *secundária* definem uma **elipse de anisotropia**.

> ⚠️ Em contextos 2D, a direção é definida apenas pelo azimute, enquanto que, em contextos 3D, a direção é definida pelo azimute e ângulo de mergulho.

Variogramas experimentais calculados ao longo de uma direção específica são chamados de **variogramas direcionais**. Nesse caso, os pares de amostras utilizados para calcular os valores de $\gamma(h)$ devem estar alinhados ao longo da direção de cálculo. Por exemplo, se estamos calculando um variograma experimental na direção 170°, apenas os pares de amostras orientados a 170° (ou a 350°) entre si são selecionados.  
"""

# ╔═╡ 81dc06f6-79a0-4022-9219-c0ae97a20ab6
md"""
> ###### Função `sph2cart`
> Em geral, geólogos (principal público-alvo deste material) não estão muito acostumados a informar orientações em coordenadas cartesianas. Por exemplo, levaria um tempo para você descobrir que o azimute de 045° é representado como ($\frac{\sqrt2}{2}$, $\frac{\sqrt2}{2}$) em coordenadas cartesianas. Como no GeoStats.jl devemos informar orientações em coordenadas cartesianas, iremos criar uma função `sph2cart` que converte azimutes em coordenadas cartesianas. Por exemplo, ao invés de informarmos a direção de cálculo como ($\frac{\sqrt2}{2}$, $\frac{\sqrt2}{2}$), podemos simplesmente escrever `sph2cart(45)`.
"""

# ╔═╡ d4775d05-4943-4493-897e-4340f01475be
function sph2cart(azi)
	θ = deg2rad(azi)
	sin(θ), cos(θ)
end

# ╔═╡ 73cded81-c93e-4609-80ae-ca1dfcb79ec7
md"""
Na Figura 03, temos um exemplo de variograma direcional. Utilize o slider abaixo para alterar a direção de cálculo do variograma experimental. Note que o variograma calculado para o azimute 000° é idêntico àquele calculado para a direção 180°.
"""

# ╔═╡ 43bc79ba-bb97-48bd-a8e4-c478bdc3a60b
md"""
Azimute: $(@bind azm Slider(0:45:180, default=0, show_value = true))°
"""

# ╔═╡ 3f39dcf2-055e-4aa8-8caa-09223175a5fa
begin
	# variograma direcional
    γ₂ = DirectionalVariogram(sph2cart(azm), geowl, :Pb,
                              maxlag = 200, nlags = 7)
	
	# plotagem do variograma direcional
	plot(γ₂, legend = false, xlims = (0,200), ylims = (0,15),
		 title = "$(azm)°", color = :orange)
end

# ╔═╡ facdf937-4056-4699-b505-d9cada0c8ce3
md"""
**Figura 03:** Exemplo de variograma direcional.
"""

# ╔═╡ 5cb62b37-fe28-4816-b7ed-f5f40df255dc
md"""

#### Tamanho do passo

O **tamanho do passo**, também chamado de *lag*, é a distância média entre as amostras vizinhas na direção em que o variograma experimental está sendo calculado (*Deutsch, 2015*).

Na Figura 04, tem-se um exemplo de busca de pares de amostras na direção W-E (indicado pela seta vermelha) em uma malha regular. Utilize o slider `Passo` para aumentar o tamanho do passo e os sliders `W-E` e `N-S` para modificar a posição inicial e final do vetor $h$.
"""

# ╔═╡ f4e189ac-5d12-4de5-80e1-516103e5950f
md"""
W-E: $(@bind ix₁ Slider(1:1:4, default=1))
N-S: $(@bind iy₁ Slider(1:1:5, default=1))

Passo: $(@bind h Slider(1:1:3, default=1, show_value = true)) m
"""

# ╔═╡ c3135efd-e69c-4270-8b45-b3f9f2dd586c
begin
	# semente aleatória
	Random.seed!(42)
	
	# geração de amostras aleatórias
	values₁ = DataFrame(Au = rand(25))
	coords₁ = PointSet([(i,j) for i in 1:5 for j in 1:5])
	
	# amostras georreferenciadas
	samples₁ = georef(values₁, coords₁)

	# plotagem de amostras
	plot(samples₁, xlims = (0,6), ylims = (0,6), title = "Au (g/t)",
		 xlabel = "X(m)", ylabel = "Y(m)", clims = (0,1))
	
	# plotagem do vetor h
	plot!([(ix₁,iy₁),(ix₁+h,iy₁)], arrow = true, color = :red, lw = 2)
end

# ╔═╡ 8923e1c1-914d-47b5-a4b4-5f0c53c4e810
md"""
**Figura 04:** Exemplo de busca de pares de amostras em uma malha regular. A seta vermelha indica o vetor $h$.
"""

# ╔═╡ 3d25e2bc-9a6d-4712-92ed-de31dbdea3f2
md"""
#### Tolerância do passo

Sabe-se que, na maioria dos casos, as malhas de sondagem são irregulares. Nesse caso, poucos pares de pontos serão buscados, já que as amostras não se encontram equidistantes entre si.

A Figura 05 mostra um exemplo de malha irregular. Tente utilizar o slider `Passo` para encontrar o tamanho de passo ideal para a malha. Você perceberá que, independentemente do tamanho escolhido, pouquíssimas amostras serão buscadas...
"""

# ╔═╡ 874544a1-07af-4509-a34d-68d77558aaae
md"""
W-E: $(@bind ix₂ Slider(0.0:0.001:1.0, default=0.015))
N-S: $(@bind iy₂ Slider(0.0:0.001:1.0, default=0.172))

Passo: $(@bind lag_size Slider(0.05:0.05:1.0, default=0.3,
										  show_value = true)) m
"""

# ╔═╡ 2965ea0b-9b5e-4460-a735-e555733b2d83
begin
	# semente aleatóia
	Random.seed!(42)
	
	# amostras georreferenciadas
	table₂ = georef(values₁, PointSet(rand(2,25)))
	
	# plotagem das amostras
	plot(table₂, xlims = (-0.2,1.2), ylims = (-0.2,1.2), title = "Au (g/t)",
		 xlabel = "X(m)", ylabel = "Y(m)", clims = (0,1))
	
	# plotagem do vetor h
	plot!([(ix₂,iy₂),(ix₂+lag_size,iy₂)], arrow = true, color = :red, lw = 2)
end

# ╔═╡ 9d60b923-72e7-42c8-8ef3-d4a590e3f600
md"""
**Figura 05:** Exemplo de busca de pares de amostras em uma malha irregular.
"""

# ╔═╡ 7c00b7a2-5c09-46f5-ba8d-03786fd606b8
md"""

Uma alternativa comumente utilizada é a definição de uma **tolerância de passo** para que mais amostras sejam buscadas.

A tolerância do passo é normalmente definida como metade do tamanho do passo *(Deutsch, 2015)*:

```math
lagtol = \frac{lag}{2} 
```

Se houver poucos dados, uma tolerância maior pode ser necessária, o que pode resultar intervalos de tolerância sobrepostos e um variograma mais estável. Por outro lado, em caso de malhas densas ou aproximadamente regulares, uma tolerância de passo menor pode ser adotada *(Deutsch, 2015)*.

A Figura 06 apresenta amostras colineares de uma malha amostral irregular. Utilize o slider `W-E` para transladar o vetor $h$ e marque a caixa para visualizar a tolerância do passo.

Note que, quando a tolerância de passo é adotada, todos os pontos inseridos entre as linhas tracejadas podem ser buscados. Por outro lado, caso essa tolerância não fosse adotada, apenas um par de pontos seria buscado para o cálculo do variograma.
"""

# ╔═╡ 841ffdd2-16b4-4c19-8f03-70942a4ebb2e
md"""
W-E: $(@bind ix₃ Slider(1.:0.1:2.8, default=1))

Tolerância de passo: $(@bind lag_tol CheckBox())
"""

# ╔═╡ f738e56e-7725-4d52-a700-960ce372f025
begin
	# semente aleatória
	Random.seed!(42)
	
	# geração de amostras aleatórias
	coords₃ = [(1.,1.),(1.6,1.),(1.9,1.),(2.2,1.),(2.8,1.),(3.6,1.),(3.8,1.)]
	values₃ = DataFrame(Au = rand(7))
	
	# amostras georreferenciadas
	samples₃ = georef(values₃, coords₃)
	
	if lag_tol
		# plotagem de amostras
		plot(samples₃, xlims = (0.,4.5), ylims = (0,2), colorbar_title="Au (g/t)",
			 title="", xlabel = "X(m)", ylabel = "Y(m)", clims = (0,1))
		
		# plotagem do vetor h
		plot!([(ix₃,1.),(ix₃+1,1.)], arrow = true, color = :red, lw = 2)

		# plotagem da linha tracejada lag - ½ lag
		vline!([ix₃ + 0.5], color = :gray, ls = :dash)
		annotate!(ix₃ + 0.5, 2.1, text("lag - ½ lag", 7, :gray))

		# plotagem da linha contínua lag
		vline!([ix₃+1], color = :red)
		annotate!(ix₃+1, 2.1, text("lag", 7, :red))

		# plotagem da linha tracejada lag + ½ lag
		vline!([ix₃ + 1.5], color = :gray, ls = :dash)
		annotate!(ix₃ + 1.5, 2.1, text("lag + ½ lag", 7, :gray))
		
	else
		# plotagem de amostras
		plot(samples₃, xlims = (0.,4.5), ylims = (0,2), colorbar_title="Au (g/t)",
			 title="", xlabel = "X(m)", ylabel = "Y(m)", clims = (0,1))

		# plotagem do vetor h
		plot!([(ix₃,1.),(ix₃+1,1.)], arrow = true, color = :red, lw = 2)

		# plotagem da linha contínua lag
		vline!([ix₃+1], color = :red)
		annotate!(ix₃+1, 2.1, text("lag", 7, :red))
	end
end

# ╔═╡ 650fc66a-3f8e-45d5-a898-5c783a8d12a1
md"""
**Figura 06:** Exemplo de busca de amostras colineares irregulares. Marque a caixa para visualizar a tolerância do passo.
"""

# ╔═╡ 5e555810-f34d-402c-ac0a-17a423f420bc
md"""
#### Largura da banda

A **largura da banda** é um parâmetro de tolerância que pode ser utilizado para limitar a busca de pares de amostras indesejados (*Deutsch, 2015*). A Figura 07 mostra a largura da banda (seta dupla preta), bem como os demais parâmetros para o cálculo do variograma experimental.
"""

# ╔═╡ 6433f0dc-04f8-450e-9a94-f8cfa8cda552
md"""
![bandwidth](https://i.postimg.cc/vHmM45Qh/bandwidth.png)
**Figura 07:** Parâmetros utilizados para o cálculo do variograma experimental. A origem do gráfico pode ser entendida como o centro de uma amostra e os "alvos" como as demais amostras. 
"""

# ╔═╡ e80e5e16-59fb-4ec0-a9f0-6b8b97bc8d36
md"""

## 4. Modelos teóricos

A partir dos variogramas experimentais só é possível obter valores médios de variograma $γ(h)$ para distâncias iguais a múltiplos do tamanho de passo $h$ escolhido.

Portanto, é necessário o ajuste de um *modelo matemático contínuo*, de modo que saberemos o valor de $\gamma$ para qualquer distância entre pares de amostras $h$.

O procedimento de se ajustar um modelo teórico contínuo ao variograma experimental é denominado **modelagem do variograma**. Clique na caixa abaixo para ajustar um modelo teórico ao variograma experimental da Figura 08...

"""

# ╔═╡ 9891913d-e735-4ec8-b09c-49b51417f18d
# ajuste teórico do variograma
varmod = fit(GaussianVariogram, γ₁);

# ╔═╡ 52c19e93-8534-4b59-a164-3f12d23d5440
md"""
Ajuste do modelo: $(@bind fit_model CheckBox())
"""

# ╔═╡ 7a8a49a2-007e-409a-9a45-c76f717f75f8
begin
	if fit_model
		# plotagem do variograma experimental
		plot(γ₁, marker=(4,:orange), line=false, ylims=(0,1.0),
			 xlims=(0,50), legend=false)
	
		# plotagem do ajuste teórico (modelo)
		plot!(varmod, ylims=(0,1.0), color=:black, xlims=(0,50),
			  label="Ajuste Teórico", legend=false)

	else
		# plotagem do variograma experimental
		plot(γ₁, marker=(4,:orange), line=false, ylims=(0,1.0),
			 xlims=(0,50), legend=false)
	end
end	

# ╔═╡ f92eedbf-097d-45f6-a550-ccc8c2f9841b
md"""
**Figura 08:** Exemplo de ajuste de um modelo teórico a um variograma experimental.
"""

# ╔═╡ 83593f8e-8dd2-40b1-903b-8712bb9eb048
md"""
### Tipos de modelo

Nem todas as funções matemáticas podem ser utilizadas para ajustar variogramas experimentais. Essas funções devem ser *positivas definidas*, ou seja, quando $f(0) = 0$ e $f(x)>0, \forall x\neq0$. Essa condição deve ser satisfeita para que a a variância de krigagem seja positiva (*Sinclair & Blackwell, 2006*).

Embora existam cerca de uma dúzia de modelos de variogramas teóricos, três deles explicam a grande maioria dos fenômenos espaciais (*Yamamoto & Landim, 2015*):
- Modelo Gaussiano
- Modelo Esférico
- Modelo Exponencial
"""

# ╔═╡ a6802bda-7b7a-4d98-bb08-bcbe8a990e01
md"""
O **modelo gaussiano** apresenta comportamento próximo à origem parabólico e é normalmente utilizado para ajustar variogramas experimentais de fenômenos de baixa heterogeneidade. Sua equação é dada por:

``` math
γ(h) = C_0 + C \left[ 1 - exp \left[- \left(\frac{h}{a} \right)^2 \right]  \right] 
```

O **modelo esférico** apresenta comportamento próximo à origem linear e é normalmente utilizado para ajustar variogramas experimentais de fenômenos de intermediária heterogeneidade. Esse é a função teórica mais comum para modelar a continuidade espacial de teores metalíferos. Sua equação é descrita como:

``` math
γ(h) = C_0 + C \left[\frac{3h}{2a} - \frac{1}{2}\left(\frac{h}{a}\right)^3 \right], ∀ h < a
```

``` math
γ(h) = C_0 + C, ∀ h ≥ a
```

O **modelo exponencial** apresenta comportamento próximo à origem linear. Entretanto, a inclinação desse modelo nas proximidades da origem é maior do que a inclinação do modelo esférico. Esse tipo de modelo teórico é normalmente utilizado para ajustar variogramas experimentais de fenômenos de elevada heterogeneidade. Sua equação é definida como:

``` math
γ(h) = C_0 + C \left[1 - exp \left[-\left(\frac{h}{a} \right) \right] \right]
```

Selecione, na lista suspensa abaixo, o tipo de modelo de variograma que deseja visualizar (Figura 09). Tente observar a diferença do comportamento próximo à origem entre os três ajustes teóricos...
"""

# ╔═╡ 6d0f5d99-f7e2-4f53-b835-c3b345613e4a
md"""
Modelo Teórico: $(@bind model Select(["Gaussiano","Esférico","Exponencial"],
				  default = "Gaussiano"))
"""

# ╔═╡ 341ec3f6-c871-431f-8ffa-85f4c43ae138
# modelo gaussiano
if model == "Gaussiano"
	γ₃ = GaussianVariogram(nugget=0., sill=1., range=10.)

# modelo esférico
elseif model == "Esférico"
	γ₃ = SphericalVariogram(nugget=0., sill=1., range=10.)

# modelo exponencial
else
	γ₃ = ExponentialVariogram(nugget=0., sill=1., range=10.)
end;

# ╔═╡ 61b8631b-8295-4dea-a5dd-189bf578bc8c
begin
	# plotagem do modelo de variograma
	plot(γ₃, color = :black, lw = 2, label = model,
		 legend = :topleft, ylims = (0.,1.5), xlims = (0.,25.))
end

# ╔═╡ ab5e6c19-789b-4944-ba8e-f983a9a2652c
md"""
**Figura 09:** Tipos de modelo do variograma.
"""

# ╔═╡ 8b4ee7b2-2a01-44ae-8539-27f1815fe634
md"""

## 5. Tipos de anisotropia

Na modelagem de variogramas, a anisotropia existe quando um ou mais elementos do variograma variam com a mudança da direção. Existem três tipos (*Yamamoto & Landim, 2015*):
- *Anisotropia Zonal*: patamar varia de acordo com a mudança de direção.
- *Anisotropia Geométrica*: alcance varia de acordo com a mudança de direção.
- *Anisotropia Mista*: patamar e alcance variam de acordo com a mudança de direção.

> ⚠️ Embora existam três tipos de anisotropia, é comum considerar apenas a anisotropia geométrica para a modelagem do variograma.

> ⚠️ Não existe anisotropia de efeito pepita, uma vez que esse elemento é, por definição, isotópico.

A partir da lista suspensa abaixo, compare os diferentes tipos de anisotropia (Figura 10)...
"""

# ╔═╡ 83d6c4fe-bcd6-4d7f-93ef-2e093b1284fa
md"""

Tipo de anisotropia: $(@bind aniso Select(["Zonal","Geométrica","Mista"],
										  default = "Geométrica"))

"""

# ╔═╡ 187c01ca-053e-4994-a748-cf9b16683a50
# anisotropia zonal
if aniso == "Zonal"
	γ_aniso₁ = SphericalVariogram(nugget = 0.1, range = 50.0, sill = 1.0)
	γ_aniso₂ = SphericalVariogram(nugget = 0.1, range = 50.0, sill = 1.2)

# anisotropia geométrica
elseif aniso == "Geométrica"
	γ_aniso₁ = SphericalVariogram(nugget = 0.1, range = 50.0, sill = 1.0)
	γ_aniso₂ = SphericalVariogram(nugget = 0.1, range = 30.0, sill = 1.0)

# anisotropia mista
else
	γ_aniso₁ = SphericalVariogram(nugget = 0.1, range = 50.0, sill = 1.2)
	γ_aniso₂ = SphericalVariogram(nugget = 0.1, range = 30.0, sill = 1.0)

end;

# ╔═╡ b9634a1e-f225-4986-867f-fd36f56882df
begin
	# plotagem do modelo de variograma vermelho
	plot(γ_aniso₁, color = :red, lw = 2, legend = false,
		 title = "Anisotropia $aniso")
	
	# plotagem do modelo de variograma azul
	plot!(γ_aniso₂, color = :blue, lw = 2, xlims = (0,80), ylims = (0,1.5))
end

# ╔═╡ ee09dcab-2298-444c-ad9f-f79268c9056c
md"""
**Figura 10:** Tipos de anisotropia.
"""

# ╔═╡ 0f28a997-4945-47fe-83b9-058726bc8041
md"""

## 6. Estruturas imbricadas

Em muitos casos não é possível ajustar de maneira adequada um variograma experimental por meio um modelo teórico simples. Esse tipo de situação ocorre quando há mais de uma estrutura nos dados em questão (i.e. a regionalização está presente em diferentes escalas) (*Sinclair & Blackwell, 2006*). Dessa forma, podemos utilizar o imbricamento/aninhamento de estruturas, com o intuito de tornar a modelagem do variograma mais flexível. 

A **estrutura do variograma** é a porção da equação do ajuste teórico em que o valor de $C$ cresce com o aumento da distância $h$:

``` math
γ(h) = C_0 +
\underbrace{C \left[\frac{3h}{2a} - \frac{1}{2}\left(\frac{h}{a}\right)^3 \right]}_\text{estrutura do variograma}
```

> ⚠️ O efeito pepita $C_0$ não pertence à estrutura do variograma.

O **imbricamento/aninhamento das estruturas** é definido como a soma de $n$ estruturas do variograma. A equação abaixo ilustra um imbricamento de $n$ estruturas para um modelo esférico:

``` math
γ(h) = C_0 +
\underbrace{C_1 \left[\frac{3h}{2a_1} - \frac{1}{2}\left(\frac{h}{a_1}\right)^3 \right]}_\text{1ª estrutura} +
\underbrace{C_2 \left[\frac{3h}{2a_2} - \frac{1}{2}\left(\frac{h}{a_2}\right)^3 \right]}_\text{2ª estrutura} + ... +
\underbrace{C_n \left[\frac{3h}{2a_n} - \frac{1}{2}\left(\frac{h}{a_n}\right)^3 \right]}_\text{n-ésima estrutura}
```

No caso de variogramas imbricados, o patamar ($C$) consiste na soma entre todas as contribuições ao patamar e o efeito pepita:

```math
C = C_0 + C_1 + C_2 + ... + C_n
```

> ⚠️ Normalmente, utiliza-se, no máximo, três estruturas imbricadas em um modelo de variograma.

A Figura 11 mostra um exemplo de modelo de variograma imbricado...
"""

# ╔═╡ 750d0cc4-d117-48be-869a-234acfe0c6d4
md"""
#### 🖊️ Exercício

Utilize os sliders abaixo para modelar o variograma experimental. Note o modelo de variograma é constituído por estruturas aninhadas.
"""

# ╔═╡ f95ffa70-f924-404a-8cec-fc281b8588e2
md"""
Efeito pepita: $(@bind nested_cₒ Slider(0.00:0.1:4.0,
										default=0.0, show_value=true))

Contrib. 1ª estrutura: $(@bind nested_c₁ Slider(0.0:0.1:10.0,
													default=2.6, show_value=true))

Contrib. 2ª estrutura: $(@bind nested_c₂ Slider(0.0:0.1:10.0,
													default=4.1, show_value=true))

Alcance 1ª estrutura: $(@bind nested_r₁ Slider(10.0:1.0:156.0, default=77.0, show_value=true)) m

Alcance 2ª estrutura: $(@bind nested_r₂ Slider(10.0:1.0:156.0, default=126.0, show_value=true)) m
"""

# ╔═╡ 3f0465bc-444c-4026-a677-a182366790ae
begin
	# ef. pepita
	γ_nested₀ = NuggetEffect(Float64(nested_cₒ))
	
	# 1ª estrutura
    γ_nested₁ = SphericalVariogram(sill = Float64(nested_c₁),
								   range = Float64(nested_r₁))

	# 2ª estrutura
    γ_nested₂ = SphericalVariogram(sill = Float64(nested_c₂),
								   range = Float64(nested_r₂))

	# modelo aninhado
    γ_nested  = γ_nested₀ + γ_nested₁ + γ_nested₂
	
	# plotagem do variograma experimental
	plot(γ₂, color = :orange, legend = false, line = false)
	
	# plotagem do modelo aninhado
	plot!(γ_nested, color = :black, lw = 2, xlims = (0,220), ylims = (0,15))
	
	# plotagem do alcance
	vline!([nested_r₂], color = :gray, ls = :dash)
end

# ╔═╡ 864c9c06-e52b-4de8-bc16-d053fa3c0346
md"""
**Figura 11:** Exemplo de modelo de variograma imbricado.
"""

# ╔═╡ 538bf67b-33c6-45c3-b5bf-328922debb26
md"""
## 7. Variograma anisotrópico

Como a continuidade espacial de fenômenos naturais tende a ser anisotrópica e o objetivo da variografia é justamente descrever a continuidade espacial desses fenômenos, é plausível que o variograma seja anisotrópico.

Como dito no início do módulo, a forma mais simples e coerente para se representar anisotropia é por meios de elipses (2D) ou elipsoides (3D).

Em um contexto 3D, assumindo condições de *anisotropia geométrica*, para representar a continuidade espacial de um fenômeno, basta encontrarmos os eixos principais do elipsoide, de modo que:
- O efeito pepita será isotrópico.
- O patamar será assumido como isotrópico.
- O alcance será anisotrópico.

Portanto, os eixos do elipsoide representam justamente a variação do alcance para diferentes direções.

A equação de um **modelo esférico anisotrópico** é descrita como:

``` math
γ(h) = C_0 + C \left[\frac{3h}{2(a_x,a_y,a_z)} - \frac{1}{2}\left(\frac{h}{(a_x,a_y,a_z)}\right)^3 \right]
```

A Figura 12 ilustra graficamente um exemplo de modelo de variograma anisotrópico. Utilize os sliders abaixo para alterar os alcances primário (Y), secundário (X) e terciário (Z)...
"""

# ╔═╡ 18282939-e7ef-4da4-aade-72e7b01886de
md"""
Alcance em Y: $(@bind range_y Slider(10.0:2.0:120.0, default=99.0, show_value=true)) m

Alcance em X: $(@bind range_x Slider(10.0:2.0:120.0, default=66.0, show_value=true)) m

Alcance em Z: $(@bind range_z Slider(10.0:2.0:120.0, default=26.0, show_value=true)) m
"""

# ╔═╡ dc47965d-e732-44e4-875c-b4922ff4bd1f
begin
	# modelo de variograma primário
	γ_1st = SphericalVariogram(nugget = 0.1, range = Float64(range_y), sill = 5.0)
	
	# modelo de variograma secundário
	γ_2nd = SphericalVariogram(nugget = 0.1, range = Float64(range_x), sill = 5.0)
	
	# modelo de variograma terciário
	γ_3rd = SphericalVariogram(nugget = 0.1, range = Float64(range_z), sill = 5.0)
end;

# ╔═╡ b2ea2e47-4fa5-4d17-8341-889069a717c7
begin
	# plotagem do modelo de variograma primário
	plot(γ_1st, color = :red, lw = 2, label = "Primário",)
	
	# plotagem do modelo de variograma secundário
	plot!(γ_2nd, color = :green, lw = 2, label = "Secundário")
	
	# plotagem do modelo de variograma terciário
	plot!(γ_3rd, color = :blue, lw = 2, label = "Terciário",
		  xlims = (0,120), ylims = (0,8))
end

# ╔═╡ 7e05a32f-44ba-45ec-8db2-6d23a966a298
md"""
**Figura 13:** Exemplo de modelo de variograma anisotrópico.
"""

# ╔═╡ ad8ca8f4-fc43-4008-8d94-eae74c84010a
md"""
Considerando um fenômeno anisotrópico, ao final da variografia, teremos em mãos um modelo de variograma que pode ser sumarizado em uma estrutura tabular, como a tabela apresentada abaixo. No exemplo a seguir, apenas uma estrutura foi considerada. Caso tivéssemos duas estruturas, por exemplo, uma nova linha seria adicionada.
"""

# ╔═╡ d6a4e6dd-7ace-4406-be57-804b4c2537e5
md"""
| Estrutura |Ef. Pepita | Alcance em X | Alcance em Y | Alcance em Z | Variância |
|:---------:|:---------:|:------------:|:------------:|:------------:|:---------:|
|     0     |    0.01   |       -      |       -      |       -      |     -     |
|     1     |     -     | $(range_x) m | $(range_y) m | $(range_z) m |    5.0    |

"""

# ╔═╡ 6feb0cb4-7bff-4635-ae38-4400affe89f3
md"""
## 8. Modelo de variograma x estimativas

Sabe-se que o modelo de variograma é utilizado como entrada na estimativa por krigagem. Nesse sentido, cada um de seus parâmetros e elementos exerce uma influência no modelo de teores estimados:

- A *direção* indica a orientação da continuidade espacial de teores;

- O *alcance* controla o comprimento de continuidade espacial médio ("elipses" na imagem);

- O *patamar* define a "altura" das "elipses";

- O *efeito pepita* define uma variabilidade adicional para escalas menores;

- O *modelo teórico* define o comportamento próximo a origem.

O exemplo abaixo auxilia na compreensão da influência de cada um desses parâmetros nas estimativas resultantes. A Figura 13 mostra o modelo de variograma anisotrópico utilizado na estimativa por krigagem. A Figura 14 representa o mapa da localização das amostras.

Utilize os sliders abaixo para ajustar os variogramas experimentais azul e vermelho. Em seguida, clique na caixa para visualizar as estimativas. Faça o exercício de analisar qual é o impacto de cada parâmetro do variograma nas estimativas resultantes.
"""

# ╔═╡ 8079a74c-005d-4654-8e44-d763a12aefd8
md"""
Direção de maior continuidade: $(@bind azi₂ Slider(0.0:45.0:90.0, default=0.0, show_value=true))°

Modelo Teórico: $(@bind m Select(["Gaussiano","Esférico","Exponencial"],
							 default = "Esférico"))

Efeito pepita: $(@bind Cₒ Slider(0.00:0.1:5.0, default=3.0, show_value=true))

Alcance primário (Y): $(@bind ry Slider(10.0:1.0:156.0, default=101.0, show_value=true)) m

Alcance secundário (X): $(@bind rx Slider(10.0:1.0:156.0, default=32.0, show_value=true)) m
"""

# ╔═╡ 39e7cb17-7813-4103-880d-64803c636039
begin
	# tipo do modelo
	model_type = Dict("Gaussiano" => GaussianVariogram,
					  "Esférico" => SphericalVariogram,
					  "Exponencial" => ExponentialVariogram)
	
	# variância amostral (definindo o patamar)
	σ² = var(geowl[:Pb])
	
	# cálculo do variograma experimental primário
	γexp_pri = DirectionalVariogram(sph2cart(azi₂), geowl, :Pb,
                                    maxlag = 200, nlags = 5)
	
	# cálculo do variograma experimental secundário
	γexp_sec = DirectionalVariogram(sph2cart(azi₂+90), geowl, :Pb,
                                    maxlag = 200, nlags = 5)
	
	# modelo do variograma primário
	γm_pri = model_type[m](nugget = Float64(Cₒ),
						   sill = Float64(σ²),
						   range = Float64(ry))
	
	# modelo do variograma secundário 
	γm_sec = model_type[m](nugget = Float64(Cₒ),
						   sill = Float64(σ²),
						   range = Float64(rx))
end;

# ╔═╡ 308abd53-d536-4ff0-8e1d-9ac118742d93
begin
	# parâmetros gráficos
	col_pri = :red
	col_sec = :blue
	xlim    = (0,200)
	ylim    = (0,15)
	
	# plotagem do variograma experimental primário
	plot(γexp_pri, color = col_pri, label = false)
	
	# plotagem do variograma experimental secundário
	plot!(γexp_sec, color = col_sec, label = false)
	
	# plotagem do modelo primário
	plot!(γm_pri, color = col_pri, lw = 2, legend = false)
	
	# plotagem do modelo secundário
	plot!(γm_sec, color = col_sec, lw = 2, xlims = xlim, ylims = ylim)
	
	# plotagem do patamar
	hline!([σ²], color = :gray, ls = :dash)
	
	# plotagem do alcance primário
	vline!([ry], color = col_pri, ls = :dash)
	
	# plotagem do alcance secundário
	vline!([rx], color = col_sec, ls = :dash)
end

# ╔═╡ a0b3b930-5f2a-47a1-bc81-c70c2ff595e6
md"""
**Figura 13:** Modelo de variograma anisotrópico utilizado na estimativa.
"""

# ╔═╡ fb99bba7-e81b-4653-a7dc-3558f6fc7e2c
md"""
Visualizar estimativas: $(@bind show_model CheckBox())
"""

# ╔═╡ cd5c821d-247e-4d18-93cf-065197b79f1b
begin
	if show_model
		# elipsoide de anisotropia
		ellip = Ellipsoid([ry,rx],[azi₂], convention = GSLIB)

		# modelo de variograma
		γ = model_type[m](nugget = Float64(Cₒ),
						  sill = Float64(σ²),
						  distance = metric(ellip))

		# domínio de estimativa
		dom = CartesianGrid((243,283),(8.,8.),(1.,1.))

		# definição do problema de estimativa
		problem = EstimationProblem(wl_georef, dom, :PB)

		# definição do estimador (OK)
		OK = Kriging(:PB => (variogram = γ,
						     neighborhood = ellip,
						     minneighbors = 8,
							 maxneighbors = 16)
				    )

		# solução da estimativa
		sol = solve(problem, OK)
		
		# manipulação das estimativas
		estimates = sol |> @map({PB = _.PB, geometry = _.geometry}) |> GeoData
	end
end;

# ╔═╡ c90bdb75-1918-4d57-93b1-6cda3e8fbb0c
begin
	if show_model
		# plotagem das estimativas		
		plot(estimates, color=:coolwarm, xlabel="X", ylabel="Y",
			 xlims=(5,255), ylims=(5,295),clims = (0,12),
			 marker=(:square,1.2), markerstrokewidth=0,
			 size=(500,500))
		
		# plotagem de amostras
		plot!(geowl, color=:coolwarm, marker=(:square,2),
			  markerstrokecolor=:black, markerstrokewidth=0.3,
		      title="Pb (%)")
		
	else
		# plotagem de amostras
		plot(geowl, color=:coolwarm, marker=(:square,2),
			 markerstrokecolor=:black, markerstrokewidth=0.3,
			 xlims=(5,255), ylims=(5,295),clims = (0,12),
			 size=(500,500),title="Pb (%)", xlabel="X", ylabel="Y")
		
	end
end

# ╔═╡ 2f1d77a0-e5cd-4d77-8031-cff161f67a45
md"""
**Figura 14:** Mapa de localização das amostras de Pb (%). Ative a caixa para visualizar as estimativas.
"""

# ╔═╡ d5de8d26-7e90-4615-bd3b-cdfd002f98b2
md"""
## Referências
*Camana, F.; Deutsch, C.V. [The nugget effect](https://geostatisticslessons.com/lessons/nuggeteffect). In: Geostatistics Lessons, 2019.*

*Deutsch, J. L. [Experimental variogram tolerance parameters](https://geostatisticslessons.com/lessons/variogramparameters). In: Geostatistics Lessons, 2015.*

*Hoffimann, J.; Zadrozny, B. [Efficient variography with partition variograms](https://www.researchgate.net/publication/333973794_Efficient_Variography_with_Partition_Variograms). Computers & Geosciences, 131, 2019. 52-59.*

*Isaaks, E. H.; Srivastava, M. R. [Applied geostatistics](https://www.google.com.br/books/edition/Applied_Geostatistics/gUXQzQEACAAJ?hl=pt-BR). New York: Oxford University Press, 1989.*

*Morgan, C. [Theoretical and practical aspects of variography](https://wiredspace.wits.ac.za/handle/10539/11193). Tese de Doutorado. University of Witwatersrand, 2011*

*Rossi, M. E.; Deutsch, C. V. [Mineral resource estimation](https://www.google.com.br/books/edition/Mineral_Resource_Estimation/gzK_BAAAQBAJ?hl=pt-BR&gbpv=0). New York: Springer Science & Business Media, 2013.*

*Samson, M.; Deutsch, C.V. [The sill of the variogram](https://geostatisticslessons.com/lessons/sillofvariogram). In: Geostatistics Lessons, 2021.*

*Sinclair, A. J.; Blackwell, G. H. [Applied mineral inventory estimation](https://www.google.com.br/books/edition/Applied_Mineral_Inventory_Estimation/oo7rCrFQJksC?hl=pt-BR&gbpv=0). New York: Cambridge University Press, 2006.*

*Sinclair, A. J.; Vallée, M. [Reviewing continuity: an essential element of quality control for deposit and reserve estimation](https://www.google.com.br/books/edition/Applied_Mineral_Inventory_Estimation/oo7rCrFQJksC?hl=pt-BR&gbpv=0). Exploration and Mining Geology, 3(2), 1994. 95-108.*

*Yamamoto, J. K.; Landim, P. M. B. [Geoestatística: conceitos e aplicações](https://www.google.com.br/books/edition/Geoestat%C3%ADstica/QUsrBwAAQBAJ?hl=pt-BR&gbpv=0). São Paulo: Oficina de textos, 2015.*
"""

# ╔═╡ 838f3147-299c-4e12-a4b0-a9f29d19f2d7
md"""
## Recursos adicionais

Abaixo, são listados alguns recursos complementares a este notebook:

> [Videoaula Continuidade Espacial - LPM/UFRGS](https://www.youtube.com/watch?v=uH6IwJEnOJI)

> [Videoaula "What the Heck is a Variogram?" - Prof. Edward Isaaks](https://www.youtube.com/watch?v=SJLDlasDLEU)

> [Videoaula Continuidade Espacial - University of Texas](https://www.youtube.com/watch?v=j0I5SGFm00c&list=PLG19vXLQHvSB-D4XKYieEku9GQMQyAzjJ)

> [Videoaula Introdução ao Variograma - University of Texas](https://www.youtube.com/watch?v=jVRLGOsnYuw&list=PLG19vXLQHvSB-D4XKYieEku9GQMQyAzjJ)

> [Videoaula Cálculo do Variograma - University of Texas](https://www.youtube.com/watch?v=mzPLicovE7Q&list=PLG19vXLQHvSB-D4XKYieEku9GQMQyAzjJ)

> [Videoaula Parâmetros do Variograma - University of Texas](https://www.youtube.com/watch?v=NE4xfhIHAm4&list=PLG19vXLQHvSB-D4XKYieEku9GQMQyAzjJ)

> [Videoaula Interpretação do Variograma - University of Texas](https://www.youtube.com/watch?v=Li-Xzlu7hvs&list=PLG19vXLQHvSB-D4XKYieEku9GQMQyAzjJ)

> [Videoaula Modelagem do Variograma - University of Texas](https://www.youtube.com/watch?v=-Bi63Y3u6TU&list=PLG19vXLQHvSB-D4XKYieEku9GQMQyAzjJ)
"""

# ╔═╡ b6cce048-8953-42de-88ad-3694038a5458
md"""
## Pacotes utilizados

Os seguintes pacotes foram utilizados neste notebook:

|                       Pacote                             |        Descrição        |
|:--------------------------------------------------------:|:-----------------------:|
|[GeoStats](https://github.com/JuliaEarth/GeoStats.jl)     | Rotinas geoestatísticas |
|[GeoStatsImages](https://github.com/JuliaEarth/GeoStatsImages.jl) | Imagens geoestatísticas clássicas   |
|[CSV](https://github.com/JuliaData/CSV.jl)                | Arquivos CSV            |
|[DataFrames](https://github.com/JuliaData/DataFrames.jl)  | Manipulação de tabelas  |
|[Query](https://github.com/queryverse/Query.jl)           | Realização de consultas |
|[Statistics](https://docs.julialang.org/en/v1/)           | Cálculo de estatísticas |
|[Random](https://docs.julialang.org/en/v1/)               | Números aleatórios      |
|[PlutoUI](https://github.com/fonsp/PlutoUI.jl)            | Widgets interativos     |
|[Plots](https://github.com/JuliaPlots/Plots.jl)           | Visualização dos dados  |

"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
GeoStats = "dcc97b0b-8ce5-5539-9008-bb190f959ef6"
GeoStatsImages = "7cd16168-b42c-5e7d-a585-4f59d326662d"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Query = "1a8c2f83-1ff3-5112-b086-8aa67b057ba1"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
CSV = "~0.9.8"
DataFrames = "~1.2.2"
GeoStats = "~0.27.0"
GeoStatsImages = "~0.6.0"
Plots = "~1.22.6"
PlutoUI = "~0.7.16"
Query = "~1.0.0"
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

[[ArrayInterface]]
deps = ["Compat", "IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "1d6835607e9f214cb4210310868f8cf07eb0facc"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.1.34"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[AverageShiftedHistograms]]
deps = ["LinearAlgebra", "RecipesBase", "Statistics", "StatsBase", "UnicodePlots"]
git-tree-sha1 = "8bdad2055f64dd71a25826d752e0222726f25f20"
uuid = "77b51b56-6f8f-5c3a-9cb4-d71f9594ea6e"
version = "0.8.7"

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
git-tree-sha1 = "29728b5bf89047611c189f412f3325fff993711b"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.9.8"

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
git-tree-sha1 = "d9e40e3e370ee56c5b57e0db651d8f92bce98fea"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.10.1"

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
git-tree-sha1 = "9809cf6871ca006d5a4669136c09e77ba08bf51a"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.20"

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

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "3c041d2ac0a52a12a27af2782b34900d9c3ee68c"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.11.1"

[[FilePathsBase]]
deps = ["Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "7fb0eaac190a7a68a56d2407a6beff1142daf844"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.12"

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
git-tree-sha1 = "dba1e8614e98949abfa60480b13653813d8f0157"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+0"

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

[[GeoStatsImages]]
deps = ["FileIO", "GslibIO"]
git-tree-sha1 = "1e1c08019257940fd78e6aed4644299c143991f9"
uuid = "7cd16168-b42c-5e7d-a585-4f59d326662d"
version = "0.6.0"

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

[[GslibIO]]
deps = ["DelimitedFiles", "FileIO", "GeoStatsBase", "Meshes", "Printf", "Tables"]
git-tree-sha1 = "68fc1fcddb10f335ab9f859ef204a2bb0b3285a6"
uuid = "4610876b-9b01-57c8-9ad9-06315f1a66a5"
version = "0.7.8"

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
git-tree-sha1 = "f6532909bf3d40b308a0f360b6a0e626c0e263a8"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.1"

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
git-tree-sha1 = "8ade4401bd97b37987c3af9d204e3e3ca41a58a4"
uuid = "eacbb407-ea5a-433e-ab97-5258b1ca43fa"
version = "0.17.18"

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
git-tree-sha1 = "ba43b248a1f04a9667ca4a9f782321d9211aa68e"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.22.6"

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
git-tree-sha1 = "54f37736d8934a12a200edea2f9206b03bdf3159"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.7"

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
git-tree-sha1 = "2d57e14cd614083f132b6224874296287bfa3979"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.8.0"

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
git-tree-sha1 = "9ad7227369e19bfebe099267125067ddc7ddb459"
uuid = "04a0146e-e6df-5636-8d7f-62fa9eb0b20c"
version = "0.12.21"

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
# ╟─1991a290-cfbf-11eb-07b6-7b3c8543dd28
# ╟─f8909bd5-9167-42ea-a302-a7a50bdc365c
# ╟─3bd915e1-2f58-451c-a0fb-8aec6d6f75d9
# ╟─faa9d295-ae72-4912-bfca-925c4e7b9b35
# ╟─029c1951-054b-4f48-bc05-341250ce9f6a
# ╟─1e211855-33b8-429f-a4e1-b01e8ad88bab
# ╟─363b1ca8-1cb4-465d-89b3-a15570d5dc7f
# ╟─e1502221-f2ee-4f76-b442-f83dbf454743
# ╟─faee9091-89aa-46ff-9a90-42eb71dcdd6a
# ╟─12770ca7-be19-4b11-88b5-0b65a05cefd6
# ╠═57bf7106-7316-43f7-8578-f59f01f04b79
# ╟─51107168-29ca-40b1-a658-9361199be3b1
# ╟─ea67e941-496f-45a3-8b0f-058d573291d8
# ╟─03a46b21-c522-4036-a710-bd6ce0a26a1b
# ╟─3a03cb21-0dd0-488d-9950-92ee2ed8d697
# ╟─8519999f-2062-41b7-a8ae-4e190b2df860
# ╟─59c0673a-e117-4669-8156-6d3a8eb861e8
# ╟─0c00aee8-9db5-4fca-b92d-e19aa4fe5c1b
# ╟─4b12eecc-0645-4f46-b3be-8b8a095af599
# ╟─b23b047e-1c02-40c5-ba88-825da85ba75c
# ╟─8cfef844-5e4d-44c8-817c-0021eecbcaa2
# ╟─528f0bb5-4030-4006-a323-29f9cbc1efc0
# ╟─5e623ea7-03f9-46a9-ba54-6d48d1a64057
# ╟─4b136ca1-f46f-43dc-9a1d-0659f1ef5e61
# ╟─c782a92c-cc4d-44bc-8521-2f70ad222bd5
# ╟─81dc06f6-79a0-4022-9219-c0ae97a20ab6
# ╠═d4775d05-4943-4493-897e-4340f01475be
# ╟─73cded81-c93e-4609-80ae-ca1dfcb79ec7
# ╟─43bc79ba-bb97-48bd-a8e4-c478bdc3a60b
# ╟─3f39dcf2-055e-4aa8-8caa-09223175a5fa
# ╟─facdf937-4056-4699-b505-d9cada0c8ce3
# ╟─5cb62b37-fe28-4816-b7ed-f5f40df255dc
# ╟─f4e189ac-5d12-4de5-80e1-516103e5950f
# ╟─c3135efd-e69c-4270-8b45-b3f9f2dd586c
# ╟─8923e1c1-914d-47b5-a4b4-5f0c53c4e810
# ╟─3d25e2bc-9a6d-4712-92ed-de31dbdea3f2
# ╟─874544a1-07af-4509-a34d-68d77558aaae
# ╟─2965ea0b-9b5e-4460-a735-e555733b2d83
# ╟─9d60b923-72e7-42c8-8ef3-d4a590e3f600
# ╟─7c00b7a2-5c09-46f5-ba8d-03786fd606b8
# ╟─841ffdd2-16b4-4c19-8f03-70942a4ebb2e
# ╟─f738e56e-7725-4d52-a700-960ce372f025
# ╟─650fc66a-3f8e-45d5-a898-5c783a8d12a1
# ╟─5e555810-f34d-402c-ac0a-17a423f420bc
# ╟─6433f0dc-04f8-450e-9a94-f8cfa8cda552
# ╟─e80e5e16-59fb-4ec0-a9f0-6b8b97bc8d36
# ╟─9891913d-e735-4ec8-b09c-49b51417f18d
# ╟─52c19e93-8534-4b59-a164-3f12d23d5440
# ╟─7a8a49a2-007e-409a-9a45-c76f717f75f8
# ╟─f92eedbf-097d-45f6-a550-ccc8c2f9841b
# ╟─83593f8e-8dd2-40b1-903b-8712bb9eb048
# ╟─a6802bda-7b7a-4d98-bb08-bcbe8a990e01
# ╟─341ec3f6-c871-431f-8ffa-85f4c43ae138
# ╟─6d0f5d99-f7e2-4f53-b835-c3b345613e4a
# ╟─61b8631b-8295-4dea-a5dd-189bf578bc8c
# ╟─ab5e6c19-789b-4944-ba8e-f983a9a2652c
# ╟─8b4ee7b2-2a01-44ae-8539-27f1815fe634
# ╟─187c01ca-053e-4994-a748-cf9b16683a50
# ╟─83d6c4fe-bcd6-4d7f-93ef-2e093b1284fa
# ╟─b9634a1e-f225-4986-867f-fd36f56882df
# ╟─ee09dcab-2298-444c-ad9f-f79268c9056c
# ╟─0f28a997-4945-47fe-83b9-058726bc8041
# ╟─750d0cc4-d117-48be-869a-234acfe0c6d4
# ╟─f95ffa70-f924-404a-8cec-fc281b8588e2
# ╟─3f0465bc-444c-4026-a677-a182366790ae
# ╟─864c9c06-e52b-4de8-bc16-d053fa3c0346
# ╟─538bf67b-33c6-45c3-b5bf-328922debb26
# ╟─dc47965d-e732-44e4-875c-b4922ff4bd1f
# ╟─18282939-e7ef-4da4-aade-72e7b01886de
# ╟─b2ea2e47-4fa5-4d17-8341-889069a717c7
# ╟─7e05a32f-44ba-45ec-8db2-6d23a966a298
# ╟─ad8ca8f4-fc43-4008-8d94-eae74c84010a
# ╟─d6a4e6dd-7ace-4406-be57-804b4c2537e5
# ╟─6feb0cb4-7bff-4635-ae38-4400affe89f3
# ╟─39e7cb17-7813-4103-880d-64803c636039
# ╟─8079a74c-005d-4654-8e44-d763a12aefd8
# ╟─308abd53-d536-4ff0-8e1d-9ac118742d93
# ╟─a0b3b930-5f2a-47a1-bc81-c70c2ff595e6
# ╟─cd5c821d-247e-4d18-93cf-065197b79f1b
# ╟─fb99bba7-e81b-4653-a7dc-3558f6fc7e2c
# ╟─c90bdb75-1918-4d57-93b1-6cda3e8fbb0c
# ╟─2f1d77a0-e5cd-4d77-8031-cff161f67a45
# ╟─d5de8d26-7e90-4615-bd3b-cdfd002f98b2
# ╟─838f3147-299c-4e12-a4b0-a9f29d19f2d7
# ╟─b6cce048-8953-42de-88ad-3694038a5458
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
