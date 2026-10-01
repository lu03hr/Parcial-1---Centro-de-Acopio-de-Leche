defmodule Reportes do

  @motivos [
    :productor_desconocido,
    :tanque_desconocido,
    :dia_invalido,
    :litros_fuera_de_rango,
    :porcentaje_invalido
  ]

  def ranking(lista, opciones) do
    campo = Keyword.fetch!(opciones, :campo)
    orden = Keyword.get(opciones, :orden, :desc)
    desempate = Keyword.get(opciones, :desempate)

    lista_desempate =
      if desempate do
        lista
        |> Util2.ordenar(:asc, fn elemento -> Map.get(elemento, desempate) end)
      else
        lista
      end

    lista_desempate
    |> Util2.ordenar(orden, fn elemento -> Map.get(elemento, campo) end)
  end


  def generar_reportes(entregas_validas, entregas_rechazadas, productores, tanques, liquidacion) do
    %{
      r1: calcular_r1(entregas_rechazadas),
      r2: calcular_r2(entregas_validas, tanques),
      r3: calcular_r3(entregas_validas),
      r4: calcular_r4(liquidacion),
      r5: calcular_r5(entregas_validas, productores),
      r6: calcular_r6(entregas_validas, productores),
      r7: calcular_r7(entregas_validas, liquidacion),
      r8: calcular_r8(entregas_validas, productores, tanques)
    }
  end


# FUNCIONES AUXILIARES:

  defp sumar_litros_por_campo(entregas, campo_de_agrupacion) do
    Enum.reduce(
      entregas,
      %{},
      fn entrega, litros_acumulados ->
        grupo = Map.get(entrega, campo_de_agrupacion)

        Map.update(
          litros_acumulados,
          grupo,
          entrega.litros,
          fn litros_actuales -> litros_actuales + entrega.litros end
        )
      end)
  end

  defp crear_mapa_productores(productores) do
    Map.new(productores, fn productor -> {productor.codigo, productor.nombre} end)
  end

  defp crear_ficha_productor(codigo, mapa_productores) do
    %{codigo: codigo, nombre: Map.get(mapa_productores, codigo)}
  end


end
