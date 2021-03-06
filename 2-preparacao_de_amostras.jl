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

# ╔═╡ e50f4dc1-99db-439d-9357-fcf523a7f50a
begin
	# configuração da página para as cenas do WGLMakie
	using WGLMakie, JSServe
    Page()
end

# ╔═╡ 9ca215d0-2e8c-11ec-27ae-3bac6ad63ae1
begin
	# carregando pacotes necessários
	using DrillHoles
	using Statistics
	using PlutoUI
	using DataFrames
	using Query
	using Plots
	
	# configurações de visualização
	theme = WGLMakie.Theme(
		resolution = (650,500),
		aspect = :data,
		colormap=:jet
	)
	WGLMakie.set_theme!(theme)
end;

# ╔═╡ d380ac0f-28a7-48f4-8463-9dbdf7f66a16
html"""
<p style="background-color:lightgrey" xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><span property="dct:title">&nbsp&nbsp🛠️&nbsp<b>Preparação de Amostras</b></span> por <span property="cc:attributionName">Franco Naghetini</span> é licenciado sob <a href="http://creativecommons.org/licenses/by/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1"></a></p>
"""

# ╔═╡ ebaf4b98-9f4a-45bc-ad35-54448f26f90c
PlutoUI.TableOfContents(aside=true, title="Sumário",
						indent=true, depth=2)

# ╔═╡ ffdbdfbd-8627-48d9-8e9c-384455b64ed4
md"""
![ufmg-logo](https://logodownload.org/wp-content/uploads/2015/02/ufmg-logo-2.png)
"""

# ╔═╡ b9b5f9a4-431d-40fc-94fe-8d622ba7c5a8
md""" # 🛠️ Preparação de Amostras

Os dados utilizados para a avaliação de um projeto de mineração normalmente apresentam tamanhos e tipos distintos e, portanto, em estado bruto, são inadequados para a condução da estimativa de recursos. Nesse sentido, a **preparação de amostras** é uma etapa que visa realizar um tratamento especial desses dados (*Abzalov, 2016*).

Ainda que uma grande variedade de dados **diretos** (e.g. furos de sondagem, trincheiras) e **indiretos** (e.g. geofísicos) sejam utilizados em empreendimentos minerários, neste módulo, iremos aprender sobre a preparação de **furos de sondagem**, o tipo de dado mais usual na mineração.
"""

# ╔═╡ eedd9f9b-6425-4b8c-ad1f-7bbedc122072
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

# ╔═╡ aa0a8370-7919-41e1-9a05-481df4e48ec7
md"""
## 1. Conceitos básicos

Nesta primeira seção, iremos aprender alguns conceitos teóricos essenciais para compreender o conteúdo deste módulo.
"""

# ╔═╡ 6c867bb6-87d6-420f-8665-fe4581ffd0a9
md"""
### Furos de sondagem

O registro dos **furos de sondagem** é uma das atividades mais comuns e importantes entre geólogos, uma vez que, frequentemente, os furos são a única informação geológica direta sobre as rochas localizadas em subsuperfície. As informações de sondagem, após registradas em um Sistema de Gerenciamento de Banco de Dados, são utilizadas pelos geólogos para gerar interpretações 3D e estimativas de teores de um depósito (*Abzalov, 2016*).

Normalmente, os dados de sondagem são constituídos por um conjunto de tabelas distintas relacionadas entre si por um campo-chave, o identificador dos furos (comumente chamado de `BHID` ou `HOLEID`) (Figura 01).
"""

# ╔═╡ a5bc3c03-856b-4ee2-a71c-8c7e1fe3c641
md"""
![Figura_01](https://i.postimg.cc/52Qz4t7Z/tables.jpg)
_**Figura 01:** Tabelas Collar, Survey, Assay e Litho relacionadas entre si pelo campo-chave `HOLEID`._
"""

# ╔═╡ ae22a6f0-d857-4229-a003-728d43a50d46
md"""
A tabela **Collar** traz, essencialmente, informações das coordenadas de boca dos furos. Ela pode conter, ainda, informações de profundidade final dos furos, método de aquisição de coordenadas, sistema de referência e data de finalização.

A tabela **Survey** apresenta informações de perfilagem, ou seja, de orientação dos furos (sentido e ângulo de mergulho).

As tabelas do tipo **Interval** são essencialmente constituídas por colunas de início (`FROM`) e final (`TO`) dos intervalos amostrais, bem como por uma característica geológica. A tabela **Assay**, por exemplo, além dos campos que definem o intervalo, contém os campos de teores amostrais analisados em laboratório. Já a tabela **Litho**, por outro lado, traz informações das litologias descritas pelos geólogos.
"""

# ╔═╡ 51199548-4ec2-4034-b955-8d1f97ddd5ee
md""" ### Suporte amostral

Uma característica muito importante dos dados utilizados na mineração é o **suporte amostral**. De forma simples, o suporte está associado ao **tamanho, forma e orientação** das amostras. Os furos de sondagem, por exemplo, são constituídos por diversos intervalos cilíndricos menores (definidos pelos campos `FROM` e `TO`), que podem apresentar tamanhos/comprimentos distintos.

Os exemplos a seguir, extraídos de *Sinclair & Blackwell (2006)*, evidenciam a importância de características geológicas dos depósitos no suporte amostral:

> **Exemplo 1:**. Em depósitos estratiformes, como aqueles de Zn-Pb hospedados em folhelhos, um conjunto de amostras lineares contíguas (e.g. intervalos de testemunhos de sondagem) paralelas ao acamamento são, em média, muito mais similares entre si do que um conjunto de amostras do mesmo tipo, mas perpendiculares ao acamamento. Percebemos aqui a importância da **orientação** das amostras.

> **Exemplo 2:** Em zonas de veios auríferos, amostras perpendiculares à orientação dos veios apresentarão uma grande variabilidade de teores, caso o tamanho do intervalo amostral seja menor do que a distância média entre os veios (algumas amostras podem ter teores nulos!). Por outro lado, amostras perpendiculares aos veios, mas com o tamanho do intervalo amostral superior à distância média entre os veios serão menos erráticas. Percebemos aqui a importância do **tamanho** das amostras.

> ⚠️ Neste módulo, para fins de simplificação, trataremos o conceito de **suporte amostral** como sinônimo do **tamanho/comprimento** dos intervalos amostrais dos furos de sondagem.
"""

# ╔═╡ dd89a21f-ce6b-4a3c-9c22-1f97ac3863a8
md"""
## 2. Geração de furos

Neste módulo, iremos trabalhar com o [Marvin](https://github.com/fnaghetini/intro-to-geostats/tree/main/data/Marvin), um conjunto de dados de um depósito de Cu-Au Pórfiro fictício, mas que apresenta uma série de caracteríticas típicas de depósitos sulfetados (*Whittle et al., 2007*).

> ⚠️ Para fins de simplificação, apenas os teores de `Au` foram mantidos.

Para a importação das tabelas Collar, Survey, Assay e Litho e geração dos furos de sondagem, utilizaremos o pacote [DrillHoles.jl](https://github.com/JuliaEarth/DrillHoles.jl)...
"""

# ╔═╡ 9ce42874-5a58-4e6a-a544-dfea97146cc2
begin
	collar = Collar(file = "data/Marvin/collar.csv",
					holeid = :HOLEID, x = :X, y = :Y, z = :Z, enddepth=:ENDDEPTH)

	survey = Survey(file = "data/Marvin/survey.csv",
					holeid = :HOLEID, at = :AT, azm = :AZM, dip = :DIP)

	assay  = Interval(file = "data/Marvin/assay.csv",
					  holeid = :HOLEID, from = :FROM, to = :TO)

	litho  = Interval(file = "data/Marvin/litho.csv",
					  holeid = :HOLEID, from = :FROM, to = :TO)
end;

# ╔═╡ f9fa9a2f-8099-434e-a76c-4b78160f264a
md"""
Em seguida, podemos utilizar a função `drillhole` para gerar os furos a partir das quatro tabelas importadas...
"""

# ╔═╡ 1e71d41a-5717-462d-81da-8ac35f22c1db
furosdesondagem = drillhole(collar, survey, [assay, litho])

# ╔═╡ 1673eef5-82cf-4eef-8ca2-17d02ecb9b27
md"""
##### Observações

- Uma inconsistência do tipo *overlap* entre as linhas 3 e 4 do arquivo `assay.csv` foi encontrada durante a geração dos furos;
- Esse erro indica que existem amostras duplicadas na tabela de teores;
- Podemos seguir a orientação da mensagem e consultar mais detalhes sobre o erro, utilizando o atributo `warns`...
"""

# ╔═╡ 63ab68f1-b342-4e8c-987d-4fc33166aa3c
furosdesondagem.warns

# ╔═╡ 6e2e4df4-096b-444f-bff3-44c70f3d1dd5
md"""
Se você abrir o arquivo `assay.csv`, perceberá que as linhas 3 e 4, de fato, se referem ao mesmo intervalo (i.e. 5.0 m - 7.5 m). Podemos excluir a linha 4 da tabela de teores, já que ela não possui teor de Au.

Vamos gerar novamente os furos, mas dessa vez importando o arquivo `assay_val.csv` como tabela Assay, ou seja, a tabela de teores já validada...
"""

# ╔═╡ 6b7b4fbe-622e-407c-8ffc-9fe888354ced
begin
	# importação da tabela assay validada
	assay_val  = Interval(file = "data/Marvin/assay_val.csv",
					  	  holeid = :HOLEID, from = :FROM, to = :TO)
	
	# 
	furosvalidados = drillhole(collar, survey, [assay_val, litho])
end

# ╔═╡ f16c8b13-256d-4c1d-a376-4e7d41ecf35d
md"""
##### Observações

- Após a nova geração dos furos, nenhuma inconistência foi relatada;
- Ao final da geração dos furos, são criados quatro objetos: `table`, `trace`, `pars` e `warns` (já discutido).

O objeto `table` contém a própria tabela de furos que será utilizada ao longo deste módulo...
"""

# ╔═╡ 0aed3ddb-b181-4f03-950c-b23e0f153760
furos = furosvalidados.table

# ╔═╡ 10f1c03f-ead5-42c5-a5c5-816d52a15653
md"""
A tabela `furos` é constituída pelas seguintes colunas:
- `HOLEID`: identificador dos furos.
- `FROM` e `TO`: início e final do intervalo amostral em metros.
- `LENGTH`: tamanho do intervalo amostral em metros.
- `AU`: teor de ouro em g/t.
- `DOMAIN`, `ROCKTYPE` e `WEATH`: domínio, tipo de rocha e alteração, respectivamente.
- `X`, `Y` e `Z`: coordenadas geográficas dos centroides dos intervalos.

Já o objeto `trace` contém as informações de perfilagem, ou seja, dados de sentido e ângulo de mergulho dos furos...
"""

# ╔═╡ 9929fafa-2bc5-4fec-83a4-c8f9b1229b0c
furosvalidados.trace

# ╔═╡ b1ec589e-35af-4e34-a663-c72f4b0afe02
md"""
O objeto `pars` contém os nomes das colunas presentes no arquivo de furos e alguns parâmetros sobre a geração dos furos...
"""

# ╔═╡ bfbe894b-a205-4d21-8adf-a26a2052573e
furosvalidados.pars

# ╔═╡ 48e9011a-dfa3-4665-9e23-2aab30e0d294
md"""
## 3. Compositagem

Normalmente, os dados brutos de sondagem (i.e. sem nenhum processamento prévio) apresentam suportes amostrais distintos e precisam ser combinados para produzir amostras de suporte aproximadamente uniforme (*Sinclair & Blackwell, 2006*). Esse procedimento é denominado **compositagem**, e as amostras (combinadas) resultantes são chamadas de **compostas**.

> ⚠️ A compositagem é realizada com o objetivo de combinar intervalos pequenos em intervalos maiores e uniformes. O processo inverso, ou seja, subdividir intervalos maiores em intervalos menores não é uma prática adequada, pois haveria uma suavização da distribuição espacial dos teores que não corresponde à realidade (*Abzalov, 2016*).

Ao compositar as amostras, os teores são recalculados. Segundo *Yamamoto (2001)*, o cálculo do teor composto $t_c$ é realizado pela média dos teores brutos $t_i$ dos intervalos que serão combinados ponderada pelos respectivos tamanhos $e_i$:

```math
t_c = \frac{\sum_{i=1}^{n} t_i e_i}{\sum_{i=1}^{n} e_i}
```
"""

# ╔═╡ 3f55ecbb-8f26-4813-ac3e-97588830d987
md"""
Você pode estar se perguntando sobre o porque devemos uniformizar o suporte amostral. Imagine que queremos calcular o teor médio de Au entre três amostras:

| Amostra | Teor (g/t) | Tamanho (m) |
|:-------:|:----------:|:-----------:|
|  AM01   |    2,5     |     2,0     |
|  AM02   |    0,5     |     10,0    |
|  AM03   |    0,2     |     15,0    |

O teor médio entre essas amostras é de aproximadamente 1 g/t. Repare que, independentemente do tamanho, cada amostra contribui igualmente para o cálculo da média. Entretanto, se fizermos uma análise crítica, perceberemos que uma amostra de 15 metros de comprimento não pode ter o mesmo peso no cálculo do que uma amostra de 2 metros. Se regularizarmos o suporte amostral, no entanto, esse problema será mitigado.
"""

# ╔═╡ c3e6a7e8-c4a2-42ad-9302-cd4be7ee0920
md"""
Segundo *Sinclair & Blackwell (2006)*, a compositagem objetiva:
1. Reduzir o número de amostras e, consequentemente, diminuir o custo computacional;
2. Regularizar o suporte amostral;
3. Reduzir o impacto de valores extremos isolados que podem dificultar a modelagem dos variogramas experimentais ([módulo 4](https://github.com/fnaghetini/intro-to-geostats/blob/main/4-variografia.jl));
4. Adequar o suporte amostral à escala de trabalho.

> ⚠️ A **compositagem por bancadas** busca tornar o suporte amostral igual ou próximo à altura das bancadas, ou seja, à escala de trabalho de minas à céu aberto.

Primeiramente, vamos analisar a distribuição do suporte das amostras. Para isso, utilizaremos o histograma (Figura 02), um gráfico univariado muito útil e que será discutido no [módulo 3](https://github.com/fnaghetini/intro-to-geostats/blob/main/3-analise_exploratoria.jl).
"""

# ╔═╡ 554a5530-e1ca-4261-a1e3-bf27846250fc
histogram(furos[!,:LENGTH], bins=:scott, legend=false,
		  color=:honeydew2, alpha=0.75, xlims=(0,2.6),
		  xlabel="Suporte (m)", ylabel="Freq. Absoluta")

# ╔═╡ 4d5eab4d-8510-45ed-97f9-31c6e3af6ab4
md"_**Figura 02:** Distribuição do suporte das amostras brutas._"

# ╔═╡ 99aac39c-f375-42a9-a422-ee1f7ef3a490
md"""
##### Observações

- Existem três grupos de tamanhos de amostras bem definidos: 0.5 m, 1.0 m e 2.5m;
- Como as amostras não estão regularizadas (i.e. mesmo tamanho), iremos compositá-las.
"""

# ╔═╡ e615de83-bcc4-4a84-8e94-140989508805
md"""
Utilizaremos a função `composite`, do pacote [DrillHoles.jl](https://github.com/JuliaEarth/DrillHoles.jl), para realizar a compositagem dos furos brutos. Os parâmetros dessa função são apresentados abaixo:

```julia
composite(dh, interval=1.0, zone=nothing, mode=:equalcomp, mincomp=0.5)
```

- `dh`: objeto de furos de sondagem que será compositado;
- `interval`: comprimento do intervalo das compostas (novo suporte);
- `zone`: coluna de zona. Se considerado, os intervalos só poderão ser combinados caso apresentem o mesmo valor de zona. Podemos utilizar a coluna de litologia `ROCKTYPE`, por exemplo;
- `mode`: método de compositagem;
- `mincomp`: comprimento mínimo do intervalo das compostas. Intervalos menores são descartados.

> ⚠️ Caso você tenha familiaridade com o software Studio RM da [Datamine](https://www.dataminesoftware.com/), perceberá que a função `composite` é muito similar ao processo `COMPDH`.

A seguir, aprenderemos sobre os dois principais métodos de compositagem de furos de sondagem: **comprimento fixo** e **comprimento ótimo**. Como dito anteriormente, o método de compositagem é definido pelo parâmetro `mode`.
"""

# ╔═╡ 29c1aa29-d21f-43c2-b5b4-a2c3443cc983
md"""
### Método do comprimento fixo

O **método do comprimento fixo** visa criar compostas com exatamente o mesmo comprimento `interval`. Além disso, é necessário definir um parâmetro de comprimento mínimo de composta `mincomp` que, por sua vez, é utilizado para decidir se as "bordas" das amostras serão mantidas ou descartadas. Caso as bordas possuam um comprimento inferior a `mincomp`, elas serão descartadas e, caso contrário, serão mantidas.

Perceba que, embora busque gerar compostas de tamanho fixo, a estratégia de comprimento fixo pode levar ao descarte de muitas amostras. Essa é a principal limitação deste método (*Abzalov, 2016*).

Abaixo, realizaremos uma compositagem dos furos pelo método do comprimento fixo, que é representado por `mode=:equalcomp`. O comprimento/suporte das compostas será igual a 10 metros e a coluna `ROCKTYPE` é adotada como campo de zona. O suporte mínimo `mincomp` que uma composta poderá apresentar é de 4 metros. A distribuição do suporte das compostas resultantes é apresesentada pelo histograma da Figura 03.
"""

# ╔═╡ 0bdf2bb0-655c-446a-bb79-91746a380701
begin
	# compositagem por comprimento fixo
	comps_fixo = composite(furosvalidados, interval=10.0,
						   zone=:ROCKTYPE, mode=:equalcomp, mincomp=4)
	
	# tabela de compostas
	cp_fixo = comps_fixo.table
end;

# ╔═╡ 86161dc5-0980-42e2-8455-6b1b07dddeaf
begin
	X̅_fixo = round(mean(cp_fixo.LENGTH), digits=2)
	md_fixo = round(median(cp_fixo.LENGTH), digits=2)
	
	histogram(cp_fixo[!,:LENGTH], bins=:scott, legend=:topleft,
		  	  color=:honeydew2, alpha=0.75, xlims=(3.5,11),
		  	  xlabel="Suporte (m)", ylabel="Freq. Absoluta",
			  label=false)

	vline!([X̅_fixo], color=:red, label="X̅ = $(X̅_fixo) m")
	vline!([md_fixo], color=:green, label="md = $(md_fixo) m")
end

# ╔═╡ 66b7f878-c620-4fee-84c0-273bdbc46440
md"_**Figura 03:** Distribuição do suporte das compostas resultantes do método do comprimento fixo._"

# ╔═╡ 7d398c89-f763-4d3b-b196-2949bd91ae9a
md"""
##### Observações

- A grande maioria das compostas agora apresenta suporte igual a 10 metros;
- A distribuição apresenta uma forte assimetria negativa (cauda alongada à esquerda). Esse padrão é típico quando se realiza a compositagem pelo método do comprimento fixo. Os tipos de assimetria que uma distribuição pode apresentar serão discutidos no [módulo 3](https://github.com/fnaghetini/intro-to-geostats/blob/main/3-analise_exploratoria.jl). 
"""

# ╔═╡ 62705acb-a304-4bd4-ae30-cca46037c7dd
md"""
### Método do comprimento ótimo

O **método do comprimento ótimo** parte do princípio que as amostras não devem ser descartadas. Essa estratégia faz com que todas as bordas de amostras (maiores que `mincomp`) sejam incluídas em alguma das compostas, de modo que o suporte resultante seja o mais próximo possível do comprimento `interval` definido (*Abzalov, 2016*). O comprimento máximo que uma amostra pode apresentar é igual a `1.5 × interval`.

O fato de essa estratégia ser mais flexível que o método do comprimento fixo faz com que menos amostras sejam descartadas, ainda que as compostas não apresentem um suporte exatamente igual ao `interval` definido.

A seguir, realizaremos uma compositagem dos furos pelo método do comprimento ótimo, que é representado por `mode=:nodiscard`. Para uma posterior comparação entre as estratégias, os demais parâmetros da função `composite` são configurados da mesma forma que o exemplo anterior. A distribuição do suporte das compostas resultantes é apresesentada pelo histograma da Figura 04.
"""

# ╔═╡ ddbeaaf1-a4e4-4a09-a487-9bbdc489c824
begin
	# compositagem por comprimento ótimo
	comps_otimo = composite(furosvalidados, interval=10.0,
						    zone=:ROCKTYPE, mode=:nodiscard, mincomp=4)
	
	# tabela de compostas
	cp_otimo = comps_otimo.table
end;

# ╔═╡ 59454ea0-138c-4005-9c4b-e2e8667189c2
begin
	X̅_otimo = round(mean(cp_otimo.LENGTH), digits=2)
	md_otimo = round(median(cp_otimo.LENGTH), digits=2)
	
	histogram(cp_otimo[!,:LENGTH], bins=:scott, legend=:topleft,
		  	  color=:honeydew2, alpha=0.75, xlims=(4,14),
		  	  xlabel="Suporte (m)", ylabel="Freq. Absoluta",
			  label=false)

	vline!([X̅_otimo], color=:red, label="X̅ = $(X̅_otimo) m")
	vline!([md_otimo], color=:green, label="md = $(md_otimo) m")
end

# ╔═╡ 0d9d4d97-e1ff-47a5-9a58-c76788b55468
md"_**Figura 04:** Distribuição do suporte das compostas resultantes do método do comprimento ótimo._"

# ╔═╡ 959927f2-74b6-411d-89f8-034c031d7422
md"""
##### Observações

- A grande maioria das compostas agora apresenta comprimentos entre 9 e 11 metros;
- A distribuição é aproximadamente simétrica. Esse padrão é típico quando se realiza a compositagem pelo método do comprimento ótimo.
"""

# ╔═╡ d50d76db-507e-450e-93a1-e0319edaf98a
md"""
### Comparação entre os algoritmos

Até o momento, já aprendemos que:

> O **método do comprimento fixo**, por ser mais rígido, pode resultar no descarte de muitas amostras. A distribuição do tamanho das compostas é tipicamente assimétrica negativa.

> O **método do comprimento ótimo**, ainda que não gere compostas de suporte fixo, mitiga o descarte de amostras. A distribuição do tamanho das compostas é aproximadamente simétrica.

Ademais, podemos realizar uma comparação estatística entre as amostras brutas e as compostas resultantes de ambos os métodos. Para isso, iremos considerar os seguintes critérios (*Abzalov, 2016*):
1. Metragem total de amostras;
2. Desvio padrão do comprimento das amostras;
3. Média do teor de Au (g/t).

Idealmente, a metragem total das compostas deve coincidir com a das amostras brutas. Para o cálculo da metragem total, utilizaremos a função `sum`.

Como o objetivo da compositagem é regularizar o suporte amostral, a variabilidade (dispersão) do comprimento das amostras `LENGTH` deve ser reduzida. Mediremos essa variabilidade com a função `std`, que representa o desvio padrão.

A compositagem não deve alterar significativamente o teor metalífero médio das amostras. Qualquer mudança superior a 5% deve ser investigada (*Abzalov, 2016*). Para o cálculo do teor médio de Au (g/t), utilizaremos a função `mean`.

Vamos criar uma função `compvalid` que remova eventuais valores faltantes de Au (para o cálculo do teor médio) e retorne um sumário estatístico com essas três informações... 
"""

# ╔═╡ 3d52dfab-40d2-4947-9dfe-cc4e6100d75c
function compvalid(amostras::DataFrame, id::String)
	
	s = amostras |> @dropna(:AU) |> DataFrame
	
	report = DataFrame(Amostras   = id,
					   Metragem   = sum(amostras.LENGTH),
					   DP_suporte = std(amostras.LENGTH),
					   Média_Au   = mean(s.AU))
	return report
end

# ╔═╡ 98d43ce9-d4a6-4b5f-8777-a0af67eddf9f
md"""
Agora podemos aplicar a função `compvalid` para calcular as estatísticas de cada um dos grupos de amostras (i.e. brutas, compostas fixas e compostas ótimas) e concatenar (verticalmente) as medidas em uma única tabela. Essa concatenação é bastante intuitiva...
"""

# ╔═╡ 58fd4e5b-da58-4cf1-8c99-32892a146bdd
[compvalid(furos, "Brutas")
 compvalid(cp_fixo, "Comp. Fixo")
 compvalid(cp_otimo, "Comp. Ótimo")]

# ╔═╡ 5431903b-e7b0-47f8-a225-9db66468256e
md"""
##### Observações

- Quando se compara a metragem de amostras brutas com a metragem das compostas, nota-se que, na estratégia do comprimento fixo, mais amostras foram descartadas (185 metros) do que no método do comprimento ótimo (9,5 metros);
- O método do comprimento fixo aumentou a dispersão do comprimento das amostras, enquanto a estratégia do comprimento ótimo reduziu;
- Há uma redução no teor médio de Au após a compositagem pelos dois métodos. Essa redução já era esperada, uma vez que, ao combinar as amostras, há uma diluição dos teores. Entretanto, a mudança na média não foi tão expressiva em ambos os casos (< 3%);
- Pelo menos neste exemplo, o algoritmo do comprimento ótimo mostrou uma melhor performance na compositagem do que a estratégia do comprimento fixo. Ainda sim, sugere-se sempre comparar ambos métodos, se possível.
"""

# ╔═╡ 447e2730-0bd4-4953-ac2e-c6d12cb5e341
md"""
## 4. Visualização dos furos

Agora que realizamos a comparação entre os dois métodos de compositagem e escolhemos as compostas ótimas, podemos visualizá-las interativamente com o pacote [Makie.jl](https://github.com/JuliaPlots/Makie.jl). Esse pacote fornece incríveis recursos interativos de visualização 3D!

Neste notebook, adotaremos o backend [WGLMakie](https://github.com/JuliaPlots/Makie.jl/tree/master/WGLMakie), por ser interativo e compatível com o visualizações no navegador.

> ⚠️ Caso queira aprender como configurar esse backend, clique no ícone 👁️ para exibir o conteúdo das duas primeiras células deste notebook.

Clique na caixa abaixo para visualizar os teores compostos de Au (Figura 05)...

> ⚠️ Ao clicar pela primeira vez, a exibição do plot pode demorar alguns segundos. Entretanto, nos próximos cliques, as compostas serão exibidas instantaneamente! Caso não queira mais visualizá-las, desmarque a caixa para não tornar lenta a execução das demais células.
"""

# ╔═╡ baf8bd0f-07b7-4ce6-8850-4f22c4a20ecf
md"""
Visualizar furos $(@bind viz_furos CheckBox())
"""

# ╔═╡ dbddc346-e9dd-416d-abf5-98d96a95f3ec
begin
	if viz_furos
		# remoção de valores faltantes
		furos_viz = cp_otimo |> @dropna(:AU) |> DataFrame
		
		# visualização dos furos
		fig, ax, p = meshscatter(furos_viz.X, furos_viz.Y, furos_viz.Z,
								 color=furos_viz.AU, markersize=8)
		
		Colorbar(fig[1, 2], p, label="Au (g/t)")
		
		fig
	end
end

# ╔═╡ d9cd1583-abec-4dc1-a9db-5bbcf74a48c8
if viz_furos
	md"""_**Figura 05:** Visualização dos teores compostos de Au (método do comprimento ótimo)._"""
end

# ╔═╡ 96ae1d18-a0fd-4846-9d4a-843952e14caa
md"""
## Referências

*Abzalov, M. [Applied mining geology](https://www.google.com.br/books/edition/Applied_Mining_Geology/Oy3RDAAAQBAJ?hl=pt-BR&gbpv=0). Switzerland: Springer International Publishing, 2016*

*Sinclair, A. J.; Blackwell, G. H. [Applied mineral inventory estimation](https://www.google.com.br/books/edition/Applied_Mineral_Inventory_Estimation/oo7rCrFQJksC?hl=pt-BR&gbpv=0). New York: Cambridge University Press, 2006.*

*Whittle, G.; Stange, W.; Hanson, N. [Optimising project value and robustness](https://www.whittleconsulting.com.au/wp-content/uploads/2017/03/Optimising-Project-Value-and-Robustness.pdf). In: Project Evaluation Conference, v.1, 2007. 147-155.*

*Yamamoto, J. K. [Avaliação e classificação de reservas minerais](https://www.google.com.br/books/edition/Avalia%C3%A7%C3%A3o_e_classifica%C3%A7%C3%A3o_de_reserva/AkmsTIzmblQC?hl=pt-BR&gbpv=0). São Paulo: Editora da Universidade de São Paulo, 2001*.
"""

# ╔═╡ 0b874268-8410-43fd-9c60-d13e4f2eec0b
md"""
## Recursos adicionais

Um outro tópico importante na fase de preparação de amostras é o *top cut*, comumente chamado de *capping* ou "capeamento". Ainda que esse assunto esteja fora do escopo deste notebook, o podcast abaixo é uma excelente introdução ao tema! 

> [Podcast Top Cut - Optiro Mining Industry Consultants](https://open.spotify.com/episode/6Wbho2xFwntNVrU86t32KJ)
"""

# ╔═╡ 6f69c80c-aafc-4db1-bd64-41d5112287fb
md"""
## Pacotes utilizados

Os seguintes pacotes foram utilizados neste notebook:

|                       Pacote                             |        Descrição        |
|:--------------------------------------------------------:|:-----------------------:|
|[JSServe](https://github.com/SimonDanisch/JSServe.jl)     | Aplicações interativas  |
|[DrillHoles](https://github.com/JuliaEarth/DrillHoles.jl) | Furos de sondagem       |
|[Statistics](https://docs.julialang.org/en/v1/)           | Cálculo de estatísticas |
|[PlutoUI](https://github.com/fonsp/PlutoUI.jl)            | Widgets interativos     |
|[DataFrames](https://github.com/JuliaData/DataFrames.jl)  | Manipulação de tabelas  |
|[Query](https://github.com/queryverse/Query.jl)           | Realização de consultas |
|[Plots](https://github.com/JuliaPlots/Plots.jl)           | Visualização dos dados  |
|[WGLMakie](https://github.com/JuliaPlots/Makie.jl)        | Plotagem interativa     |

"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DrillHoles = "9d36f3b5-8124-4f7e-bcda-df733105c718"
JSServe = "824d6782-a2ef-11e9-3a09-e5662e0c26f9"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Query = "1a8c2f83-1ff3-5112-b086-8aa67b057ba1"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
WGLMakie = "276b4fcb-3e11-5398-bf8b-a0c2d153d008"

[compat]
DataFrames = "~1.2.2"
DrillHoles = "~0.1.4"
JSServe = "~1.2.3"
Plots = "~1.22.6"
PlutoUI = "~0.7.16"
Query = "~1.0.0"
WGLMakie = "~0.4.6"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[Animations]]
deps = ["Colors"]
git-tree-sha1 = "e81c509d2c8e49592413bfb0bb3b08150056c79d"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArrayInterface]]
deps = ["Compat", "IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "b8d49c34c3da35f220e7295659cd0bab8e739fed"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.1.33"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Automa]]
deps = ["Printf", "ScanByte", "TranscodingStreams"]
git-tree-sha1 = "d50976f217489ce799e366d9561d56a98a30d7fe"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "0.8.2"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

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

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "2f294fae04aa5069a67964a3366e151e09ea7c09"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.9.0"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[ColorBrewer]]
deps = ["Colors", "JSON", "Test"]
git-tree-sha1 = "61c5334f33d91e570e1d0c3eb5465835242582c4"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.0"

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

[[ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "45efb332df2e86f2cb2e992239b6267d97c9e0b6"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.7"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "31d0151f5716b655421d9d75b7fa74cc4e744df2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.39.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

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

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

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

[[FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "cabd77ab6a6fdff49bfd24af2ebe76e6e018a2b4"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.0.0"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FreeTypeAbstraction]]
deps = ["ColorVectorSpace", "Colors", "FreeType", "GeometryBasics", "StaticArrays"]
git-tree-sha1 = "19d0f1e234c13bbfd75258e55c52aa1d876115f5"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.9.2"

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

[[Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "1c5a84319923bea76fa145d49e93aa4394c73fc2"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.1"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Match", "Observables"]
git-tree-sha1 = "e2f606c87d09d5187bb6069dab8cee0af7c77bdb"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.6.1"

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

[[ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "9a5c62f231e5bba35695a20988fc7cd6de7eeb5a"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.3"

[[ImageIO]]
deps = ["FileIO", "Netpbm", "OpenEXR", "PNGFiles", "TiffImages", "UUIDs"]
git-tree-sha1 = "13c826abd23931d909e4c5538643d9691f62a617"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.5.8"

[[ImageMagick]]
deps = ["FileIO", "ImageCore", "ImageMagick_jll", "InteractiveUtils", "Libdl", "Pkg", "Random"]
git-tree-sha1 = "5bc1cb62e0c5f1005868358db0692c994c3a13c6"
uuid = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
version = "1.2.1"

[[ImageMagick_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "ea2b6fd947cdfc43c6b8c15cff982533ec1f72cd"
uuid = "c73af94c-d91f-53ed-93a7-00f77d67a9d7"
version = "6.9.12+0"

[[Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "87f7662e03a649cffa2e05bf19c303e168732d3e"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.2+0"

[[IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[Inflate]]
git-tree-sha1 = "f5fc07d4e706b84f72d54eedcc1c13d92fb0871c"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.2"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

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

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
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

[[JSON3]]
deps = ["Dates", "Mmap", "Parsers", "StructTypes", "UUIDs"]
git-tree-sha1 = "7d58534ffb62cd947950b3aa9b993e63307a6125"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.9.2"

[[JSServe]]
deps = ["Base64", "CodecZlib", "Colors", "HTTP", "Hyperscript", "JSON3", "LinearAlgebra", "Markdown", "MsgPack", "Observables", "SHA", "Sockets", "Tables", "Test", "UUIDs", "WebSockets", "WidgetsBase"]
git-tree-sha1 = "91101a4b8ac8eefeed6ca8eb4f663fc660e4d9f9"
uuid = "824d6782-a2ef-11e9-3a09-e5662e0c26f9"
version = "1.2.3"

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
git-tree-sha1 = "95d36f32dde312e694c1de5714821efc4b010815"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.7"

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

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

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "5455aef09b40e5020e1520f551fa3135040d4ed0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+2"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "5a5bc6bf062f0f95e62d0fe0a2d99699fed82dd9"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.8"

[[Makie]]
deps = ["Animations", "Base64", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "Contour", "Distributions", "DocStringExtensions", "FFMPEG", "FileIO", "FixedPointNumbers", "Formatting", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageIO", "IntervalSets", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MakieCore", "Markdown", "Match", "MathTeXEngine", "Observables", "Packing", "PlotUtils", "PolygonOps", "Printf", "Random", "RelocatableFolders", "Serialization", "Showoff", "SignedDistanceFields", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "UnicodeFun"]
git-tree-sha1 = "7e49f989e7c7f50fe55bd92d45329c9cf3f2583d"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.15.2"

[[MakieCore]]
deps = ["Observables"]
git-tree-sha1 = "7bcc8323fb37523a6a51ade2234eee27a11114c8"
uuid = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
version = "0.1.3"

[[MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[Match]]
git-tree-sha1 = "5cf525d97caf86d29307150fcba763a64eaa9cbe"
uuid = "7eb4fadd-790c-5f42-8a69-bfa0b872bfbf"
version = "1.1.0"

[[MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "Test"]
git-tree-sha1 = "70e733037bbf02d691e78f95171a1fa08cdc6332"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.2.1"

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

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "b34e3bc3ca7c94914418637cb10cc4d1d80d877d"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.3"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[MsgPack]]
deps = ["Serialization"]
git-tree-sha1 = "a8cbf066b54d793b9a48c5daa5d586cf2b5bd43d"
uuid = "99f44e22-a591-53d1-9472-aa23ef4bd671"
version = "1.1.0"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[Netpbm]]
deps = ["FileIO", "ImageCore"]
git-tree-sha1 = "18efc06f6ec36a8b801b23f076e3c6ac7c3bf153"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.2"

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

[[OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "923319661e9a22712f24596ce81c54fc0366f304"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.1+0"

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

[[PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "85e3436b18980e47604dd0909e37e2f066f54398"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.10"

[[Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "1155f6f937fa2b94104162f01fa400e192e4272f"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.4.2"

[[PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "646eed6f6a5d8df6708f15ea7e02a7a2c4fe4800"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.10"

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

[[PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "a7a7e1a88853564e551e4eba8650f8c38df79b37"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.1.1"

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

[[PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a193d6ad9c45ada72c14b731a318bedd3c2f00cf"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.3.0"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "69fd065725ee69950f3f58eceb6d144ce32d627d"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "afadeba63d90ff223a6a48d2009434ecee2ec9e8"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.1"

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

[[RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "df2be5142a2a3db2da37b21d87c9fa7973486bfd"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.1.2"

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

[[SIMD]]
git-tree-sha1 = "9ba33637b24341aba594a2783a502760aa0bff04"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.3.1"

[[ScanByte]]
deps = ["Libdl", "SIMD"]
git-tree-sha1 = "9cc2955f2a254b18be655a4ee70bc4031b2b189e"
uuid = "7b38b023-a4d7-4c5e-8d43-3f3097f304eb"
version = "0.3.0"

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

[[ShaderAbstractions]]
deps = ["ColorTypes", "FixedPointNumbers", "GeometryBasics", "LinearAlgebra", "Observables", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "0d97c895406b552bed78f3a1fe9925248e908ae2"
uuid = "65257c39-d410-5151-9873-9b3e5be5013e"
version = "0.2.8"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[SignedDistanceFields]]
deps = ["Random", "Statistics", "Test"]
git-tree-sha1 = "d263a08ec505853a5ff1c1ebde2070419e3f28e9"
uuid = "73760f76-fbc4-59ce-8f25-708e95d2df96"
version = "0.4.0"

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
git-tree-sha1 = "793793f1df98e3d7d554b65a107e9c9a6399a6ed"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.7.0"

[[StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

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
git-tree-sha1 = "95072ef1a22b057b1e80f73c2a89ad238ae4cfff"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.12"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "d24a825a95a6d98c385001212dc9020d609f2d4f"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.8.1"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

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

[[TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TiffImages]]
deps = ["ColorTypes", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "OffsetArrays", "OrderedCollections", "PkgVersion", "ProgressMeter"]
git-tree-sha1 = "945b8d87c5e8d5e34e6207ee15edb9d11ae44716"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.4.3"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[WGLMakie]]
deps = ["Colors", "FileIO", "FreeTypeAbstraction", "GeometryBasics", "Hyperscript", "ImageMagick", "JSServe", "LinearAlgebra", "Makie", "Observables", "ShaderAbstractions", "StaticArrays"]
git-tree-sha1 = "bafa1c4ab77626f8d8199209b740e097ae03805f"
uuid = "276b4fcb-3e11-5398-bf8b-a0c2d153d008"
version = "0.4.6"

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

[[WebSockets]]
deps = ["Base64", "Dates", "HTTP", "Logging", "Sockets"]
git-tree-sha1 = "f91a602e25fe6b89afc93cf02a4ae18ee9384ce3"
uuid = "104b5d7c-a370-577a-8038-80a2059c5097"
version = "1.5.9"

[[WidgetsBase]]
deps = ["Observables"]
git-tree-sha1 = "c1ef6e02bc457c3b23aafc765b94c3dcd25f174d"
uuid = "eead4739-05f7-45a1-878c-cee36b57321c"
version = "0.1.3"

[[WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "9398e8fefd83bde121d5127114bd3b6762c764a6"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.4"

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

[[isoband_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "a1ac99674715995a536bbce674b068ec1b7d893d"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.2+0"

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
# ╟─e50f4dc1-99db-439d-9357-fcf523a7f50a
# ╟─9ca215d0-2e8c-11ec-27ae-3bac6ad63ae1
# ╟─d380ac0f-28a7-48f4-8463-9dbdf7f66a16
# ╟─ebaf4b98-9f4a-45bc-ad35-54448f26f90c
# ╟─ffdbdfbd-8627-48d9-8e9c-384455b64ed4
# ╟─b9b5f9a4-431d-40fc-94fe-8d622ba7c5a8
# ╟─eedd9f9b-6425-4b8c-ad1f-7bbedc122072
# ╟─aa0a8370-7919-41e1-9a05-481df4e48ec7
# ╟─6c867bb6-87d6-420f-8665-fe4581ffd0a9
# ╟─a5bc3c03-856b-4ee2-a71c-8c7e1fe3c641
# ╟─ae22a6f0-d857-4229-a003-728d43a50d46
# ╟─51199548-4ec2-4034-b955-8d1f97ddd5ee
# ╟─dd89a21f-ce6b-4a3c-9c22-1f97ac3863a8
# ╠═9ce42874-5a58-4e6a-a544-dfea97146cc2
# ╟─f9fa9a2f-8099-434e-a76c-4b78160f264a
# ╠═1e71d41a-5717-462d-81da-8ac35f22c1db
# ╟─1673eef5-82cf-4eef-8ca2-17d02ecb9b27
# ╠═63ab68f1-b342-4e8c-987d-4fc33166aa3c
# ╟─6e2e4df4-096b-444f-bff3-44c70f3d1dd5
# ╠═6b7b4fbe-622e-407c-8ffc-9fe888354ced
# ╟─f16c8b13-256d-4c1d-a376-4e7d41ecf35d
# ╠═0aed3ddb-b181-4f03-950c-b23e0f153760
# ╟─10f1c03f-ead5-42c5-a5c5-816d52a15653
# ╠═9929fafa-2bc5-4fec-83a4-c8f9b1229b0c
# ╟─b1ec589e-35af-4e34-a663-c72f4b0afe02
# ╠═bfbe894b-a205-4d21-8adf-a26a2052573e
# ╟─48e9011a-dfa3-4665-9e23-2aab30e0d294
# ╟─3f55ecbb-8f26-4813-ac3e-97588830d987
# ╟─c3e6a7e8-c4a2-42ad-9302-cd4be7ee0920
# ╟─554a5530-e1ca-4261-a1e3-bf27846250fc
# ╟─4d5eab4d-8510-45ed-97f9-31c6e3af6ab4
# ╟─99aac39c-f375-42a9-a422-ee1f7ef3a490
# ╟─e615de83-bcc4-4a84-8e94-140989508805
# ╟─29c1aa29-d21f-43c2-b5b4-a2c3443cc983
# ╠═0bdf2bb0-655c-446a-bb79-91746a380701
# ╟─86161dc5-0980-42e2-8455-6b1b07dddeaf
# ╟─66b7f878-c620-4fee-84c0-273bdbc46440
# ╟─7d398c89-f763-4d3b-b196-2949bd91ae9a
# ╟─62705acb-a304-4bd4-ae30-cca46037c7dd
# ╠═ddbeaaf1-a4e4-4a09-a487-9bbdc489c824
# ╟─59454ea0-138c-4005-9c4b-e2e8667189c2
# ╟─0d9d4d97-e1ff-47a5-9a58-c76788b55468
# ╟─959927f2-74b6-411d-89f8-034c031d7422
# ╟─d50d76db-507e-450e-93a1-e0319edaf98a
# ╠═3d52dfab-40d2-4947-9dfe-cc4e6100d75c
# ╟─98d43ce9-d4a6-4b5f-8777-a0af67eddf9f
# ╠═58fd4e5b-da58-4cf1-8c99-32892a146bdd
# ╟─5431903b-e7b0-47f8-a225-9db66468256e
# ╟─447e2730-0bd4-4953-ac2e-c6d12cb5e341
# ╟─baf8bd0f-07b7-4ce6-8850-4f22c4a20ecf
# ╟─dbddc346-e9dd-416d-abf5-98d96a95f3ec
# ╟─d9cd1583-abec-4dc1-a9db-5bbcf74a48c8
# ╟─96ae1d18-a0fd-4846-9d4a-843952e14caa
# ╟─0b874268-8410-43fd-9c60-d13e4f2eec0b
# ╟─6f69c80c-aafc-4db1-bd64-41d5112287fb
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
