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

# ╔═╡ 980f4910-96f3-11eb-0d4f-b71ad9888d73
begin
	# ativando ambiente
	using Pkg; Pkg.activate(@__DIR__); Pkg.instantiate()
	
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

# ╔═╡ ee41b8da-a488-478d-a424-ad46470652ae
@bind veg Radio(["potato", "carrot"])

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
# ╠═ee41b8da-a488-478d-a424-ad46470652ae
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
