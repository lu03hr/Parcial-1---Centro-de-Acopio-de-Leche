# Integrantes: Luisa Hernández, Isabella Hincapié, Camila González
# Mediciones de tiempo con :timer.tc/1 (Parte C).
# Ejecutar con:  elixir mediciones.exs

Code.require_file("Util2.ex", __DIR__)
Code.require_file("parametros.exs", __DIR__)
Code.require_file("datos.exs", __DIR__)
Code.require_file("validacion.exs", __DIR__)

defmodule Mediciones do
  @repeticiones 7

  # Ejecuta la función varias veces y devuelve {mínimo, promedio} en microsegundos
  def medir(funcion) do
    tiempos =
      for _ <- 1..@repeticiones do
        {microsegundos, _resultado} = :timer.tc(funcion)
        microsegundos
      end

    {Enum.min(tiempos), div(Enum.sum(tiempos), @repeticiones)}
  end

  def imprimir(nombre, {minimo, promedio}) do
    Util2.mostrar(
      "  #{String.pad_trailing(nombre, 44)} mín: #{String.pad_leading(Integer.to_string(minimo), 8)} µs   prom: #{String.pad_leading(Integer.to_string(promedio), 8)} µs",
      :mensaje
    )
  end

  # 1. Buscar el productor de cada entrega: en una lista vs en un mapa
  def experimento_busqueda(entregas, productores, vueltas) do
    mapa_productores =
      Enum.reduce(productores, %{}, fn productor, mapa ->
        Map.put(mapa, productor.codigo, productor)
      end)

    Util2.mostrar(
      "\n1) Buscar el productor de cada entrega (#{vueltas} vueltas sobre #{length(entregas)} entregas)",
      :mensaje
    )

    imprimir(
      "Lista + Enum.any?",
      medir(fn ->
        for _ <- 1..vueltas,
            entrega <- entregas,
            do: Enum.any?(productores, fn productor -> productor.codigo == entrega.productor end)
      end)
    )

    imprimir(
      "Mapa + Map.has_key?",
      medir(fn ->
        for _ <- 1..vueltas, entrega <- entregas, do: Map.has_key?(mapa_productores, entrega.productor)
      end)
    )
  end

  # 2. Litros por día: group_by y sumar cada grupo vs un solo reduce
  def experimento_agrupacion(entregas) do
    Util2.mostrar("\n2) Litros por día con #{length(entregas)} entregas", :mensaje)

    imprimir(
      "Enum.group_by y luego sumar cada grupo",
      medir(fn ->
        entregas
        |> Enum.group_by(fn entrega -> entrega.dia end)
        |> Enum.map(fn {dia, del_dia} ->
          {dia, Enum.sum(Enum.map(del_dia, fn entrega -> entrega.litros end))}
        end)
      end)
    )

    imprimir(
      "Enum.reduce con Map.update (una pasada)",
      medir(fn ->
        Enum.reduce(entregas, %{}, fn entrega, mapa ->
          Map.update(mapa, entrega.dia, entrega.litros, fn total -> total + entrega.litros end)
        end)
      end)
    )
  end

  # 3. Agregar elementos al final (++) vs al inicio ([x | lista])
  def experimento_agregar(n) do
    Util2.mostrar("\n3) Construir una lista de #{n} elementos", :mensaje)

    imprimir(
      "lista ++ [x] (al final)",
      medir(fn ->
        Enum.reduce(1..n, [], fn x, lista -> lista ++ [x] end)
      end)
    )

    imprimir(
      "[x | lista] y Enum.reverse al final",
      medir(fn ->
        1..n |> Enum.reduce([], fn x, lista -> [x | lista] end) |> Enum.reverse()
      end)
    )
  end

  def main do
    productores = Datos.productores()
    tanques = Datos.tanques()
    {validas, _rechazadas} = Validacion.clasificar(Datos.entregas(), productores, tanques)

    # Se repiten los datos 200 veces para que las diferencias se noten
    grandes = for _ <- 1..200, entrega <- validas, do: entrega

    Util2.mostrar("MEDICIONES CON :timer.tc/1 (#{@repeticiones} repeticiones por caso)", :mensaje)
    experimento_busqueda(validas, productores, 1_000)
    experimento_agrupacion(validas)
    experimento_agrupacion(grandes)
    experimento_agregar(5_000)
  end
end

Mediciones.main()
