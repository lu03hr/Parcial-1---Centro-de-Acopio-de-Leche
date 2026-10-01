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

  @doc "Suma los litros de una lista de entregas."
  def total_litros(entregas) do
    entregas
    |> Enum.map(fn entrega -> entrega.litros end)
    |> Enum.sum()
  end

  @doc "Suma el valor de una lista de entregas."
  def total_valor(entregas) do
    entregas
    |> Enum.map(fn entrega -> valor_entrega(entrega) end)
    |> Enum.sum()
  end

  @doc "Litros de cada día, como lista de tuplas: [{1, 470}, {3, 180}]."
  def litros_por_dia(entregas) do
    entregas
    |> Enum.group_by(fn entrega -> entrega.dia end)
    |> Enum.map(fn {dia, entregas_del_dia} -> {dia, total_litros(entregas_del_dia)} end)
  end

  @doc "Bonificación de un día según el total de litros válidos de ese día."
  def bonificacion_dia(litros_del_dia) do
    if litros_del_dia >= Parametros.litros_bonificacion() do
      Parametros.bonificacion_diaria()
    else
      0
    end
  end

  @doc """
  Liquida un productor con sus entregas válidas, si la lista está vacía
  todos los valores quedan en cero
  """
  def liquidar_productor(productor, entregas) do
    por_dia = litros_por_dia(entregas)
    dias_entrega = length(por_dia)

    valor = total_valor(entregas)

    bonificaciones =
      por_dia
      |> Enum.map(fn {_dia, litros} -> bonificacion_dia(litros) end)
      |> Enum.sum()

    transporte =
      if productor.transporte do
        dias_entrega * Parametros.costo_transporte()
      else
        0
      end

    %{
      codigo: productor.codigo,
      nombre: productor.nombre,
      entregas: length(entregas),
      dias_entrega: dias_entrega,
      litros: total_litros(entregas),
      valor_entregas: valor,
      bonificaciones: bonificaciones,
      transporte: transporte,
      neto: valor + bonificaciones - transporte
    }
  end

  @doc "Liquida a todos los productores, aunque no tengan entregas válidas."
  def liquidar(productores, validas) do
    por_productor = Enum.group_by(validas, fn entrega -> entrega.productor end)

    Enum.map(productores, fn productor ->
      entregas = Map.get(por_productor, productor.codigo, [])
      liquidar_productor(productor, entregas)
    end)
  end

  @doc """
  Datos del comprobante de un productor.
  Devuelve tuplas {:ok, comprobante} o {:error, :productor_no_existe}.
  """
  def comprobante(codigo, productores_por_codigo, validas) do
    productor = Map.get(productores_por_codigo, codigo)

    if productor == nil do
      {:error, :productor_no_existe}
    else
      entregas = Enum.filter(validas, fn entrega -> entrega.productor == codigo end)
      liquidacion = liquidar_productor(productor, entregas)
      {:ok, Map.put(liquidacion, :detalle, detalle_por_dia(entregas))}
    end
  end

  # Una fila por cada día en que el productor entregó, ordenadas por día
  defp detalle_por_dia(entregas) do
    entregas
    |> Enum.group_by(fn entrega -> entrega.dia end)
    |> Enum.sort_by(fn {dia, _entregas_del_dia} -> dia end)
    |> Enum.map(fn {dia, entregas_del_dia} ->
      litros = total_litros(entregas_del_dia)

      %{
        dia: dia,
        entregas: length(entregas_del_dia),
        litros: litros,
        valor: total_valor(entregas_del_dia),
        bonificacion: bonificacion_dia(litros)
      }
    end)
  end
end
