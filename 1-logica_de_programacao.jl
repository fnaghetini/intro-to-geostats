### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ 75fe8fd0-2563-11ec-30ef-d15cdc3d4e63
using PlutoUI

# ╔═╡ d4b5618f-f1a7-4483-b738-fb94e1e2bbbe
html"""
<p style="background-color:lightgrey" xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><span property="dct:title">&nbsp&nbsp<b>Lógica de Programação</b></span> por <span property="cc:attributionName">Franco Naghetini</span> é licenciado sob <a href="http://creativecommons.org/licenses/by/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1"></a></p>
"""

# ╔═╡ deee1735-37ee-4c97-a4df-8fcb61e95d6a
PlutoUI.TableOfContents(aside=true, title="Sumário",
						indent=true, depth=2)

# ╔═╡ 488dcacd-109d-41f2-b904-3d17193e6190
md"""

![ufmg-logo](https://logodownload.org/wp-content/uploads/2015/02/ufmg-logo-2.png)

"""

# ╔═╡ 6ca3e113-02db-4cef-ad9e-3941ac7d7a6d
md"""

# 💻 Lógica de Programação

O ato de **programar** pode ser entendido como uma forma de se comunicar com as máquinas a partir de um conjunto de instruções não ambíguas com o intuito de se realizar uma determinada tarefa. Essa comunicação com as máquinas é realizada por meio das **linguagens de programação**, como Python, R, C e Julia.

Nesse contexto, a **lógica de programação** é de suma importância, uma vez que ela define a estrutura das instruções dadas às máquinas, ou seja, define a forma que você se comunica com as máquinas. Se quer aprender mais sobre a importância da lógica de programação assista [este vídeo](https://www.youtube.com/watch?v=l7lIPXij85I) do canal Programação Dinâmica.

Neste módulo, estudaremos alguns conceitos básicos de lógica de programação. Para isso, utilizaremos [Julia](https://julialang.org/), uma linguagem de programação moderna e de propósito geral que possui diversos recursos favoráveis ao desenvolvimento de rotinas geoestatísticas.

> A linguagem é *simples* como Python e *rápida* como C 🚀

A seguir, serão apresentados alguns conceitos básicos de lógica de programação, além de uma introdução sobre os recursos interativos da linguagem Julia: 

1. Variáveis
2. Funções
3. Coleções
4. Condicionais
5. Laços
6. Interatividade

"""

# ╔═╡ c111da75-d294-4def-93fb-56953c3585ad
md"""

## 1. Variáveis

As **variáveis** podem ser entendidas como partes da memória (ou "caixas") onde se armazena **valores** de diferentes **tipos** para serem posteriormente processados. Cada variável é identificada/rotulada por um **nome**.

As variáveis podem ser **numéricas**...

"""

# ╔═╡ 7ceb9c27-0310-4f97-8349-91286c1f9235
numero_inteiro = 10

# ╔═╡ 218bb8c3-729b-43c7-9a53-d3b579cf2d21
numero_decimal = 15.5

# ╔═╡ 3b3e6955-1573-4620-8109-d80b71cf0708
md" As variáveis podem armazenar **cadeias de caracteres**... "

# ╔═╡ f2e6adcd-9095-496f-a8e3-88069537015c
nome = "Camila"

# ╔═╡ 870cbb76-b0c3-4d14-be22-86e0d34ebe58
frase = "Olá, mundo! 🌎"

# ╔═╡ 55a2c622-0f9f-45db-b534-55873c0759d4
md"""

> **Nota:** as cadeias de caracteres (**strings**) devem ser encapsuladas por áspas duplas.

"""

# ╔═╡ 4d31b989-7a7d-43ca-a1f8-831db58f1c8e
md"""

Podemos utilizar *símbolos matemáticos* como nomes das variáveis. Para inserir o símbolo $\alpha$, por exemplo, digita-se `\alpha` + `TAB`. No caso do símbolo $\gamma$, digita-se `\gamma` + `TAB`.

Cique [aqui](https://docs.julialang.org/en/v1/manual/unicode-input/) para acessar a lista completa de símbolos disponíveis.

"""

# ╔═╡ b0d01238-1213-45c3-9bef-a443afc6b87c
β = 2.0

# ╔═╡ 2cce4c5e-7890-4c6c-bd7c-eecc8437bef3
ϵ = 0.5

# ╔═╡ 1b454935-c858-4817-928d-da116011d7b0
β + ϵ

# ╔═╡ 96ced3bd-69e7-490c-b8be-b06a30049a31
π

# ╔═╡ d28119c3-6800-430d-9ffe-d6f25e8e5c2a
md"""
## 2. Funções

As **funções**, no mundo da computação, são similares às funções matemáticas. De forma geral, uma função recebe valores de **entrada**, processa-os e retorna valores de **saída**.

Em Julia, existem, essencialmente, três maneiras distintas de se construir funções:

"""

# ╔═╡ bb495116-8ff9-4a66-9b66-6f6fe990c5d9
f(χ) = 5χ + 25

# ╔═╡ a63d4a04-0ceb-4e4f-90ba-30dc798e1b48
function areatriangulo(b,h)
	A = (b * h) / 2
	return A
end

# ╔═╡ 5b168a45-b5a2-4415-80f4-e2347c21730a
diagonal = l -> l * √2

# ╔═╡ 1a1ac9a0-b8f0-46d1-9d89-21b6bc0e6aec
f(2) + areatriangulo(10,4) / diagonal(1)

# ╔═╡ 784426f8-ac63-4555-adb2-cbfb9b37fdda
md"""
#### 🖊️ Exercício

Crie uma função `recurso` que retorne a tonelagem em metal contido de um depósito de volume `V`, densidade média `ρ` e teor médio `T` (em %).

"""

# ╔═╡ ffc5e222-8ae8-4314-a616-e4588d7808fe
recurso(V, ρ, T) = missing

# ╔═╡ 5dc76f3b-badf-4951-9eb4-f61ca66dfb98
md"""
## 3. Coleções

As **coleções** são conjuntos de elementos, normalmente do mesmo tipo, mas não necessariamente. São exemplos *vetores*, *matrizes* e *tensores*.

Os **vetores** podem ser escritos como...

"""

# ╔═╡ d349ac4d-44bb-4505-a6c4-3096d8c48ba0
vetor1 = [1,2,3,4,5,6,7,8,9,10]

# ╔═╡ 9e181c4a-a759-4f92-8444-6a23387a20b9
vetor_2 = collect(10:20)

# ╔═╡ d39f503a-158e-4774-851e-d786014b8f2b
md" As **matrizes** podem ser escritas como... "

# ╔═╡ b5387324-df28-422d-8e74-4fefa8054e7f
A = [1 2
	 3 4]

# ╔═╡ 570f62db-edd7-429d-a084-2686f4b6923c
B = [1 2 3; 4 5 6; 7 8 9]

# ╔═╡ 7e8a4e33-0e9c-45f5-b8bc-e2adece0806d
md" Os **tensores** podem ser escritos como... "

# ╔═╡ 204bcedc-4123-4845-bcac-493ce3544582
tensor_de_zeros = zeros(5,5,2)

# ╔═╡ 92b0cb5f-41a1-420f-8b81-3b967db8138f
tensor_de_uns = ones(2,2,3)

# ╔═╡ 7471120d-6e00-46be-be11-649c8cdbb32c
md"""
Uma operação muito utilizada é o **fatiamento**, que visa obter apenas certo(s) elemento(s) de uma coleção. O fatiamento de vetores, por exemplo, é realizado a partir da seguinte sintaxe:

```julia
vetor[índice inicial:índice final]
```

Observe o vetor `v₁`...

"""

# ╔═╡ b31b883d-5a69-4e04-b8b5-cedca81dcf9a
v₁ = [10,20,30,40,50,60,70,80,90,100]

# ╔═╡ c7f94dcd-64a2-4e97-b38d-363dc6f9f757
md" O primeiro elemento pode ser obtido a partir do fatiamento de `v₁`..."

# ╔═╡ 2a25a884-44cf-4460-ab23-02e728201f90
v₁[1]

# ╔═╡ e127bdf8-2a53-4534-a628-1463a5735f41
md"""

> **Nota:** Assim como *R* e diferentemente de *Python* ou *Java Script*, a numeração do índice se inicia em **1** na linguagem *Julia*.

Os três primeiros elementos de `v₁` podem ser obtidos como...

"""

# ╔═╡ 0806feb3-33eb-402c-92d2-af0b153834ba
v₁[1:3]

# ╔═╡ 1a5f467b-7244-4587-b01c-61fd22bfbb9b
v₁[begin:3]

# ╔═╡ 4b1ec558-5f94-417a-aa3c-d13a0039a6a0
md" Os dois últimos elementos de `v₁` podem ser obtidos como..."

# ╔═╡ 6bee210a-11cc-40c4-bfb0-d14a6b2495b4
v₁[9:10]

# ╔═╡ 10cc97dd-a390-4d4a-9644-20b654ff66bb
v₁[end-1:end]

# ╔═╡ 04738501-16fa-43e1-b640-47682c155bcb
md"""

#### 🖊️ Exercício

Fatie o vetor `v₂`, de modo que apenas os elementos da terceira posição em diante sejam retornados. A fatia resultante deve ser armazenada na variável `v₃`.

"""

# ╔═╡ f9317c0c-2389-43a8-8b91-f8b2f278e258
begin
	v₂ = collect(10:15)
	v₃ = missing
end

# ╔═╡ 8253149c-e1b0-4e3f-9f5b-909621dba86e
md"""
## 4. Condicionais

As **estruturas condicionais** são utilizadas em situações em que se deseja executar algum trecho de código apenas quando uma **condição** é satisfeita:

```julia
if quartzo < 20
   rochaignea != "granitoide"
else
   rochaignea = "granitoide"
end
```

"""

# ╔═╡ 1f0abfbe-49cd-4529-8f4d-65f8286b6f0e
md"""

#### 🖊️ Exercício

Crie uma função `tiporocha` que recebe o nome de uma rocha e retorna o seu tipo:

* "gabro" → "ígnea"
* "gnaisse" → "metamórfica"
* "ritmito" → "sedimentar"

"""

# ╔═╡ 6fcc1433-c348-4825-8503-782304ed508b
function tiporocha(rocha)
	missing
end

# ╔═╡ 3cfbddfb-be59-4019-965f-13bdbac2295a
md"""

## 5. Laços

"""

# ╔═╡ aac164f5-6209-4d4e-a135-a848593f0c25


# ╔═╡ 525cd275-7b36-4d77-bbbf-d7b75fdcd2b6


# ╔═╡ 0029b8a6-e44b-4005-8eb1-d81253f93332


# ╔═╡ f8f272e0-17ca-47e5-8dd0-577eb6322c90
md"""

## 6. Interatividade

"""

# ╔═╡ e137bf5e-d795-49ac-b641-b5f7364cfac9


# ╔═╡ fae5e284-66e7-4599-9905-f0d5e64387ea


# ╔═╡ a9c9cbbe-1e74-46d9-b1cc-fd60e6c2cc41


# ╔═╡ bb899ab7-b3d8-493f-aaa6-85a4710a6690
begin
	hint(text) = Markdown.MD(Markdown.Admonition("hint", "Dica", [text]))

	almost(text) = Markdown.MD(Markdown.Admonition("warning", "Quase lá!", [text]))

	still_missing(text=md"Troque `missing` pela sua resposta.") = Markdown.MD(Markdown.Admonition("warning", "Aqui vamos nós!", [text]))

	keep_working(text=md"A resposta não está totalmente certa.") = Markdown.MD(Markdown.Admonition("danger", "Continue trabalhando!", [text]))

	yays = [md"Fantástico!", md"Ótimo!", md"Yay ❤", md"Legal! 🎉", md"Muito bem!", md"Bom trabalho!", md"Você conseguiu a resposta certa!", md"Vamos seguir para próxima seção."]

	correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Certa resposta!", [text]))

	not_defined(variable_name) = Markdown.MD(Markdown.Admonition("danger", "Opa!", [md"Tenha certeza que definiu uma variável chamada **$(Markdown.Code(string(variable_name)))**"]))
end;

# ╔═╡ a4f3b825-6806-4c64-bbe0-6d7383015d68
begin
	s1 = false
	_rec = recurso(12500000,2.7,5)
	if ismissing(_rec)
		still_missing()
	elseif _rec ≈ (12500000 * 2.7 * 5) / 100
		s1 = true
		correct()
	elseif _rec isa Number
		almost(md"A fórmula não está certa...")
	else
		keep_working()
	end
end

# ╔═╡ 3ccac0bc-9f78-4ece-988b-ba832811e538
hint(md"Alguém me contou que a fórmula é $\frac{VρT}{100}$...")

# ╔═╡ a84b90c1-fa85-499a-9fa4-ac1f33ed8469
begin
	s2 = false
	if ismissing(v₃)
		still_missing()
	elseif v₃ == v₂[3:end]
		s2 = true
		correct()
	else
		keep_working()
	end
end

# ╔═╡ e2c42c9e-abbb-4a33-844d-ef0f0c9b4939
hint(md"Utilize `end` como índice final.")

# ╔═╡ 33b81b24-ca33-4dd3-a85e-0371ca8623e8
begin
	s3 = false
	_rcktype = tiporocha.(["gabro","gnaisse","ritmito"])
	if all(ismissing.(_rcktype))
		still_missing()
	elseif all(_rcktype .== ["ígnea","metamórfica","sedimentar"])
		s3 = true
		correct()
	elseif _rcktype ⊆ ["ígnea","metamórfica","sedimentar"]
		almost(md"A resposta não está 100% correta...")
	else
		keep_working()
	end
end

# ╔═╡ e462ca14-b38a-46b0-8faa-2261a2cfc150
hint(md"Basta escrever uma sequência de `if rocha == \"gabro\" return \"ígnea\" end`")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.14"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[HypertextLiteral]]
git-tree-sha1 = "72053798e1be56026b81d4e2682dbe58922e5ec9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.0"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "a8709b968a1ea6abc2dc1967cb1db6ac9a00dfb6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.5"

[[PlutoUI]]
deps = ["Base64", "Dates", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "d1fb76655a95bf6ea4348d7197b22e889a4375f4"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.14"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
"""

# ╔═╡ Cell order:
# ╟─75fe8fd0-2563-11ec-30ef-d15cdc3d4e63
# ╟─d4b5618f-f1a7-4483-b738-fb94e1e2bbbe
# ╟─deee1735-37ee-4c97-a4df-8fcb61e95d6a
# ╟─488dcacd-109d-41f2-b904-3d17193e6190
# ╟─6ca3e113-02db-4cef-ad9e-3941ac7d7a6d
# ╟─c111da75-d294-4def-93fb-56953c3585ad
# ╠═7ceb9c27-0310-4f97-8349-91286c1f9235
# ╠═218bb8c3-729b-43c7-9a53-d3b579cf2d21
# ╟─3b3e6955-1573-4620-8109-d80b71cf0708
# ╠═f2e6adcd-9095-496f-a8e3-88069537015c
# ╠═870cbb76-b0c3-4d14-be22-86e0d34ebe58
# ╟─55a2c622-0f9f-45db-b534-55873c0759d4
# ╟─4d31b989-7a7d-43ca-a1f8-831db58f1c8e
# ╠═b0d01238-1213-45c3-9bef-a443afc6b87c
# ╠═2cce4c5e-7890-4c6c-bd7c-eecc8437bef3
# ╠═1b454935-c858-4817-928d-da116011d7b0
# ╠═96ced3bd-69e7-490c-b8be-b06a30049a31
# ╟─d28119c3-6800-430d-9ffe-d6f25e8e5c2a
# ╠═bb495116-8ff9-4a66-9b66-6f6fe990c5d9
# ╠═a63d4a04-0ceb-4e4f-90ba-30dc798e1b48
# ╠═5b168a45-b5a2-4415-80f4-e2347c21730a
# ╠═1a1ac9a0-b8f0-46d1-9d89-21b6bc0e6aec
# ╟─784426f8-ac63-4555-adb2-cbfb9b37fdda
# ╠═ffc5e222-8ae8-4314-a616-e4588d7808fe
# ╟─a4f3b825-6806-4c64-bbe0-6d7383015d68
# ╟─3ccac0bc-9f78-4ece-988b-ba832811e538
# ╟─5dc76f3b-badf-4951-9eb4-f61ca66dfb98
# ╠═d349ac4d-44bb-4505-a6c4-3096d8c48ba0
# ╠═9e181c4a-a759-4f92-8444-6a23387a20b9
# ╟─d39f503a-158e-4774-851e-d786014b8f2b
# ╠═b5387324-df28-422d-8e74-4fefa8054e7f
# ╠═570f62db-edd7-429d-a084-2686f4b6923c
# ╟─7e8a4e33-0e9c-45f5-b8bc-e2adece0806d
# ╠═204bcedc-4123-4845-bcac-493ce3544582
# ╠═92b0cb5f-41a1-420f-8b81-3b967db8138f
# ╟─7471120d-6e00-46be-be11-649c8cdbb32c
# ╠═b31b883d-5a69-4e04-b8b5-cedca81dcf9a
# ╠═c7f94dcd-64a2-4e97-b38d-363dc6f9f757
# ╠═2a25a884-44cf-4460-ab23-02e728201f90
# ╟─e127bdf8-2a53-4534-a628-1463a5735f41
# ╠═0806feb3-33eb-402c-92d2-af0b153834ba
# ╠═1a5f467b-7244-4587-b01c-61fd22bfbb9b
# ╟─4b1ec558-5f94-417a-aa3c-d13a0039a6a0
# ╠═6bee210a-11cc-40c4-bfb0-d14a6b2495b4
# ╠═10cc97dd-a390-4d4a-9644-20b654ff66bb
# ╟─04738501-16fa-43e1-b640-47682c155bcb
# ╠═f9317c0c-2389-43a8-8b91-f8b2f278e258
# ╟─a84b90c1-fa85-499a-9fa4-ac1f33ed8469
# ╟─e2c42c9e-abbb-4a33-844d-ef0f0c9b4939
# ╟─8253149c-e1b0-4e3f-9f5b-909621dba86e
# ╟─1f0abfbe-49cd-4529-8f4d-65f8286b6f0e
# ╠═6fcc1433-c348-4825-8503-782304ed508b
# ╟─33b81b24-ca33-4dd3-a85e-0371ca8623e8
# ╟─e462ca14-b38a-46b0-8faa-2261a2cfc150
# ╟─3cfbddfb-be59-4019-965f-13bdbac2295a
# ╠═aac164f5-6209-4d4e-a135-a848593f0c25
# ╠═525cd275-7b36-4d77-bbbf-d7b75fdcd2b6
# ╠═0029b8a6-e44b-4005-8eb1-d81253f93332
# ╟─f8f272e0-17ca-47e5-8dd0-577eb6322c90
# ╠═e137bf5e-d795-49ac-b641-b5f7364cfac9
# ╠═fae5e284-66e7-4599-9905-f0d5e64387ea
# ╠═a9c9cbbe-1e74-46d9-b1cc-fd60e6c2cc41
# ╟─bb899ab7-b3d8-493f-aaa6-85a4710a6690
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
