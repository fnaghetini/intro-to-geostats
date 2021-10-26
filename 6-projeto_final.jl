### A Pluto.jl notebook ###
# v0.16.4

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

# ╔═╡ 980f4910-96f3-11eb-0d4f-b71ad9888d73
begin
	# carregando pacotes necessários
	using GeoStats, DrillHoles
	using CSV, DataFrames, Query
    using Statistics, StatsBase
	using LinearAlgebra, Random 
	using FileIO, PlutoUI
    using Plots, StatsPlots
	
	# configurações de plotagem
	gr(format=:png)
end;

# ╔═╡ 14ac7b6e-9538-40a0-93d5-0379fa009872
html"""
<p style="background-color:lightgrey" xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><span property="dct:title">&nbsp&nbsp🏆&nbsp<b>Projeto Final</b></span> por <span property="cc:attributionName">Franco Naghetini</span> é licenciado sob <a href="http://creativecommons.org/licenses/by/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1"></a></p>
"""

# ╔═╡ 6b7e7c5d-7a86-4ea4-a47e-fb4148030c1a
PlutoUI.TableOfContents(aside=true, title="Sumário",
						indent=true, depth=2)

# ╔═╡ 3afd7a32-3696-4cea-b00c-b52bfdb003ba
md"""
![ufmg-logo](https://logodownload.org/wp-content/uploads/2015/02/ufmg-logo-2.png)
"""

# ╔═╡ c544614a-3e5c-4d22-9340-592aabf84871
md"""
# 🏆 Projeto Final

Este último módulo visa demonstrar, na prática, um fluxo de trabalho completo de estimativa de recursos realizado com o pacote [GeoStats.jl](https://github.com/JuliaEarth/GeoStats.jl). Para isso, utilizaremos todo o conhecimento adquirido nos cinco módulos anteriores. Abordaremos desde a etapa de importação dos dados brutos (tabelas Collar, Survey e Assay) até a geração de um modelo de teores 3D.

> ⚠️ Nos dois últimos módulos trabalhamos com uma base de dados 2D (i.e. Walker Lake). Neste módulo, no entanto, trabalharemos com um banco de dados 3D e, por isso, adaptaremos alguns conceitos.

O produto final deste módulo é um modelo de blocos estimado (i.e. modelo de teores) por diferentes métodos: Inverso do Quadrado da Distância (IQD), Krigagem Simples (KS) e Krigagem Ordinária (KO).
"""

# ╔═╡ 3353d0be-4280-4ffd-824b-745bb6b64f41
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

# ╔═╡ 8e2b3339-a65d-4e1b-a9fb-69b6cd4631ea
md"""
## 1. Base de dados

Neste módulo, utilizaremos uma base de dados desenvolvida pelo autor, denominada [Junipero](). Ela consiste em conjunto de furos realizados durante uma campanha de sondagem em um depósito fictício de Cu Pórfiro. Portanto, estaremos interessados na estimativa da commodity Cu (%).

A Figura 01 mostra os campos presentes nas quatro tabelas do banco de dados.
"""

# ╔═╡ af1aca7e-bde2-4e14-a664-b7c71ff80ffe
md"""
![tabelas_raw](https://i.postimg.cc/52Qz4t7Z/tables.jpg)

**Figura 01:** Tabelas Collar, Survey, Assay e Litho e seus respectivos campos.
"""

# ╔═╡ ff01a7d7-d491-4d49-b470-a2af6783c82b
md"""
## 2. Geração de furos

Primeiramente, vamos importar as quatro tabelas (i.e. Collar, Survey, Assay e Litho), utilizando o pacote [DrillHoles.jl](https://github.com/JuliaEarth/DrillHoles.jl)...
"""

# ╔═╡ 444402c6-99a3-4829-9e66-c4962fb83612
begin
	collar = Collar(file="data/Junipero/collar.csv",
					holeid=:HOLEID, x=:X, y=:Y, z=:Z)

	survey = Survey(file="data/Junipero/survey.csv",
					holeid=:HOLEID, at=:AT, azm=:AZM, dip=:DIP)

	assay  = Interval(file="data/Junipero/assay.csv",
					 holeid=:HOLEID, from=:FROM, to=:TO)

	litho  = Interval(file="data/Junipero/litho.csv",
					  holeid=:HOLEID, from=:FROM, to=:TO)
end;

# ╔═╡ 0d0d610a-b06c-4c16-878d-8d2d124b8b9e
md"""
Em seguida, podemos utilizar a função `drillhole` do mesmo pacote para gerar os furos de sondagem...
"""

# ╔═╡ 1d7df6f8-f643-4c1e-92b4-52e51c4ccda8
drillholes = drillhole(collar, survey, [assay, litho])

# ╔═╡ bb8336ba-f347-418c-8883-47d86350bc94
md"""
Vamos, agora, armazenar uma cópia da tabela de furos na variável `dh`...
"""

# ╔═╡ 412cfe3d-f9f1-49a5-9f40-5ab97946df6d
dh = copy(drillholes.table);

# ╔═╡ d343401d-61dc-4a45-ab9b-beaff2534886
md"""
##### Observações

- Após a geração dos furos, não há inconsistências em nenhuma das tabelas importadas.
"""

# ╔═╡ ec102b27-79e2-4a91-99d6-dff061752855
md"""
> ⚠️ Caso algo não tenha ficado claro, consulte o [módulo 2](https://github.com/fnaghetini/intro-to-geostats/blob/main/2-preparacao_de_amostras.jl).
"""

# ╔═╡ bedcf585-53ef-4cf6-9dc2-d3fc9cff7755
md"""
## 3. Limpeza dos dados

Nesta seção, iremos verificar a necessidade de se realizar uma limpeza na base de dados. Uma das primeiras atitudes a se tomar quando se lida com um novo banco de dados é a visualização do sumário estatístico de suas colunas. Frequentemente são encontrados valores faltantes e eventuais inconsistências. Podemos fazer isso com a função `describe`...
"""

# ╔═╡ 15fd1c4d-fbf2-4389-bc1c-eabbbd26817b
describe(dh)

# ╔═╡ 39ae0ea7-9659-4c7b-b161-fd9c3495f4e3
md"""
##### Observações

- Existem 307 valores faltantes das variáveis `CU` e `LITH`;
- As variáveis que deveriam ser numéricas foram reconhecidas como tal;
- Não existem valores anômalos que "saltam aos olhos".
"""

# ╔═╡ f9545a95-57c0-4de6-9ab7-3ac3728b3d27
md"""
Como o objetivo deste módulo é a geração de um modelo de estimativas de Cu (%), podemos remover os 307 valores faltantes do banco de dados e recalcular o sumário estatístico para validar essa operação. Para a remoção dos valores faltantes, utilizaremos a função `dropmissing!`...
"""

# ╔═╡ 4d5f2467-c7d5-4a82-9968-97f193090bd6
begin
    dropmissing!(dh)

    describe(dh)
end

# ╔═╡ 2af7dfc5-a26a-4ad3-a046-31d1dfa107f1
md"""
##### Observações

- Após a aplicação da função `dropmissing!`, os 307 valores falantes de `CU` e `LITH` foram removidos com sucesso da tabela de furos `dh`.
"""

# ╔═╡ ee6c8dfa-d8be-4b5a-bfe0-9e1b3f394e9d
md"""
> ⚠️ Caso algo não tenha ficado claro, consulte o [módulo 3](https://github.com/fnaghetini/intro-to-geostats/blob/main/3-analise_exploratoria.jl).
"""

# ╔═╡ f4bd13d4-70d3-4167-84ff-9d3c7200e143
md"""
## 4. Compositagem

Nesta seção, iremos realizar a compositagem com o objetivo de adequar as amostras à escala de trabalho (hipotética) de 10 metros. Primeiramente, vamos analisar a distribuição do comprimento `LENGTH` das amostras brutas (Figura 02)...
"""

# ╔═╡ 41790d87-ce85-461f-a16d-04821a3624bb
begin
	X̅_dh = round(mean(dh.LENGTH), digits=2)
	md_dh = round(median(dh.LENGTH), digits=2)
	
    # Plotagem da distribuição do comprimento das amostras brutas
    dh |> @df histogram(:LENGTH,
		                legend = :topleft,
		                label  = false,
		 				color  = :honeydew2,
						alpha  = 0.75,
	                    xlabel = "Suporte (m)",
        				ylabel = "Freq. Absoluta",
	                    title  = "Amostras Brutas")

    # plotagem da média
    vline!([X̅_dh], label="X̅ = $(X̅_dh) m")

    # plotagem da mediana
    vline!([md_dh], label="md = $(md_dh) m")
end

# ╔═╡ f40bca06-6a3e-4807-9857-ff17d21893bc
md"""
**Figura 02:** Distribuição do comprimento das amostras brutas.
"""

# ╔═╡ 7ea21049-5edd-4979-9782-8a20d4bb287b
md"""
##### Observações

- Grande parte das amostras apresenta um comprimento igual a 5 metros;
- O suporte das amostras brutas apresenta uma distribuição assimétrica negativa (cauda alongada à esquerda);
- O comprimento das amostras varia de 2,5 a 5,0 metros.
"""

# ╔═╡ d8ce39f1-8017-4df3-a55d-648bdd3dbc04
md"""
Vamos agora utilizar a função `composite` para realizar a compositagem das amostras pelo método do comprimento ótimo (`mode=:nodiscard`) para um tamanho `interval` de 10 metros...
"""

# ╔═╡ 32f75604-b01a-4a0b-a008-33b2a56f4b57
begin
	# compositagem (comprimento ótimo) para um intervalo de 10 m
	compostas = composite(drillholes, interval=10.0, mode=:nodiscard)

	# armazenando a tabela de furos compositados na variável "cp"
	cp = compostas.table
	
	# remoção de eventuais valores faltantes
	dropmissing!(cp)
end;

# ╔═╡ b6712822-7c4d-4936-bcc2-21b48be99a66
md"""
Agora, podemos analisar a distribuição do suporte das compostas ótimas (Figura 03)...
"""

# ╔═╡ 87808ab0-3bcb-428d-9ebf-71ffefbcb357
begin
	X̅_cp = round(mean(cp.LENGTH), digits=2)
	md_cp = round(median(cp.LENGTH), digits=2)
	
    # plotagem da distribuição do comprimento das compostas ótimas
    cp |> @df histogram(:LENGTH,
	                    legend = :topleft,
                        label  = false,
                        color  = :honeydew2,
                        alpha  = 0.75,
	                    xlabel = "Suporte (m)",
                        ylabel = "Freq. Absoluta",
		                title  = "Compostas Ótimas")

    # plotagem da média
    vline!([X̅_cp], label="X̅ = $(X̅_cp) m")

    # plotagem da mediana
    vline!([md_cp], label="md = $(md_cp) m")
end

# ╔═╡ 280db32e-cebf-4d51-bfcb-54d456f2194b
md"""
**Figura 03:** Distribuição do comprimento das compostas ótimas.
"""

# ╔═╡ 893d7d19-878b-4990-80b1-ef030b716048
md"""
##### Observações

- A média do suporte das compostas ótimas encontra-se muito próxima do comprimento pré-estabelecido (10 m);
- O suporte das compostas ótimas passou a apresentar uma distribuição aproximadamente simétrica.
"""

# ╔═╡ b85a7c2f-37e2-48b0-a1db-984e2e719f29
md"""
Podemos agora realizar uma comparação estatística entre as amostras brutas e as compostas ótimas a partir da função `compvalid`. Para isso, iremos avaliar a dispersão do comprimento das amostras e a média do teor de Cu (%).
"""

# ╔═╡ 676bea93-69a9-4f2c-bb3e-759a9d28b12e
function compvalid(amostras::DataFrame, id::String)
	
	report = DataFrame(Amostras   = id,
					   DP_suporte = std(amostras.LENGTH),
					   Média_Au   = mean(amostras.CU))
	return report
end

# ╔═╡ 59dfbb66-f188-49f1-87ba-4f7020c4c031
[compvalid(dh, "Brutas")
 compvalid(cp, "Comp. Ótimo")]

# ╔═╡ 7a021fbd-83ac-4a36-bb8c-98519e6f8acb
md"""
##### Observações

- Houve uma redução < 1% na média de Cu;
- Houve um aumento na dispersão do comprimento das amostras após a compositagem. Poderíamos testar outras configurações de compositagem, mas seguiremos com essas compostas.
"""

# ╔═╡ fb67daea-0b8b-47da-b06c-8256566f9ba0
md"""
> ⚠️ Caso algo não tenha ficado claro, consulte o [módulo 2](https://github.com/fnaghetini/intro-to-geostats/blob/main/2-preparacao_de_amostras.jl).
"""

# ╔═╡ f2be5f11-1923-4658-93cf-800ce57c32d3
md"""
## 5. Análise exploratória

Nesta seção, iremos conduzir uma análise exploratória simples, visando descrever principalmente a variável `CU`.

Primeiramente, vamos calcular sumário estatístico da variável `CU` e, em seguida, visualizar sua distribuição (Figura 04)...
"""

# ╔═╡ ecec08be-b9da-4913-9f5a-3a77631fa96e
function sumario(teor::String, id::String)
	q10 = quantile(cp[!,teor], 0.1)
	q90 = quantile(cp[!,teor], 0.9)
	
	df = DataFrame(teor = id,
                   X̄    = mean(cp[!,teor]),
				   md   = median(cp[!,teor]),
				   min  = minimum(cp[!,teor]),
			       max  = maximum(cp[!,teor]),
                   S²   = var(cp[!,teor]),
				   S    = std(cp[!,teor]),
                   q10  = q10,
				   q90  = q90,
                   Cᵥ   = variation(cp[!,teor]),
                   skew = skewness(cp[!,teor]))
				
	return df
end;

# ╔═╡ d00f02fc-3c14-4911-a36b-209c747f96cb
sumario_cu = sumario("CU", "Cu (amostral)")

# ╔═╡ b95a6def-f3e6-4835-b15f-2a48577006f4
begin
	# cálculo da média e mediana
	X̅_cu = round(sumario_cu.X̄[], digits=2)
	md_cu = round(sumario_cu.md[], digits=2)
	
    # plotagem da distribuição dos teores compostos de Cu
    cp |> @df histogram(:CU,
		                bins   = 30,
		 				label  = false,
		                color  = :honeydew2,
		                alpha  = 0.75,
		                xlabel = "Cu (%)",
            			ylabel = "Freq. Absoluta")

    # plotagem da média
    vline!([X̅_cu], label="X̄ = $(X̅_cu)%")

    # plotagem da mediana
    vline!([md_cu], label="md = $(md_cu)%")
end

# ╔═╡ 81a5831f-75ef-478b-aba5-70d19306798e
md"""
**Figura 04:** Distribuição dos teores compostos de Cu (%).
"""

# ╔═╡ 0808061f-4856-4b82-8560-46a59e669ac4
md"""
##### Observações

- A média do Cu é igual a 0,86%;
- O coeficiente de variação do Cu é de 46% e, portanto, essa variável é pouco errática;
- A princípio, os lowgrades do depósito correspondem a amostras ≤ 0,47%;
- A princípio, os _high grades_ do depósito correspondem a amostras > 1,32%;
- Como X̅ > P50, Skew > 0 e tem-se cauda alongada à direita, a distribuição dos teores compostos de Cu é assimétrica positiva.
"""

# ╔═╡ c0604ed8-766e-4c5d-a628-b156615f8140
md"""
Como estamos lidando com dados geoespaciais, a visualização espacial da variável de interesse sempre deve ser realizada em conjunto com a sua descrição estatística.

Nesse sentido, podemos utilizar o pacote [Plots.jl](https://github.com/JuliaPlots/Plots.jl) para visualizar a distribuição espacial dos teores de Cu (Figura 05). Utilize os sliders abaixo para analisar os dados por ângulos diferentes...
"""

# ╔═╡ eac8e835-83bc-4f9c-b25b-3aaddcf69611
md"""
**Figura 05:** Distribuição espacial dos teores de Cu (%).
"""

# ╔═╡ 8bb2f630-8234-4f7f-a05c-8206993bdd45
md"""

Rotação em Z: $(@bind α Slider(0:10:90, default=30, show_value=true))°

Rotação em X: $(@bind β Slider(0:10:90, default=30, show_value=true))°

"""

# ╔═╡ 074bff0b-6b41-4bbc-9b5c-77fbf62c4dc6
# Visualização dos furos por teor de Cu
cp |> @df scatter(:X, :Y, :Z,
	              marker_z = :CU,
	              marker   = (:circle, 4),
	              colorbar = true,
	              color    = :jet,
                  xlabel   = "X",
	              ylabel   = "Y",
	              zlabel   = "Z",
	              label    = "Teor de Cu (%)",
                  camera   = (α, β))

# ╔═╡ 862dd0cf-69ae-48e7-92fb-ff433f62e67c
md"""
Podemos, ainda, visualizar os *highgrades* e *lowgrades* de Cu (Figura 06). Como não temos muito conhecimento sobre o depósito, adotaremos a seguinte convenção:
- `lowgrades`: Cu (%) ≤ P10
- `highgrades`: Cu (%) > P90

Utilize os sliders acima para analisar esses teores por ângulos diferentes...
"""

# ╔═╡ 52c28a55-3a4a-4df3-841a-ab8fc748bf55
md"""
**Figura 06:** Distribuição espacial dos highgrades e lowgrades de Cu (%).
"""

# ╔═╡ 3ae99e49-6996-4b4a-b930-f6073994f25c
begin	
    # filtragem dos teores lowgrade
    lg = cp |> @filter(_.CU ≤ sumario_cu.q10[])
	
	# filtragem dos teores highgrade
    hg = cp |> @filter(_.CU > sumario_cu.q90[])
end;

# ╔═╡ ea0968ca-a997-40c6-a085-34b3aa89807e
begin

    # Visualização de todas as amostras (cinza claro)
    @df cp scatter(:X, :Y, :Z,
		           marker = (:circle, 4, :gray95, 0.5),
		           label  = false,
		           xlabel = "X",
                   ylabel = "Y",
		           zlabel = "Z",
	               camera = (α, β))
	
	# Visualização de lowgrades (azul)
    @df lg scatter!(:X, :Y, :Z,
		            marker=(:circle, 4, :blue),
		            label="lowgrades")
    
    # Visualização de highgrades (vermelho)
    @df hg scatter!(:X, :Y, :Z,
		            marker=(:circle, 4, :red),
		            label="highgrades")

end

# ╔═╡ ccbcf57e-d00b-43df-8555-eee8bf4f9e6f
md"""
##### Observações

- Os *highgrades* ocorrem em regiões de maior densidade amostral;
- Os *low grades* tendem a se concentrar em porções de densidade amostral baixa;
- As amostras apresentam-se ligeiramente agrupadas na porção sudeste do depósito.
"""

# ╔═╡ c6c41764-509c-4f40-b063-a5f85dcc16db
md"""
> ⚠️ Caso algo não tenha ficado claro, consulte o [módulo 3](https://github.com/fnaghetini/intro-to-geostats/blob/main/3-analise_exploratoria.jl).
"""

# ╔═╡ 3c2eb77b-60e9-4aeb-9d19-ba22293741f9
md"""
## 6. Desagrupamento

Antes de calcularmos as estatísticas desagrupadas, devemos georreferenciar os dados, utilizando a função `georef`...
"""

# ╔═╡ 63b75ae2-8dca-40e3-afe0-68c6a639f54e
samples = georef(cp, (:X,:Y,:Z))

# ╔═╡ 5699c563-d6cb-4bc2-8063-e1be00722a41
md"""
Com os dados georreferenciados, podemos calcular as estatísticas desagrupadas do Cu (%). Utilize o slider abaixo para configurar o tamanho do bloco de desagrupamento... 
"""

# ╔═╡ 16cb8eaa-773e-4a42-ae8d-00bebddedc59
md"""
Tamanho de bloco: $(@bind s Slider(50.:10.:250., default=230., show_value=true)) m
"""

# ╔═╡ af160a03-10ea-404e-87a3-e6417058449f
begin
	# Sumário estatístico do Cu clusterizado
	Cu_clus = sumario_cu[:,[:teor,:X̄,:S²,:q10,:md,:q90]]
	
	# Sumário estatístico do Cu declusterizado
	Cu_decl = DataFrame(teor = "Cu (desagrupado)",
						X̄    = mean(samples, :CU, s),
						S²   = var(samples, :CU, s),
						q10  = quantile(samples, :CU, 0.1, s),
						md   = quantile(samples, :CU, 0.5, s),
						q90  = quantile(samples, :CU, 0.9, s))
	
	# Razão das médias (%)
	Xᵣ = (Cu_decl.X̄ / Cu_clus.X̄)[] * 100
	
	# Concatenação dos sumários
	[Cu_clus
     Cu_decl]
end

# ╔═╡ 161cc157-9667-48b5-8832-586c4bb0c476
md"""
##### Observações

- A média declusterizada representa $(round(Xᵣ, digits=2))% da média original. Ou seja, há uma diferença de $(round((100-Xᵣ), digits=2))% de Cu entre a média original e a média declusterizada;
- Utilizaremos essas estatísticas desagrupadas mais tarde, durante a validação das estimativas.
"""

# ╔═╡ 6ec16d83-d8fb-45d0-a7f8-d75f712b4c91
md"""
> ⚠️ Caso algo não tenha ficado claro, consulte o [módulo 3](https://github.com/fnaghetini/intro-to-geostats/blob/main/3-analise_exploratoria.jl).
"""

# ╔═╡ b02263dc-280a-40b4-be1e-9c3b6873e153
md"""

## 7. Variografia

Durante o [módulo 4](https://github.com/fnaghetini/intro-to-geostats/blob/main/4-variografia.jl) tivemos uma breve introdução à variografia, com exemplos 2D. Neste módulo, entretanto, lidaremos com dados de sondagem 3D. Nesse sentido, adotaremos o fluxo de trabalho a seguir. Em cada etapa, listamos os principais parâmetros encontrados:

1. **Variograma down hole:**
    - Efeito pepita e as contribuições das estruturas.
2. **Variograma azimute:**
    - Azimute de maior continuidade;
    - Primeira rotação do variograma (eixo Z).
3. **Variograma primário:**
    - Dip de maior continuidade, fixando-se o azimute;
    - Segunda rotação do variograma (eixo X);
    - Alcance da direção (azimute + dip) de maior continuidade (Y).
4. **Variogramas secundário e terciário:**
    - Terceira rotação do variograma (eixo Y);
    - Alcance da direção de continuidade intermediária (X);
    - Alcance da direção de menor continuidade (Z).
"""

# ╔═╡ 6d520cfe-aa7b-4083-b2bf-b34f840c0a75
md"""
### 1. Variograma down hole

Primeiramente, iremos calcular o **variograma experimental down hole**, com o intuito de se obter o *efeito pepita* e o valor de *contribuição por estrutura*.

> ⚠️ Esses parâmetros serão utilizados na modelagem de todos os variogramas experimentais que serão calculados adiante!
"""

# ╔═╡ 289865a9-906f-46f4-9faa-f62feebbc92a
md"""
Como o variograma down hole é calculado ao longo da orientação dos furos, devemos avaliar as estatísticas das variáveis `AZM` (azimute) e `DIP` (mergulho) pertencentes à tabela de perfilagem:
"""

# ╔═╡ 1db51803-8dc4-4db6-80a1-35a489b6fb9e
begin
	
	# sumário estatístico da variável "AZM"
	azmdf = DataFrame(Variable = "Azimute",
                      Mean     = mean(compostas.trace.AZM),
					  Median   = median(compostas.trace.AZM),
					  Min      = minimum(compostas.trace.AZM),
					  Max      = maximum(compostas.trace.AZM))
	
	# sumário estatístico da variável "DIP"
	dipdf = DataFrame(Variable = "Dip",
                      Mean     = mean(compostas.trace.DIP),
					  Median   = median(compostas.trace.DIP),
					  Min      = minimum(compostas.trace.DIP),
					  Max      = maximum(compostas.trace.DIP))
	
	# azimute e dip médios
	μazi = round(azmdf.Mean[], digits=2)
	μdip = round(dipdf.Mean[], digits=2)
	
	# concatenação vertical dos sumários
	[azmdf
	 dipdf]

end

# ╔═╡ e49b7b48-77d8-4abf-a5df-70e9c65e3667
begin
	# converte coordenadas esféricas para cartesianas
	function sph2cart(azi, dip)
		θ, ϕ = deg2rad(azi), deg2rad(dip)
		sin(θ)*cos(ϕ), cos(θ)*cos(ϕ), -sin(ϕ)
	end
	
	# converte coordenadas cartesianas para esféricas
	function cart2sph(x, y, z)
		θ, ϕ = atan(x, y), atan(z, √(x^2 + y^2))
		rad2deg(θ), rad2deg(ϕ)
	end
		
	# Direcão ao longo dos furos
	dirdh = sph2cart(μazi, μdip)
end;

# ╔═╡ a717d5d3-9f4e-4a2d-8e32-f0605bbd742f
md"""
Agora que sabemos a orientação média dos furos ($(round(μazi,digits=2))°/ $(round(μdip,digits=2))°), podemos calcular o variograma experimental down hole (Figura 07). Utilize os sliders abaixos para configurar os parâmetros necessários...
"""

# ╔═╡ 8348abd3-27f6-4161-bd04-c4be6a644888
md"""
**Figura 07:** Variograma experimental downhole.
"""

# ╔═╡ 1465f010-c6a7-4e72-9842-4504c6dda0be
md"""
Número de passos: $(@bind nlagsdh Slider(5:1:30, default=11, show_value=true))

Largura da banda: $(@bind toldh Slider(10:5:50, default=45, show_value=true)) m
"""

# ╔═╡ ffe3700c-262f-4949-b910-53cbe1dd597b
begin
	# semente aleatória
	Random.seed!(1234)
	
	# cor para variogramas down hole
	colordh = :brown

	# cálculo variograma down hole para a variável Cu
	gdh = DirectionalVariogram(dirdh, samples, :CU,
		                       maxlag=150, nlags=nlagsdh, dtol=toldh)
	
	# variância a priori
	σ² = var(samples[:CU])
	
	# plotagem do variograma experimental downhole
    plot(gdh, ylims=(0, σ²+0.05), color=colordh, ms=5,
		 legend=:bottomright, label=false, title="")
	
	# linha horizontal tracejada cinza (variância à priori)
    hline!([σ²], color=:gray, label="σ²")

end

# ╔═╡ 0b46230a-b305-4840-aaad-e985444cf54e
md"""
Com o variograma down hole calculado, podemos ajustá-lo com um modelo teórico conhecido. Utilize os sliders abaixo para encontrar o melhor ajuste para esse variograma experimental (Figura 08)...
"""

# ╔═╡ fc2ea8f3-064a-4d6d-8115-236c8160cc23
md"""
**Figura 08:** Ajuste teórico ao variograma experimental downhole.
"""

# ╔═╡ 0585add6-1320-4a31-a318-0c40b7a444fa
md"""
Efeito pepita: $(@bind cₒ Slider(0.00:0.005:0.06, default=0.025, show_value=true))

Contribuição 1ª estrutura: $(@bind c₁ Slider(0.045:0.005:0.18, default=0.055, show_value=true))

Contribuição 2ª estrutura: $(@bind c₂ Slider(0.045:0.005:0.18, default=0.065, show_value=true))

Alcance 1ª estrutura: $(@bind rdh₁ Slider(10.0:2.0:140.0, default=110.0, show_value=true)) m

Alcance 2ª estrutura: $(@bind rdh₂ Slider(10.0:2.0:140.0, default=110.0, show_value=true)) m
"""

# ╔═╡ c6d0a87e-a09f-4e78-9672-c858b488fd39
begin

    # criação da primeira estrutura do modelo de variograma (efeito pepita)
    γdhₒ = NuggetEffect(nugget=Float64(cₒ))

    # criação da segunda estrutura do modelo de variograma (1ª contribuição ao sill)
    γdh₁ = SphericalVariogram(sill=Float64(c₁), range=Float64(rdh₁))

    # criação da terceira estrutura do modelo de variograma (2ª contribuição ao sill)
    γdh₂ = SphericalVariogram(sill=Float64(c₂), range=Float64(rdh₂))

    # aninhamento das três estruturas
    γdh  = γdhₒ + γdh₁ + γdh₂

    # plotagem do variograma experimental downhole
    plot(gdh, color=colordh, ms=5, label=false,
		 legend=:bottomright, title="Variograma Down Hole")

    # plotagem do modelo de variograma aninhado
    plot!(γdh, 0, 150, ylims=(0, σ²+0.05), color=colordh,
		  lw=2, label=false)
    
    # linha horizontal tracejada cinza (variância à priori)
    hline!([σ²], color=:gray, label="σ²")
    
    # linha vertical tracejada cinza (alcance)
    vline!([range(γdh)], color=colordh, ls=:dash, primary=false)

end

# ╔═╡ 09d95ff8-3ba7-4031-946b-8ba768dae5d5
md"""
### 2. Variograma azimute

O próximo passo é o cálculo do **variograma experimental do azimute de maior continuidade**. Nesta etapa, obteremos a *primeira rotação* do variograma.

> ⚠️ A primeira rotação do variograma ocorre em torno do eixo Z.

Calcularemos diversos variogramas experimentais ortogonais entre si e escolheremos aquele que apresentar maior continuidade/alcance (Figura 09).

Utilize o slider `Azimute` para definir o azimute de cálculo. Automaticamente, o variograma de direção perpendicular àquela definida também será calculado. Utilize os demais sliders para configurar os parâmetros restantes...

> ⚠️ Normalmente, o variograma de menor continuidade é perpendicular ao variograma de maior alcance. Utilize essa informação para selecionar a direção mais contínua.
"""

# ╔═╡ bda3cda3-9d57-495b-be79-1415aa95707f
md"""
**Figura 09:** Variogramas experimentais de azimutes de maior e menor continuidade.
"""

# ╔═╡ 17b21a63-9fa6-4975-9302-5465cdd3d2fa
md"""
Azimute: $(@bind azi Slider(0.0:22.5:67.5, default=67.5, show_value=true)) °

Número de passos: $(@bind nlagsazi Slider(5:1:20, default=8, show_value=true))

Largura de banda: $(@bind dtolazi Slider(10:10:100, default=70, show_value=true)) m

"""

# ╔═╡ d07a57c3-0a7a-49c2-a840-568e72d50545
begin

    Random.seed!(1234)
	
	coloraziₐ = :green
	coloraziᵦ = :purple

    gaziₐ = DirectionalVariogram(sph2cart(azi, 0), samples, :CU,
                                 maxlag = 350, nlags = nlagsazi, dtol = dtolazi)

    gaziᵦ = DirectionalVariogram(sph2cart((azi+90), 0), samples, :CU,
		                         maxlag = 350, nlags = nlagsazi, dtol = dtolazi)
	
	plot(gaziₐ, ylims=(0, σ²+0.05), color = coloraziₐ, ms = 5,
		 legend = :bottomright, label="$azi °")

    plot!(gaziᵦ, color = coloraziᵦ, ms = 5, label="$(azi+90) °")

    hline!([σ²], color = :gray, label="σ²")

end

# ╔═╡ 9389a6f4-8710-44c3-8a56-804017b6239b
md"""
✔️ Agora sabemos que a *primeira rotação do variograma é igual a $(azi)*. Utilizaremos essa informação mais a frente para a criação do elipsoide de anisotropia.
"""

# ╔═╡ 99baafe5-6249-4eda-845f-d7f6219d5726
# Cores dos variograms principais
colorpri, colorsec, colorter = :red, :green, :blue;

# ╔═╡ 294ac892-8952-49bc-a063-3d290c375ea5
md"""
### 3. Variograma primário

Agora, calcularemos o **variograma experimental primário**, ou seja, aquele que representa a *direção (azimute/mergulho) de maior continuidade*.

Nesta etapa, devemos encontrar o *maior alcance* do modelo de variograma final, além da *segunda rotação do variograma*.

> ⚠️ A segunda rotação do variograma ocorre em torno do eixo X.

Para o cálculo deste variograma experimental, devemos fixar o azimute de maior continuidade já encontrado ($azi °) e variar o mergulho. A orientação (azimute/mergulho) que fornecer o maior alcance, será eleita a *direção de maior continuidade* (Figura 10).

Utilize o slider `Mergulho` para definir o mergulho de cálculo e os outros para configurar os demais parâmetros...
"""

# ╔═╡ 774f8e10-fd10-4b16-abcf-20579f174f8a
md"""
**Figura 10:** Variograma experimental primário.
"""

# ╔═╡ 97670210-2c91-4be7-a607-0da83cb16f44
md"""

Mergulho: $(@bind dip Slider(0.0:22.5:90.0, default=22.5, show_value=true))°

Número de passos: $(@bind nlagspri Slider(5:1:20, default=8, show_value=true))

Largura de banda: $(@bind tolpri Slider(10:10:100, default=70, show_value=true)) m

"""

# ╔═╡ 668da8c2-2db6-4812-90ce-86b17b289cc6
begin
	
    Random.seed!(1234)

    gpri = DirectionalVariogram(sph2cart(azi, dip), samples, :CU,
                                maxlag = 350, nlags = nlagspri, dtol = tolpri)

	plot(gpri, ylims=(0, σ²+0.05), color = colorpri, ms = 5,
		 legend = :bottomright, label=false, title="$azi ° / $dip °")

    hline!([σ²], color = :gray, label="σ²")
end

# ╔═╡ eb9ebce2-7476-4f44-ad4f-10a1ca522143
md"""
Agora que o variograma primário foi calculado, podemos utilizar os sliders abaixo para ajustá-lo com um modelo teórico conhecido (Figura 11)...
"""

# ╔═╡ 24981600-3336-4295-b567-8f05785b9346
md"""
**Figura 11:** Ajuste teórico ao variograma experimental primário.
"""

# ╔═╡ 92d11f3b-c8be-4701-8576-704b73d1b619
md"""

Alcance 1ª estrutura: $(@bind rpri₁ Slider(10.0:2.0:300.0, default=84.0, show_value=true)) m

Alcance 2ª estrutura: $(@bind rpri₂ Slider(10.0:2.0:300.0, default=190.0, show_value=true)) m

"""

# ╔═╡ fa93796d-7bc0-4391-89a7-eeb63e1a3838
begin

    γpriₒ = NuggetEffect(nugget = Float64(cₒ))

    γpri₁ = SphericalVariogram(sill = Float64(c₁), range = Float64(rpri₁))

    γpri₂ = SphericalVariogram(sill = Float64(c₂), range = Float64(rpri₂))

    γpri  = γpriₒ + γpri₁ + γpri₂

    plot(gpri, color = colorpri, ms = 5,
	     legend = :bottomright, label = "primário", title = "$azi °/ $dip °")

    plot!(γpri, 0, 350, ylims = (0, σ²+0.05), color = colorpri, lw = 2,
		  label = "teórico")
		
    hline!([σ²], color = :gray, label="σ²")

    vline!([range(γpri)], color = colorpri, ls = :dash, primary = false)

end

# ╔═╡ 55373bb0-6953-4c6f-b1dd-2dacac90b6cc
md"""
✔️ Agora sabemos que a *segunda rotação do variograma é igual a $dip °*. Além disso, também encontramos os *alcances do eixo primário* do variograma.
"""

# ╔═╡ 6c048b83-d12c-4ce8-9e9a-b89bf3ef7638
md"""

### 4. Variogramas secundário e terciário

Por definição, os três eixos principais do variograma são ortogonais entre si. Agora que encontramos a *direção de maior continuidade do variograma (eixo primário)*, sabemos que os outros dois eixos (secundário e terciário) pertencem a um plano cuja normal é o próprio eixo primário!

Portanto, nesta etapa, encontraremos os *alcances intermediário e menor* do modelo de variograma final, bem como a *terceira rotação do variograma (rake)*.

> ⚠️ A terceira rotação do variograma ocorre em torno do eixo Y.

Como o eixo primário do variograma apresenta uma orientação $(azi)° / $(dip)°, podemos encontrar o plano que contém os eixos secundário e terciário. Ressalta-se ainda que *eixos secundário e terciário são ortogonais entre si*.

> ⚠️ Iremos adotar a seguinte convenção de eixos:
>- Eixo primário (maior continuidade) = Y;
>- Eixo secundário (continuidade intermediária) = X;
>- Eixo terciário (menor continuidade) = Z.

Para o cálculo dos variogramas experimentais secundário e terciário, escolheremos duas direções para serem eleitas as *direções secundária e terciária* do modelo de variograma (Figura 12).

Utilize o slider `Rake` para definir as direções de cálculo dos variogramas secundário e terciário. Utilize os demais sliders para configurar os outros parâmetros...
"""

# ╔═╡ a92f702d-8859-4f95-b676-36deab03e717
md"""
**Figura 12:** Variogramas experimentais secundário e terciário.
"""

# ╔═╡ 120f4a9c-2ca6-49f1-8abc-999bcc559149
md"""

Rake: $(@bind θ Slider(range(0, stop=90-180/8, step=180/8), default=45, show_value=true))°

Número de passos: $(@bind nlagssec Slider(5:1:20, default=11, show_value=true))

Largura de banda: $(@bind tolsec Slider(10:10:100, default=70, show_value=true)) m

"""

# ╔═╡ 0def0326-55ef-45db-855e-a9a683b2a76d
begin

    Random.seed!(1234)

	# Encontra vetores u e v perpendiculares entre si e perpendiculares a normal
	n = Vec(sph2cart(azi,dip))
	u = Vec(sph2cart(azi+90,0))
	v = n × u
	
	# Giro no plano perpendicular gerado por u e v
	dirsec = cos(deg2rad(θ)) .* u .+ sin(deg2rad(θ)) .* v
	dirter = cos(deg2rad(θ+90)) .* u .+ sin(deg2rad(θ+90)) .* v

	# Variograma secundário
    gsec = DirectionalVariogram(dirsec, samples, :CU,
		                        maxlag = 250, nlags = nlagssec, dtol = tolsec)

	# Variograma terciário
    gter = DirectionalVariogram(dirter, samples, :CU,
								maxlag = 250, nlags = nlagssec, dtol = tolsec)
	
	plot(gsec, ylims=(0, σ²+0.2), color = colorsec, ms = 5,
		 legend = :bottomright, label = "secundário")

    plot!(gter, color = colorter, ms = 5, label = "terciário")

    hline!([σ²], color = :gray, label="σ²")

end

# ╔═╡ 34b9b30f-615d-43ff-8d07-ed757cd69a7f
md"""
✔️ Agora sabemos que a *terceira rotação do variograma é igual a $θ °*.

Como já elegemos o variograma experimental representante do eixo secundário, podemos utilizar os sliders abaixo para modelá-lo (Figura 13)...
"""

# ╔═╡ b19e5ac0-21fd-4dcd-ac61-a36a67ee80dd
md"""
**Figura 13:** Ajuste teórico ao variograma experimental secundário.
"""

# ╔═╡ 922d81f3-0836-4b14-aaf2-83be903c8642
md"""

Alcance 1ª estrutura: $(@bind rsec₁ Slider(10.0:2.0:200.0, default=60.0, show_value=true)) m

Alcance 2ª estrutura: $(@bind rsec₂ Slider(10.0:2.0:200.0, default=84.0, show_value=true)) m

"""

# ╔═╡ a74b7c50-4d31-4bd3-a1ef-6869abf73185
begin

    γsecₒ = NuggetEffect(Float64(cₒ))
	
    γsec₁ = SphericalVariogram(sill = Float64(c₁), range = Float64(rsec₁))

    γsec₂ = SphericalVariogram(sill = Float64(c₂), range = Float64(rsec₂))

    γsec  = γsecₒ + γsec₁ + γsec₂

    plot(gsec, color = colorsec, ms = 5,
	     label = false, legend = :bottomright)

    plot!(γsec, 0, 250, ylims = (0, σ²+0.2), color = colorsec, lw = 2,
	      label = false)

    hline!([σ²], color = :gray, label="σ²")

    vline!([range(γsec)], color = colorsec, ls = :dash, primary = false)

end

# ╔═╡ fed7dbb1-8dfd-4242-a060-7b44508ce432
md"""
✔️ Agora encontramos os *alcances do eixo secundário* do variograma.

Finalmente, podemos também utilizar os sliders abaixo para modelar o variograma terciário (Figura 14)...
"""

# ╔═╡ 33ba8a9b-f548-4984-8a31-1c381b31ced4
md"""
**Figura 14:** Ajuste teórico ao variograma experimental terciário.
"""

# ╔═╡ dacfe446-3c19-430d-8f5f-f276a022791f
md"""

Alcance 1ª Estrutura: $(@bind rter₁ Slider(10.0:2.0:200.0, default=58.0, show_value=true)) m

Alcance 2ª Estrutura: $(@bind rter₂ Slider(10.0:2.0:200.0, default=62.0, show_value=true)) m

"""


# ╔═╡ 0927d78e-9b50-4aaf-a93c-69578608a4f8
begin

    γterₒ = NuggetEffect(Float64(cₒ))

    γter₁ = SphericalVariogram(sill = Float64(c₁), range = Float64(rter₁))

    γter₂ = SphericalVariogram(sill = Float64(c₂), range = Float64(rter₂))

    γter  = γterₒ + γter₁ + γter₂

    plot(gter, color = colorter, ms = 5, label = false,
	     legend = :bottomright)

    plot!(γter, 0, 250, ylims = (0, σ²+0.2), color = colorter, lw = 2,
		  label = false)

    hline!([σ²], color = :gray, label="σ²")

    vline!([range(γter)], color = colorter, ls = :dash, primary = false)

end

# ╔═╡ 38946a3f-d5a6-4a1c-a1d5-d4ec475f1545
md"""
✔️ Agora encontramos os *alcances do eixo terciário* do variograma.
"""

# ╔═╡ 483487c6-acf8-4551-8357-2e69e6ff44ff
md"""
### Modelo de variograma final

Agora que temos as três direções principais do modelo de variograma, podemos sumarizar as informações obtidas nos passos anteriores na tabela abaixo. A Figura 15 é a representação gráfica da informação contida nessa tabela.

| Estrutura | Modelo | Alcance em Y | Alcance em X | Alcance em Z | Contribuição | Efeito Pepita |
|:---:|:--------:|:--------:|:--------:|:--------:|:---:|:---:|
|  0  |     -    |    -     |    -     |    -     |  -  | $cₒ |
|  1  | Esférico |  $rpri₁  |  $rsec₁  |  $rter₁  | $c₁ |  -  |
|  2  | Esférico |  $rpri₂  |  $rsec₂  |  $rter₂  | $c₂ |  -  |

"""

# ╔═╡ c9ac9fb4-5d03-43c9-833e-733e48565946
begin
    plot(γpri, color=colorpri, lw=2, label="primário",
		 legend=:bottomright, title="")

    plot!(γsec, color=colorsec, lw=2, label="secundário")

    plot!(γter, 0, range(γpri)+10, color=colorter, lw=2, label="terciário",
		  ylims=(0, σ²+0.05))
	
	hline!([σ²], color=:gray, label="σ²")
end

# ╔═╡ 5134e2cb-8c98-4e5e-9f13-722b8f828dc7
md"""
**Figura 15:** Modelo de variograma 3D anisotrópico.
"""

# ╔═╡ d700e40b-dd7f-4630-a29f-f27773000597
md"""
Além das informações sumarizadas acima, devemos escolher uma convenção de rotação que, por sua vez, é utilizada para definir a orientação do elipsoide de anisotropia no espaço.

A convenção de rotação que iremos adotar é a do clássico software **GSLIB**. Portanto, as rotações do do elipsoide de anisotropia serão:

| Rotação | Eixo |   Ângulo   |
|:-------:|:----:|:----------:|
|    1ª   |   Z  |  $(azi)°   |
|    2ª   |   X  |  $(-dip)°  |
|    3ª   |   Y  |  $(-θ)°    |

> ⚠️ Caso queira entender melhor a convenção de rotação GSLIB, consulte [Deutsch (2015)](https://geostatisticslessons.com/lessons/anglespecification).

O elipsoide de anisotropia nada mais é do que uma representação do modelo de variograma que utilizaremos como entrada no sistema linear de Krigagem. Os eixos desse elipsoide representam os alcances (do variograma) e a orientação dessa geometria é definida pelas três rotações. Sabendo disso, podemos construir o modelo de variograma final...
"""

# ╔═╡ 38d15817-f3f2-496b-9d83-7dc55f4276dc
begin
	# elipsoides de anisotropia para cada estrutura
	ellipsoid₁ = Ellipsoid([rpri₁, rsec₁, rter₁], [azi, -dip, -θ], convention=GSLIB)
    ellipsoid₂ = Ellipsoid([rpri₂, rsec₂, rter₂], [azi, -dip, -θ], convention=GSLIB)

	# estruturas do variograma final
	γₒ = NuggetEffect(nugget=Float64(cₒ))
	
    γ₁ = SphericalVariogram(sill=Float64(c₁), distance=metric(ellipsoid₁))
	
    γ₂ = SphericalVariogram(sill=Float64(c₂), distance=metric(ellipsoid₂))

	# aninhamento das estruturas e obtenção do modelo de variograma final
    γ = γₒ + γ₁ + γ₂
end;

# ╔═╡ b2156251-26ae-4b1d-8757-ffdf3a02a2f8
md"""
>🏆 Finalmente encontramos o modelo de variograma final $\gamma$, que será utilizado como entrada durante a estimação por Krigagem.
"""

# ╔═╡ 51f8bc33-a24f-4ce4-a81b-cd22fb8312ec
md"""
> ⚠️ Caso algo não tenha ficado claro, consulte o [módulo 4](https://github.com/fnaghetini/intro-to-geostats/blob/main/4-variografia.jl).
"""

# ╔═╡ 9baefd13-4c16-404f-ba34-5982497e8da6
md"""
## 8. Estimação

Nesta seção, seguiremos o fluxo de trabalho do [GeoStats.jl](https://juliaearth.github.io/GeoStats.jl/stable/index.html#Quick-example), anteriormente apresentado no [módulo 5]():

- **Etapa 1:** Criação do domínio de estimativas;
- **Etapa 2:** Definição do problema de estimação;
- **Etapa 3:** Definição do estimador;
- **Etapa 4:** Solução do problema de estimação.
"""

# ╔═╡ a7a59395-59ec-442a-b4b6-7db55d150d53
md"""

### Etapa 1: Criação do domínio de estimativas

Nesta primeira etapa, delimitaremos o domínio de estimativas. No contexto de estimativa de recursos minerais, esse domínio é chamado de **modelo de blocos**.

> ⚠️ O modelo de blocos é o modelo geológico 3D discretizado em unidades volumétricas menores (i.e. blocos). Em outras palavras, trata-se do modelo geológico constituído por "tijolos".

Para definir o modelo de blocos, devemos configurar três parâmetros:

- Ponto de origem do modelo de blocos;
- Ponto de término do modelo de blocos;
- Número de blocos nas direções X, Y e Z.

Faremos algumas manipulações e, em seguida, utilizaremos a função `CartesianGrid` para criar o modelo de blocos, cujas dimensões dos blocos serão `20 m x 20 m x 10 m` (Figura 16)...
"""

# ╔═╡ f7cee6a3-5ac2-44ff-9d5e-58ede7327c46
begin
	# caixa delimitadora das amostras
    bbox = boundingbox(samples)
	
	# lados da caixa delimitadora
	extent = maximum(bbox) - minimum(bbox)
	
	# tamanho dos blocos em cada direção (metros)
	blocksizes = (20., 20., 10.)
	
	# número de blocos em cada direção
	nblocks = ceil.(Int, extent ./ blocksizes)

	# modelo de blocos
    grid = CartesianGrid(minimum(bbox), maximum(bbox), dims=Tuple(nblocks))
end

# ╔═╡ a73cc834-c600-4278-bc77-49b85dc90256
md"""
**Figura 16:** Modelo de blocos.
"""

# ╔═╡ 12d79d77-358c-4098-993a-d5be538929a2
md"""
Utilize os sliders abaixo para rotacionar o modelo de blocos...

Rotação em Z: $(@bind ψ₁ Slider(0:5:90, default=45, show_value=true))°

Rotação em X: $(@bind ψ₂ Slider(0:5:90, default=45, show_value=true))°
"""

# ╔═╡ 6f7663ed-c672-4d29-8b06-415dcdc8fbff
plot(grid, camera = (ψ₁,ψ₂), xlabel = "X", ylabel = "Y", zlabel = "Z")

# ╔═╡ a8adf478-620d-4744-aae5-99d0891fe6b0
md"""

### Etapa 2: Definição do problema de estimação

Para definirmos o problema de estimação, devemos definir os seguintes parâmetros:

- Furos georreferenciados;
- Modelo de blocos;
- Variável de interesse.

Neste exemplo, passaremos os furos georreferenciados `samples`, o modelo de blocos `grid` e a variável de interesse `:CU` como parâmetros da função `EstimationProblem`...
"""

# ╔═╡ affacc76-18e5-49b2-8e7f-77499d2503b9
problem = EstimationProblem(samples, grid, :CU)

# ╔═╡ 31cd3d10-a1e8-4ad8-958f-51de08d0fa54
md"""

### Etapa 3: Definição do estimador

Nesta etapa, devemos selecionar o estimador (solver) e configurar os parâmetros de vizinhança. Neste exemplo, utilizaremos três estimadores:

- Inverso do Quadrado da Distância (IQD);
- Krigagem Simples (KS);
- Krigagem Ordinária (KO).

No caso dos estimadores KS e OK, utilizaremos o modelo de variograma `γ` e um volume de busca igual ao elipsoide de anisotropia `ellipsoid₂` definido anteriormente.

A média estacionária, um parâmetro que deve ser informado no caso da KS, será definida como o valor da média declusterizada de Cu `μ`.

Utilize os sliders abaixo para configurar o número mínimo `minneighbors` e máximo `maxneighbors` de amostras que serão utilizadas para se estimar cada bloco...
"""

# ╔═╡ 9c61271d-4afe-4f7c-a521-8f799b6981ed
md"""

Número mínimo de amostras: $(@bind nmin Slider(2:1:6, default=4, show_value=true))

Número máximo de amostras: $(@bind nmax Slider(6:1:20, default=8, show_value=true))

"""

# ╔═╡ 2a76c2b9-953e-4e4b-a98e-8e992943f60c
begin
	# média desclusterizada
    μ = mean(samples, :CU)
	
	# IQD
	IQD = IDW(:CU => (power=2, neighbors=nmax))

	# KS
    KS = Kriging(
		:CU => (variogram=γ, mean=μ, neighborhood=ellipsoid₂,
			    minneighbors=nmin, maxneighbors=nmax)
	)

	# KO
    KO = Kriging(
		:CU => (variogram=γ, neighborhood=ellipsoid₂,
			    minneighbors=nmin, maxneighbors=nmax)
	)

end;

# ╔═╡ 9b3fe534-78fa-48db-a101-e2a43f2478d6
md"""

### Etapa 4: Solução do problema de estimação

Para gerar o modelo de estimativas de Cu, resolvemos o problema definido com os três estimadores para, posteriormente, compará-los. Clique na caixa abaixo para executar as estimativas...

Executar estimativas: $(@bind run CheckBox())
"""

# ╔═╡ e9b7e9b7-146f-4763-ad79-c93e111b25b4
if run
	sol_iqd = solve(problem, IQD)
end

# ╔═╡ 78117ae8-d77c-4508-9793-3e7e9dfbb913
if run
	sol_ks = solve(problem, KS)
end

# ╔═╡ 5e86ee34-60fe-43e4-851c-2f08072f836e
if run
	sol_ko = solve(problem, KO)
end

# ╔═╡ 50650d2f-350b-446d-8c4b-6aa19e18c148
md"""
Agora que os teores de Cu foram estimados, clique na caixa abaixo para visualizar o modelo de teores (Figura 17). Em seguida, selecione, na lista suspensa abaixo, a solução que deseja visualizar...

Visualizar estimativas: $(@bind viz CheckBox())
"""

# ╔═╡ bce98bc9-c676-4a2e-bdac-10a74a9cdeae
if run && viz
md"""
Solução: $(@bind selection Select(["IQD", "KS", "KO"], default="KO"))
"""
end

# ╔═╡ 3bc456e5-9030-41e5-a48c-179da59547c9
if run && viz
	md"""
	**Figura 17:** Visualização das estimativas por $selection.
	"""
end

# ╔═╡ 97b41da9-979a-4785-9ee4-19f43d912c49
if run && viz	
	if selection == "IQD"
		sol = sol_iqd
	elseif selection == "KS"
		sol = sol_ks
	elseif selection == "KO"
		sol = sol_ko
	end
end;

# ╔═╡ 63d5db73-1073-4b8d-bfab-93577579571f
if run && viz
	cmin, cmax = coordinates.(extrema(grid))
		
	xm, ym, zm = cmin
	xM, yM, zM = cmax
	
	md"""
	Rotação em Z: $(@bind ϕ₁ Slider(0:5:90, default=45, show_value=true))°

	Rotação em X: $(@bind ϕ₂ Slider(0:5:90, default=45, show_value=true))°

	X: $(@bind x Slider(xm:xM, show_value=true, default=(xm+xM)/2)) m
	
	Y: $(@bind y Slider(ym:yM, show_value=true, default=(ym+yM)/2)) m
	
	Z: $(@bind z Slider(zm:zM, show_value=true, default=(zm+zM)/2)) m
	"""
end

# ╔═╡ b2197d9c-0342-4efe-8c9e-ecf45a07fcf3
if run && viz
	sol |> @filter(!isnan(_.CU)) |>
	@map({CU = _.CU, COORDS = coordinates(centroid(_.geometry))}) |>
	@map({CU = _.CU, X = _.COORDS[1], Y = _.COORDS[2], Z = _.COORDS[3]}) |>
	@filter(_.X < x && _.Y < y && _.Z < z) |>
	@df scatter(:X, :Y, :Z, marker_z = :CU, color = :jet, marker = (:square, 4),
	            xlabel = "X", ylabel = "Y", zlabel = "Z",
		        xlims = (xm, xM), ylims = (ym, yM), zlims = (zm, zM),
	            label = "Modelo de teores de Cu (%)", camera = (ϕ₁, ϕ₂))
end

# ╔═╡ 4f05c05d-c92a-460d-b3e0-d392111ef57a
md"""
## 9. Validação das estimativas

Nesta etapa, iremos comparar as estimativas geradas pelos três estimadores por meio de duas abordagens de validação:

- Validação global das estimativas;
- Q-Q plot entre teores amostrais e teores estimados.
"""

# ╔═╡ fb8dc6e2-8708-41c5-b4ca-0f04b7a2bde5
md"""
Na **validação global das estimativas**, nos atentaremos para a comparação entre os seguintes sumários estatísticos:

- Cu (amostral);
- Cu (desagrupado);
- Cu (estimado por IQD);
- Cu (estimado por KS);
- Cu (estimado por KO).

> ⚠️ Como a Krigagem leva em consideração a redundância amostral, é mais conveniente compararmos a média Krigada com a a média declusterizada.

Compare os cinco sumários estatísticos gerados abaixo...
"""

# ╔═╡ 92b731f3-5eae-406e-a593-4e6d49f476d9
if run
	sol_ks_filt = sol_ks |> @filter(!isnan(_.CU)) |> DataFrame
	sol_ko_filt = sol_ko |> @filter(!isnan(_.CU)) |> DataFrame
end;

# ╔═╡ c6b0f335-19cb-4fbe-a47b-2ba3fd664832
if run
	
	stats_iqd = DataFrame(teor = "Cu (IQD)",
                         X̄    = mean(sol_iqd[:CU]),
                         S²   = var(sol_iqd[:CU]),
                         q10  = quantile(sol_iqd[:CU], 0.1),
                         md   = quantile(sol_iqd[:CU], 0.5),
                         q90  = quantile(sol_iqd[:CU], 0.9))
	
	stats_ks = DataFrame(teor = "Cu (KS)",
                         X̄    = mean(sol_ks_filt[!,:CU]),
                         S²   = var(sol_ks_filt[!,:CU]),
                         q10  = quantile(sol_ks_filt[!,:CU], 0.1),
                         md   = quantile(sol_ks_filt[!,:CU], 0.5),
                         q90  = quantile(sol_ks_filt[!,:CU], 0.9))

	
    stats_ko = DataFrame(teor = "Cu (KO)",
                         X̄    = mean(sol_ko_filt[!,:CU]),
                         S²   = var(sol_ko_filt[!,:CU]),
                         q10  = quantile(sol_ko_filt[!,:CU], 0.1),
                         md   = quantile(sol_ko_filt[!,:CU], 0.5),
                         q90  = quantile(sol_ko_filt[!,:CU], 0.9))

    [Cu_clus
	 Cu_decl
	 stats_iqd
	 stats_ks
	 stats_ko]

end

# ╔═╡ ed97c749-30b7-4c72-b790-fef5a8332548
if run
	md"""
	##### Observações

	- As médias estimadas são próximas à média declusterizada;
	- Nota-se uma suavização extrema da distribuição dos teores estimados pelos três métodos em relação à distribuição dos teores amostrais. Isso é evidenciado pela redução  de S²;
	- IQD gerou estimativas menos suavizadas do que KO;
	- KO gerou estimativas menos suavizadas do que KS e IQD.
	
	> ⚠️ Os estimadores da família da Krigagem tendem a gerar estimativas que não honram a real variabilidade do depósito (i.e. mais suavizadas). Uma alternativa seria a utilização de técnicas de **Simulação Geoestatística**. Para ter uma breve introdução a esse tópico, confira este [notebook](https://github.com/juliohm/CBMina2021/blob/main/notebook2.jl). 
	"""
end

# ╔═╡ 263c1837-7474-462b-bd97-ee805baec458
md"""
Já o **Q-Q plot entre os teores amostrais e os teores estimados** pode ser utilizado para realizar uma comparação entre as distribuições de Cu amostral e Cu estimado. Podemos analisar visualmente o grau de suavização dos diferentes estimadores.

Compare os Q-Q plots gerados abaixo (Figura 18)...
"""

# ╔═╡ 193dde9b-1f4a-4313-a3a6-ba3c89600bcb
if run

	qq_iqd = qqplot(
				   samples[:CU], sol_iqd[:CU],
		           color=:red, legend=:false,
                   xlabel="Cu amostral (%)",
		           ylabel="Cu estimado (%)",
                   title="IQD"
                   )
	
    qq_ks = qqplot(
				   samples[:CU], sol_ks_filt[!,:CU],
                   color=:red, legend=:false,
		           xlabel="Cu amostral (%)",
                   title="KS"
                   )
 
    qq_ko = qqplot(
				   samples[:CU], sol_ko_filt[!,:CU],
		           color=:green,
                   xlabel="Cu amostral (%)",
                   title="KO"
				  )

    plot(qq_iqd, qq_ks, qq_ko, layout=(1,3), size=(700,500))

end

# ╔═╡ 6926d1bb-359d-46a5-abf5-e1700d0edcf0
if run
	md"""
	**Figura 18:** Q-Q plots entre os teores amostrais e estimados de Cu (%).
	"""
end

# ╔═╡ 2181506b-76f5-4a57-adba-e90679b2b21b
md"""

##### Observações

- A KO mostra uma menor suavização em relação aos demais métodos;
- Métodos de Krigagem são conhecidos por suavizar inadequadamente a distribuição de teores.
"""

# ╔═╡ 5ad612f4-76e9-4867-b4c8-4c35540a5f47
md"""
## 10. Exportação das estimativas

Nesta última seção, iremos exportar as estimativas geradas pelo método da Krigagem Ordinária em dois formatos distintos:

- GSLIB;
- CSV.

Marque a caixa abaixo para executar a exportação das estimativas em ambos os formatos...

Salvar estimativas: $(@bind store CheckBox())
"""

# ╔═╡ b96c4bd5-54ba-4394-b963-5c5ddc06cf3b
# GSLIB
if run && store
	save("output/estimativas_KO.gslib", sol_ko)
end;

# ╔═╡ 79bc4b7d-72de-4c9e-94f5-3b5ba6bbff1d
function csvtable(solution, variable)
	center = centroid.(domain(solution))
	
	coords = coordinates.(center)
	
	X = getindex.(coords, 1)
	
	Y = getindex.(coords, 2)
	
	Z = getindex.(coords, 3)
	
	mean = solution[variable]
	
	var  = solution[variable*"-variance"]
	
	DataFrame(MEAN=mean, VARIANCE=var, X=X, Y=Y, Z=Z)
end;

# ╔═╡ 245c7304-1cc0-408a-97ec-867ac0cc81b0
# CSV
if run && store
	csvtable(sol_ko, "CU") |> CSV.write("output/estimativas_KO.csv")
end;

# ╔═╡ 1164ba05-0835-4713-b11c-92b37085b744
md"""
## Recursos adicionais

Abaixo, são listados alguns recursos complementares a este notebook:

> [Workshop GeoStats.jl - CBMina 2021](https://github.com/juliohm/CBMina2021)

> [Tutoriais GeoStats.jl - Notebooks](https://github.com/JuliaEarth/GeoStatsTutorials)

> [Tutoriais GeoStats.jl - Vídeos](https://www.youtube.com/playlist?list=PLsH4hc788Z1f1e61DN3EV9AhDlpbhhanw)

"""

# ╔═╡ 16baa4c7-2807-4aaf-9ace-dbc4d2f960c7
md"""
## Pacotes utilizados

Os seguintes pacotes foram utilizados neste notebook:

|                       Pacote                             |        Descrição        |
|:--------------------------------------------------------:|:-----------------------:|
|[GeoStats](https://github.com/JuliaEarth/GeoStats.jl)     | Rotinas geoestatísticas |
|[DrillHoles](https://github.com/JuliaEarth/DrillHoles.jl) | Furos de sondagem       |
|[CSV](https://github.com/JuliaData/CSV.jl)                | Arquivos CSV            |
|[DataFrames](https://github.com/JuliaData/DataFrames.jl)  | Manipulação de tabelas  |
|[Query](https://github.com/queryverse/Query.jl)           | Realização de consultas |
|[Statistics](https://docs.julialang.org/en/v1/)           | Cálculo de estatísticas |
|[StatsBase](https://github.com/JuliaStats/StatsBase.jl)   | Cálculo de estatísticas |
|[LinearAlgebra](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/)   | Álgebra linear |
|[Random](https://docs.julialang.org/en/v1/)               | Números aleatórios      |
|[FileIO](https://github.com/JuliaIO/FileIO.jl)            | Coversão entre formatos |
|[PlutoUI](https://github.com/fonsp/PlutoUI.jl)            | Widgets interativos     |
|[Plots](https://github.com/JuliaPlots/Plots.jl)           | Visualização dos dados  |
|[StatsPlots](https://github.com/JuliaPlots/StatsPlots.jl) | Visualização dos dados  |

"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DrillHoles = "9d36f3b5-8124-4f7e-bcda-df733105c718"
FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
GeoStats = "dcc97b0b-8ce5-5539-9008-bb190f959ef6"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Query = "1a8c2f83-1ff3-5112-b086-8aa67b057ba1"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
StatsPlots = "f3b207a7-027a-5e70-b257-86293d7955fd"

[compat]
CSV = "~0.8.5"
DataFrames = "~1.2.2"
DrillHoles = "~0.1.4"
FileIO = "~1.11.1"
GeoStats = "~0.27.0"
Plots = "~1.23.1"
PlutoUI = "~0.7.16"
Query = "~1.0.0"
StatsBase = "~0.33.12"
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
deps = ["Dates", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode"]
git-tree-sha1 = "b83aa3f513be680454437a0eee21001607e5d983"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.8.5"

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
git-tree-sha1 = "15dad92b6a36400c988de3fc9490a372599f5b4c"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.21"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[DrillHoles]]
deps = ["CSV", "DataFrames", "StatsBase"]
git-tree-sha1 = "b8ad18a7f8f61bebc10da2ded20456a2e2a32de5"
uuid = "9d36f3b5-8124-4f7e-bcda-df733105c718"
version = "0.1.4"

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
git-tree-sha1 = "bfd7d8c7fd87f04543810d9cbd3995972236ba1b"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.2"

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
# ╟─980f4910-96f3-11eb-0d4f-b71ad9888d73
# ╟─14ac7b6e-9538-40a0-93d5-0379fa009872
# ╟─6b7e7c5d-7a86-4ea4-a47e-fb4148030c1a
# ╟─3afd7a32-3696-4cea-b00c-b52bfdb003ba
# ╟─c544614a-3e5c-4d22-9340-592aabf84871
# ╟─3353d0be-4280-4ffd-824b-745bb6b64f41
# ╟─8e2b3339-a65d-4e1b-a9fb-69b6cd4631ea
# ╟─af1aca7e-bde2-4e14-a664-b7c71ff80ffe
# ╟─ff01a7d7-d491-4d49-b470-a2af6783c82b
# ╠═444402c6-99a3-4829-9e66-c4962fb83612
# ╟─0d0d610a-b06c-4c16-878d-8d2d124b8b9e
# ╠═1d7df6f8-f643-4c1e-92b4-52e51c4ccda8
# ╟─bb8336ba-f347-418c-8883-47d86350bc94
# ╠═412cfe3d-f9f1-49a5-9f40-5ab97946df6d
# ╟─d343401d-61dc-4a45-ab9b-beaff2534886
# ╟─ec102b27-79e2-4a91-99d6-dff061752855
# ╟─bedcf585-53ef-4cf6-9dc2-d3fc9cff7755
# ╠═15fd1c4d-fbf2-4389-bc1c-eabbbd26817b
# ╟─39ae0ea7-9659-4c7b-b161-fd9c3495f4e3
# ╟─f9545a95-57c0-4de6-9ab7-3ac3728b3d27
# ╠═4d5f2467-c7d5-4a82-9968-97f193090bd6
# ╟─2af7dfc5-a26a-4ad3-a046-31d1dfa107f1
# ╟─ee6c8dfa-d8be-4b5a-bfe0-9e1b3f394e9d
# ╟─f4bd13d4-70d3-4167-84ff-9d3c7200e143
# ╟─41790d87-ce85-461f-a16d-04821a3624bb
# ╟─f40bca06-6a3e-4807-9857-ff17d21893bc
# ╟─7ea21049-5edd-4979-9782-8a20d4bb287b
# ╟─d8ce39f1-8017-4df3-a55d-648bdd3dbc04
# ╠═32f75604-b01a-4a0b-a008-33b2a56f4b57
# ╟─b6712822-7c4d-4936-bcc2-21b48be99a66
# ╟─87808ab0-3bcb-428d-9ebf-71ffefbcb357
# ╟─280db32e-cebf-4d51-bfcb-54d456f2194b
# ╟─893d7d19-878b-4990-80b1-ef030b716048
# ╟─b85a7c2f-37e2-48b0-a1db-984e2e719f29
# ╠═676bea93-69a9-4f2c-bb3e-759a9d28b12e
# ╠═59dfbb66-f188-49f1-87ba-4f7020c4c031
# ╟─7a021fbd-83ac-4a36-bb8c-98519e6f8acb
# ╟─fb67daea-0b8b-47da-b06c-8256566f9ba0
# ╟─f2be5f11-1923-4658-93cf-800ce57c32d3
# ╟─ecec08be-b9da-4913-9f5a-3a77631fa96e
# ╟─d00f02fc-3c14-4911-a36b-209c747f96cb
# ╟─b95a6def-f3e6-4835-b15f-2a48577006f4
# ╟─81a5831f-75ef-478b-aba5-70d19306798e
# ╟─0808061f-4856-4b82-8560-46a59e669ac4
# ╟─c0604ed8-766e-4c5d-a628-b156615f8140
# ╟─074bff0b-6b41-4bbc-9b5c-77fbf62c4dc6
# ╟─eac8e835-83bc-4f9c-b25b-3aaddcf69611
# ╟─8bb2f630-8234-4f7f-a05c-8206993bdd45
# ╟─862dd0cf-69ae-48e7-92fb-ff433f62e67c
# ╟─ea0968ca-a997-40c6-a085-34b3aa89807e
# ╟─52c28a55-3a4a-4df3-841a-ab8fc748bf55
# ╟─3ae99e49-6996-4b4a-b930-f6073994f25c
# ╟─ccbcf57e-d00b-43df-8555-eee8bf4f9e6f
# ╟─c6c41764-509c-4f40-b063-a5f85dcc16db
# ╟─3c2eb77b-60e9-4aeb-9d19-ba22293741f9
# ╠═63b75ae2-8dca-40e3-afe0-68c6a639f54e
# ╟─5699c563-d6cb-4bc2-8063-e1be00722a41
# ╟─16cb8eaa-773e-4a42-ae8d-00bebddedc59
# ╟─af160a03-10ea-404e-87a3-e6417058449f
# ╟─161cc157-9667-48b5-8832-586c4bb0c476
# ╟─6ec16d83-d8fb-45d0-a7f8-d75f712b4c91
# ╟─e49b7b48-77d8-4abf-a5df-70e9c65e3667
# ╟─b02263dc-280a-40b4-be1e-9c3b6873e153
# ╟─6d520cfe-aa7b-4083-b2bf-b34f840c0a75
# ╟─289865a9-906f-46f4-9faa-f62feebbc92a
# ╟─1db51803-8dc4-4db6-80a1-35a489b6fb9e
# ╟─a717d5d3-9f4e-4a2d-8e32-f0605bbd742f
# ╟─ffe3700c-262f-4949-b910-53cbe1dd597b
# ╟─8348abd3-27f6-4161-bd04-c4be6a644888
# ╟─1465f010-c6a7-4e72-9842-4504c6dda0be
# ╟─0b46230a-b305-4840-aaad-e985444cf54e
# ╟─c6d0a87e-a09f-4e78-9672-c858b488fd39
# ╟─fc2ea8f3-064a-4d6d-8115-236c8160cc23
# ╟─0585add6-1320-4a31-a318-0c40b7a444fa
# ╟─09d95ff8-3ba7-4031-946b-8ba768dae5d5
# ╟─d07a57c3-0a7a-49c2-a840-568e72d50545
# ╟─bda3cda3-9d57-495b-be79-1415aa95707f
# ╟─17b21a63-9fa6-4975-9302-5465cdd3d2fa
# ╟─9389a6f4-8710-44c3-8a56-804017b6239b
# ╟─99baafe5-6249-4eda-845f-d7f6219d5726
# ╟─294ac892-8952-49bc-a063-3d290c375ea5
# ╟─668da8c2-2db6-4812-90ce-86b17b289cc6
# ╟─774f8e10-fd10-4b16-abcf-20579f174f8a
# ╟─97670210-2c91-4be7-a607-0da83cb16f44
# ╟─eb9ebce2-7476-4f44-ad4f-10a1ca522143
# ╟─fa93796d-7bc0-4391-89a7-eeb63e1a3838
# ╟─24981600-3336-4295-b567-8f05785b9346
# ╟─92d11f3b-c8be-4701-8576-704b73d1b619
# ╟─55373bb0-6953-4c6f-b1dd-2dacac90b6cc
# ╟─6c048b83-d12c-4ce8-9e9a-b89bf3ef7638
# ╟─0def0326-55ef-45db-855e-a9a683b2a76d
# ╟─a92f702d-8859-4f95-b676-36deab03e717
# ╟─120f4a9c-2ca6-49f1-8abc-999bcc559149
# ╟─34b9b30f-615d-43ff-8d07-ed757cd69a7f
# ╟─a74b7c50-4d31-4bd3-a1ef-6869abf73185
# ╟─b19e5ac0-21fd-4dcd-ac61-a36a67ee80dd
# ╟─922d81f3-0836-4b14-aaf2-83be903c8642
# ╟─fed7dbb1-8dfd-4242-a060-7b44508ce432
# ╟─0927d78e-9b50-4aaf-a93c-69578608a4f8
# ╟─33ba8a9b-f548-4984-8a31-1c381b31ced4
# ╟─dacfe446-3c19-430d-8f5f-f276a022791f
# ╟─38946a3f-d5a6-4a1c-a1d5-d4ec475f1545
# ╟─483487c6-acf8-4551-8357-2e69e6ff44ff
# ╟─c9ac9fb4-5d03-43c9-833e-733e48565946
# ╟─5134e2cb-8c98-4e5e-9f13-722b8f828dc7
# ╟─d700e40b-dd7f-4630-a29f-f27773000597
# ╠═38d15817-f3f2-496b-9d83-7dc55f4276dc
# ╟─b2156251-26ae-4b1d-8757-ffdf3a02a2f8
# ╟─51f8bc33-a24f-4ce4-a81b-cd22fb8312ec
# ╟─9baefd13-4c16-404f-ba34-5982497e8da6
# ╟─a7a59395-59ec-442a-b4b6-7db55d150d53
# ╠═f7cee6a3-5ac2-44ff-9d5e-58ede7327c46
# ╟─6f7663ed-c672-4d29-8b06-415dcdc8fbff
# ╟─a73cc834-c600-4278-bc77-49b85dc90256
# ╟─12d79d77-358c-4098-993a-d5be538929a2
# ╟─a8adf478-620d-4744-aae5-99d0891fe6b0
# ╠═affacc76-18e5-49b2-8e7f-77499d2503b9
# ╟─31cd3d10-a1e8-4ad8-958f-51de08d0fa54
# ╠═2a76c2b9-953e-4e4b-a98e-8e992943f60c
# ╟─9c61271d-4afe-4f7c-a521-8f799b6981ed
# ╟─9b3fe534-78fa-48db-a101-e2a43f2478d6
# ╠═e9b7e9b7-146f-4763-ad79-c93e111b25b4
# ╠═78117ae8-d77c-4508-9793-3e7e9dfbb913
# ╠═5e86ee34-60fe-43e4-851c-2f08072f836e
# ╟─50650d2f-350b-446d-8c4b-6aa19e18c148
# ╟─bce98bc9-c676-4a2e-bdac-10a74a9cdeae
# ╟─b2197d9c-0342-4efe-8c9e-ecf45a07fcf3
# ╟─3bc456e5-9030-41e5-a48c-179da59547c9
# ╟─97b41da9-979a-4785-9ee4-19f43d912c49
# ╟─63d5db73-1073-4b8d-bfab-93577579571f
# ╟─4f05c05d-c92a-460d-b3e0-d392111ef57a
# ╟─fb8dc6e2-8708-41c5-b4ca-0f04b7a2bde5
# ╟─92b731f3-5eae-406e-a593-4e6d49f476d9
# ╟─c6b0f335-19cb-4fbe-a47b-2ba3fd664832
# ╟─ed97c749-30b7-4c72-b790-fef5a8332548
# ╟─263c1837-7474-462b-bd97-ee805baec458
# ╟─193dde9b-1f4a-4313-a3a6-ba3c89600bcb
# ╟─6926d1bb-359d-46a5-abf5-e1700d0edcf0
# ╟─2181506b-76f5-4a57-adba-e90679b2b21b
# ╟─5ad612f4-76e9-4867-b4c8-4c35540a5f47
# ╠═b96c4bd5-54ba-4394-b963-5c5ddc06cf3b
# ╠═245c7304-1cc0-408a-97ec-867ac0cc81b0
# ╟─79bc4b7d-72de-4c9e-94f5-3b5ba6bbff1d
# ╟─1164ba05-0835-4713-b11c-92b37085b744
# ╟─16baa4c7-2807-4aaf-9ace-dbc4d2f960c7
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
