module ModelGenie
using XLSX, JuMP, GLPK, Dates

#function rodaModelo(inputInvestimento::Int, inputMeses::Int, inputValorMinimo::Int, inputBuscasMensais , inputImpressoesDisplay::Int,inputPublicoFacebook::Int, inputCPCsMensaisGoogle , inputCPCsMensaisFacebook , inputCPCsMensaisInstagram , inputCPCsMensaisDisplay , inputCTRsMensaisGoogle , inputCTRsMensaisFacebook , inputCTRsMensaisInstagram , inputCTRsMensaisDisplay , inputTxConvsMensaisGoogle , inputTxConvsMensaisFacebook , inputTxConvsMensaisInstagram , inputTxConvsMensaisDisplay)
function rodaModelo(inputInvestimento::Int, inputMeses::Int, inputValorMinimo::Int, inputBuscasMensais , inputImpressoesDisplay::Int,inputPublicoFacebook::Int, inputCPCsMensaisGoogle , inputCPCsMensaisFacebook , inputCPCsMensaisInstagram , inputCPCsMensaisDisplay , inputTxConvsMensaisGoogle , inputTxConvsMensaisFacebook , inputTxConvsMensaisInstagram , inputTxConvsMensaisDisplay)

  model = Model(with_optimizer(GLPK.Optimizer))

  dinheirot = inputInvestimento #valor investido

  n = inputMeses #numero de meses

  m = 4 #numero de plataformas


  cpm =  [21.27 21.27 21.27 21.27 21.27; #facebook
          30.29 30.29 30.29 30.29 30.29; #instagram
          10.58 10.58 10.58 10.58 10.58; #google display
          109.59 109.59 109.59 109.59 109.59] #google search

#  ctr =  [1.27 1.27 1.27 1.27 1.27 1.27; #facebook
#          0.29 0.29 0.29 0.29 0.29 0.29; #instagram
#          0.58 0.58 0.58 0.58 0.58 0.58; #google display
#          9.59 9.59 9.59 9.59 9.59 9.59] #google search

  cpcFacebook = [parse(Float64, item) for item in split(inputCPCsMensaisFacebook,",")]
  cpcInstagram = [parse(Float64, item) for item in split(inputCPCsMensaisInstagram,",")]
  cpcGoogle = [parse(Float64, item) for item in split(inputCPCsMensaisGoogle,",")]
  cpcDisplay = [parse(Float64, item) for item in split(inputCPCsMensaisDisplay,",")]

  #ctrFacebook = [parse(Float64, item) for item in split(inputCTRsMensaisFacebook,",")]
  #ctrInstagram = [parse(Float64, item) for item in split(inputCTRsMensaisInstagram,",")]
  #ctrGoogle = [parse(Float64, item) for item in split(inputCTRsMensaisGoogle,",")]
  #ctrDisplay = [parse(Float64, item) for item in split(inputCTRsMensaisDisplay,",")]

  TxConvFacebook = [parse(Float64, item) for item in split(inputTxConvsMensaisFacebook,",")]
  TxConvInstagram = [parse(Float64, item) for item in split(inputTxConvsMensaisInstagram,",")]
  TxConvGoogle = [parse(Float64, item) for item in split(inputTxConvsMensaisGoogle,",")]
  TxConvDisplay = [parse(Float64, item) for item in split(inputTxConvsMensaisDisplay,",")]

  #cpc =  [0.59 0.59 0.59 0.59 0.59 0.59; #facebook
#          1.90 1.90 1.90 1.90 1.90 1.90; #instagram
#          0.13 0.13 0.13 0.13 0.13 0.13; #google display
#          0.41 0.41 0.41 0.41 0.41 0.41] #google search

  cpc = [cpcFacebook cpcInstagram cpcDisplay cpcGoogle]'
  #ctr = [ctrFacebook ctrInstagram ctrDisplay ctrGoogle]'
  txConv = [TxConvFacebook TxConvInstagram TxConvDisplay TxConvGoogle]'

  #cpc = [parse(Float64, item) for item in split(inputCPCsMensaisFacebook,","); parse(Float64, item) for item in split(inputCPCsMensaisInstagram,","); parse(Float64, item) for item in split(inputCPCsMensaisGoogle,","); parse(Float64, item) for item in split(inputCPCsMensaisDisplay,",")]

# txConv =   [3.73 2.73 1.73 0.73 3.73 3.73; #facebook
#              8.88 8.88 8.88 8.88 8.88 8.88; #instagram
#              0.08 0.08 0.08 0.08 0.08 0.08; #google display
#              7.67 7.67 7.67 7.67 7.67 7.67] #Google search


  indGoogle = 4 #indice que corresponde ao google search nas matrizes
  volBuscas = [parse(Int, item) for item in split(inputBuscasMensais,",")]
  publicoTotal = [inputPublicoFacebook,inputPublicoFacebook,inputImpressoesDisplay,0] # TODOS OS PUBLICOS NA ORDEM FACE,INSTA, DISPLAY e google que precisa ser infinito caso
  minservico = [inputValorMinimo,inputValorMinimo,inputValorMinimo,inputValorMinimo] # Mínimos informados pelo usuarios

  @variable(model, dinheiro[1:m,1:n]) # Usar matrizes de N meses por M canais para ter apenas uma variavel dinheiro

  # Primeira restricao é ser menor ou igual ao investimento total (estava dando erro, fazendo com que cada valor seja menor)
  @constraint(model, sum(dinheiro) .<= sum(dinheirot)) # nao precisa do 1:n, ele le tudo

  # Segunda restrição é o dinheiro nas midias ser proporcional ao publico e suas taxas
  @constraint(model, [j=1:m;j!=indGoogle], dinheiro[j,1:n] .<= publicoTotal[j] .* 0.8 .* cpc[j,1:n]) # limite do publico SEM CTR

  # Terceira restriçào é do volume de buscas do google
  @constraint(model, dinheiro[indGoogle,1:n] .<= volBuscas[1:n] .* cpc[indGoogle,1:n])

  # Quarta restricao é que o dinheiro nunca pode ser negativo
  @constraint(model, dinheiro .>= 0)

  # Quinta restrição é o dinheiro ser maior que o minimos // ERRO QUANDO ENTRA ESSA RESTRIÇÃO, TUDO FICA COM R$500,00
  @constraint(model, [j=1:m], dinheiro[j,1:n] .>= minservico[j]) #j sao os canais, n sao o numero de meses

  @objective(model, Max, sum((dinheiro[j,i]/cpc[j,i]*(txConv[j,i])/100) for i = 1:n,j=1:m)) # com CPC
  #@objective(model, Max, sum(( dinheiro[j,i]/cpm[j,i]*1000*ctr[j,i]/100*(txConv[j,i])/100) for i = 1:n,j=1:m)) # sem CPC, AI USA CTR E CPM

  optimize!(model)

  #-------------------------------- Gera o XLS com os dados --------------------------------

  #nome = "PLANO",Dates.format(now(), "HH:MM:SS") #"ïnvest_de ",dinheirot,"__",n," meses"
  dataAgora = string(Dates.format(now(), "HH:MM:SS"))
  nome = string("plano_de_",dinheirot,"__",n,"_meses","__",dataAgora)
  nomeCorreto = replace(nome, r"()" => s"")
  nomeCorreto = replace(nomeCorreto, ":"=>"_")

  #downloadLink = @__DIR__,"/",nome,".xlsx"
  filename = string(nomeCorreto, ".xlsx")
  #@show filename
  #filename = string("/",nomeCorreto,".xlsx")

  # Converte o retorno do modelo em string para usar no XLS
  resultado = string(termination_status(model))

  # Reseva os vetores
  columns_plano = Vector()
  labels_plano = Vector()
  columns_tab_invest = Vector()
  labels_tab_invest = Vector()

  # Adicionar os dados para os vetores de colunas e linhas do XLS
  push!(labels_plano,"Dados do Plano")
  push!(labels_plano,"Status")
  push!(columns_plano,["Status da solução", "Investimento Previsto", "Investimento Aplicado", "Conversões Estimadas", "Saldo do Investimento"])
  push!(columns_plano,[ resultado, dinheirot, value(sum(dinheiro)), objective_value(model), (dinheirot - value(sum(dinheiro))) ])
  push!(columns_tab_invest,["Facebook","Instagram","Display","Google Search"])
  push!(labels_tab_invest,"Plataforma")

  # Loop para pegar os dados de dinheiro de cada mes
  for n in 1:n
      push!(columns_tab_invest, [value(dinheiro[1,n]),value(dinheiro[2,n]),value(dinheiro[3,n]),value(dinheiro[4,n])])
  end

  # Loop para montar o nome de cada mes
  for i in 1:n
      push!(labels_tab_invest, "Mês $(i)")
  end

  #@show pwd()
  #@show filename

  filepath = joinpath("public", "files", filename)

  # Monta o XLS
  XLSX.openxlsx(filepath, mode="w") do xf
      sheet = xf[1]
      XLSX.rename!(sheet, "Dados do Plano")
      XLSX.writetable!(sheet, columns_plano, labels_plano, anchor_cell=XLSX.CellRef("A1"))
      sheet2 = XLSX.addsheet!(xf, "Tabela de Investimentos")
      XLSX.writetable!(sheet2, columns_tab_invest, labels_tab_invest, anchor_cell=XLSX.CellRef("A1"))
  end

  return "/files/$filename"

end
end
