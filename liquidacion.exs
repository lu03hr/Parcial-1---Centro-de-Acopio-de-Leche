# Integrantes: Luisa Hernández, Isabella Hincapié, Camila González
# Cálculo del valor de las entregas y liquidación por productor

defmodule Liquidacion do
  @moduledoc """
  Reglas de pago, se trabaja solo con
  entregas que ya fueron validadas.
  """

  @doc "Factor que se aplica al valor de una entrega según su porcentaje de grasa."
  def factor_calidad(grasa) when grasa >= 3.5, do: 1.06
  def factor_calidad(grasa) when grasa >= 3.0, do: 1.0
  def factor_calidad(grasa) when grasa >= 2.5, do: 0.92
  def factor_calidad(_grasa), do: 0.80

  @doc "Valor de una entrega: litros × tarifa base × factor de calidad."
  def valor_entrega(entrega) do
    entrega.litros * Parametros.tarifa_base() * factor_calidad(entrega.grasa)
  end

  @doc "Suma los litros de una lista de entregas agrupándolos por día: %{dia => litros}."
  def litros_por_dia(entregas) do
  entregas
  |> Enum.group_by(fn e -> e.dia end, fn e -> e.litros end)
  |> Map.new(fn {dia, litros} -> {dia, Enum.sum(litros)} end)
  end

  @doc "Bonificación de un día según el total de litros válidos de ese día."
  def bonificacion_dia(litros_del_dia) do
    if litros_del_dia >= Parametros.litros_bonificacion(),
      do: Parametros.bonificacion_diaria(),
      else: 0
  end
   @doc """
  Liquida un productor con sus entregas válidas, si la lista está vacía
  todos los valores quedan en cero
  """
  def liquidar_productor(productor, entregas) do
    por_dia = litros_por_dia(entregas)
    litros = Enum.sum(Map.values(por_dia))
    valor = entregas
    |> Enum.map(&valor_entrega/1)
    |> Enum.sum()
    bonificaciones = por_dia
    |> Map.values()
    |> Enum.map(&bonificacion_dia/1)
    |> Enum.sum()
    dias_entrega = Enum.count(por_dia)

    transporte =
      if productor.transporte, do: dias_entrega * Parametros.costo_transporte(), else: 0

    %{
      codigo: productor.codigo,
      nombre: productor.nombre,
      entregas: length(entregas),
      dias_entrega: dias_entrega,
      litros: litros,
      valor_entregas: valor,
      bonificaciones: bonificaciones,
      transporte: transporte,
      neto: valor + bonificaciones - transporte
    }
  end

  @doc "Liquida a todos los productores, aunque no tengan entregas válidas."
  def liquidar(productores, validas) do
    por_productor = Enum.group_by(validas, fn e -> e.productor end)
    Enum.map(productores, fn p -> liquidar_productor(p, Map.get(por_productor, p.codigo, [])) end)
  end
end
