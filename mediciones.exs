Code.require_file("Util2.ex", __DIR__)
Code.require_file("parametros.exs", __DIR__)
Code.require_file("datos.exs", __DIR__)
Code.require_file("validacion.exs", __DIR__)
Code.require_file("reportes.exs", __DIR__)

defmodule Mediciones do

    @repeticiones 7

    def medir(funcion) do
    tiempos =
      for _ <- 1..@repeticiones do
        {microsegundos, _resultado} = :timer.tc(funcion)
        microsegundos
      end

    {Enum.min(tiempos), div(Enum.sum(tiempos), @repeticiones)}
  end

  def imprimir(nombre, {minimo, promedio}) do
    Util2.mostrar("  #{String.pad_trailing(nombre, 44)} mín: #{String.pad_leading(Integer.to_string(minimo), 8)} µs   prom: #{String.pad_leading(Integer.to_string(promedio), 8)} µs", :mensaje)
  end

  def experimento_busqueda(entregas, productores, vueltas) do
    indice = Validacion.indexar_productores(productores)
    Util2.mostrar("\n1) Buscar el productor de cada entrega (#{vueltas} vueltas sobre #{length(entregas)} entregas)", :mensaje)

    imprimir("Lista + Enum.any?", medir(fn ->
      for _ <- 1..vueltas, e <- entregas, do: Enum.any?(productores, fn p -> p.codigo == e.productor end)
    end))

    imprimir("Mapa + Map.has_key?", medir(fn ->
      for _ <- 1..vueltas, e <- entregas, do: Map.has_key?(indice, e.productor)
    end))
  end

  def experimento_agrupacion(entregas) do
    Util2.mostrar("\n2) Litros por día con #{length(entregas)} entregas", :mensaje)

    imprimir("Enum.group_by y luego sumar cada grupo", medir(fn ->
      entregas
      |> Enum.group_by(fn e -> e.dia end)
      |> Map.new(fn {dia, lista} -> {dia, Enum.sum(Enum.map(lista, fn e -> e.litros end))} end)
    end))

    imprimir("Enum.reduce con Map.update (una pasada)", medir(fn ->
      Reportes.sumar_litros_por(entregas, fn e -> e.dia end)
    end))
  end

  def experimento_agregar(n) do
    Util2.mostrar("\n3) Construir una lista de #{n} elementos", :mensaje)

    imprimir("lista ++ [x] (al final)", medir(fn ->
      Enum.reduce(1..n, [], fn x, acc -> acc ++ [x] end)
    end))

    imprimir("[x | lista] y Enum.reverse al final", medir(fn ->
      1..n |> Enum.reduce([], fn x, acc -> [x | acc] end) |> Enum.reverse()
    end))
  end
end

Mediciones.main()
