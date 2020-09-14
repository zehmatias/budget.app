using Revise
using Genie, Genie.Router, Genie.Requests
using Genie.Renderer, Genie.Renderer.Html

include("lib/ModelGenie.jl")
using .ModelGenie

# render the form
route("/") do
  html(path"views/formulario.jl.html")
end

route("/model", method=POST) do
  filename = ModelGenie.rodaModelo( parse(Int, payload(:inputInvestimento)),
                                    parse(Int, payload(:inputMeses)),
                                    parse(Int, payload(:inputValorMinimo)),
                                    payload(:inputBuscasMensais),
                                    parse(Int, payload(:inputImpressoesDisplay)),
                                    parse(Int, payload(:inputPublicoFacebook)),
                                    payload(:inputCPCsMensaisG),
                                    payload(:inputCPCsMensaisFb),
                                    payload(:inputCPCsMensaisIg),
                                    payload(:inputCPCsMensaisDs),
                                    #payload(:inputCTRsMensaisG),
                                    #payload(:inputCTRsMensaisFb),
                                    #payload(:inputCTRsMensaisIg),
                                    #payload(:inputCTRsMensaisDs),
                                    payload(:inputTxConvsMensaisG),
                                    payload(:inputTxConvsMensaisFb),
                                    payload(:inputTxConvsMensaisIg),
                                    payload(:inputTxConvsMensaisDs))

  redirect(filename)
end

route("/sobre") do
  html(path"views/sobre.jl.html")
end

route("/downloads") do
    html(path"views/download.jl.html")
end

up(async=false) # start server and block the repl so it keeps running // ctrl+c to exit

#=
<h4>Quais os dados de CTR?</h4>

  <label>Informe o CTR Facebook separado por vírgulas (para os % use pontos!)</label>
  <input onblur="validaValores('inputCTRsMensaisFb')" class="text" id="inputCTRsMensaisFb" type="text" name="inputCTRsMensaisFb" min="0" value="1.44,1.35,1.23,1.80" placeholder="Informe os valores" required /><br>

  <label>Informe o CTR Instagram separado por vírgulas (para os % use pontos!))</label>
  <input onblur="validaValores('inputCTRsMensaisIg')" class="text" id="inputCTRsMensaisIg" type="text" name="inputCTRsMensaisIg" min="0" value="1.44,1.35,1.23,1.80" placeholder="Informe os valores" required /><br>


  <label>Informe o CTR Display separado por vírgulas (para os % use pontos!))</label>
  <input onblur="validaValores('inputCTRsMensaisDs')" class="text" id="inputCTRsMensaisDs" type="text" name="inputCTRsMensaisDs" min="0" value="1.44,1.35,1.23,1.80" placeholder="Informe os valores" required /><br>

  <label>Informe o CTR Google separado por vírgulas (ppara os % use pontos!))</label>
  <input onblur="validaValores('inputCTRsMensaisG')" class="text" id="inputCTRsMensaisG" type="text" name="inputCTRsMensaisG" min="0" value="1.44,1.35,1.23,1.80" placeholder="Informe os valores" required /><br>
=#
