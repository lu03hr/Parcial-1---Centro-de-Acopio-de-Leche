# Integrantes: Luisa Hernández, Isabella Hincapié, Camila González
# Validación de entregas

defmodule Validacion do
  @moduledoc """
  Revisa si cada entrega cumple las reglas de negocio y clasifica las entregas en válidas y rechazadas.
  """

  @doc "Motivos de rechazo presentados en el negocio"
  def motivos do
    [:productor_desconocido, :tanque_desconocido, :dia_invalido,
     :litros_fuera_de_rango, :porcentaje_invalido]
  end

  @doc """
  Revisa una entrega. Devuelve {:ok, entrega} si cumple todo,
  o {:error, motivo} con el primer error que encuentre.
  """
  def validar(entrega, productores, tanques) do
    with :ok <- verificar_productor(entrega, productores),
         :ok <- verificar_tanque(entrega, tanques),
         :ok <- verificar_dia(entrega),
         :ok <- verificar_litros(entrega),
         :ok <- verificar_grasa(entrega) do
      {:ok, entrega}
    end
  end

  @doc """
  Separa las entregas en dos listas: las válidas y las rechazadas.
  Cada rechazada se guarda como {entrega, motivo}.
  """
  def clasificar(entregas, productores, tanques) do
    validas =
      Enum.filter(entregas, fn entrega ->
        validar(entrega, productores, tanques) == {:ok, entrega}
      end)

    rechazadas =
      entregas
      |> Enum.filter(fn entrega -> validar(entrega, productores, tanques) != {:ok, entrega} end)
      |> Enum.map(fn entrega ->
        {:error, motivo} = validar(entrega, productores, tanques)
        {entrega, motivo}
      end)

    {validas, rechazadas}
  end

  defp verificar_productor(entrega, productores) do
    if Enum.any?(productores, fn productor -> productor.codigo == entrega.productor end) do
      :ok
    else
      {:error, :productor_desconocido}
    end
  end

  defp verificar_tanque(entrega, tanques) do
    if Enum.any?(tanques, fn tanque -> tanque.id == entrega.tanque end) do
      :ok
    else
      {:error, :tanque_desconocido}
    end
  end

  defp verificar_dia(entrega) do
    if is_integer(entrega.dia) and entrega.dia in Parametros.dias() do
      :ok
    else
      {:error, :dia_invalido}
    end
  end

  defp verificar_litros(entrega) do
    if is_number(entrega.litros) and entrega.litros > 0 and
         entrega.litros <= Parametros.max_litros_entrega() do
      :ok
    else
      {:error, :litros_fuera_de_rango}
    end
  end

  defp verificar_grasa(entrega) do
    if is_number(entrega.grasa) and entrega.grasa >= Parametros.grasa_minima() and
         entrega.grasa <= Parametros.grasa_maxima() do
      :ok
    else
      {:error, :porcentaje_invalido}
    end
  end
end
