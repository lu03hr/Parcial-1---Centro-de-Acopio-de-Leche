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

 
end
