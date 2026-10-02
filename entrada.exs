# Integrantes: Luisa Hernández, Isabella Hincapié, Camila González
# Conversión del texto ingresado por el usuario en una entrega

defmodule Entrada do
  @moduledoc """
  Convierte una línea con el formato productor;tanque;dia;litros;grasa
  en un mapa de entrega. Solo revisa el formato; las reglas de negocio
  se revisan después con Validacion.validar/3.
  """

  @doc """
  Devuelve {:ok, entrega} o {:error, :formato_invalido} cuando no hay
  exactamente cinco campos, el día no es entero, o los litros o la grasa
  no son numéricos.
  """
  def parsear_entrega(texto) do
    # Limpia espacios y separa los campos usando ";"
    campos = texto |> String.trim() |> String.split(";") |> Enum.map(&String.trim/1)

    # Verifica que existan exactamente 5 campos y convierte día, litros y grasa
    with [productor, tanque, dia_texto, litros_texto, grasa_texto] <- campos,
         {:ok, dia} <- a_entero(dia_texto),
         {:ok, litros} <- a_numero(litros_texto),
         {:ok, grasa} <- a_numero(grasa_texto) do
      # Si todo es correcto, devuelve los datos en un mapa
      {:ok, %{productor: productor, tanque: tanque, dia: dia, litros: litros, grasa: grasa}}
    else
      # Si algún dato es inválido, devuelve un error
      _ -> {:error, :formato_invalido}
    end
  end

  @doc "Convierte un texto a entero solo si todo el texto es un entero (\"4\" sí, \"4.5\" no)."
  def a_entero(texto) do
    case Integer.parse(texto) do
      {numero, ""} -> {:ok, numero}
      _ -> {:error, :no_entero}
    end
  end

  @doc "Convierte un texto a número decimal (\"320\" y \"320.5\" sí, \"abc\" no)."
  def a_numero(texto) do
    case Float.parse(texto) do
      {numero, ""} -> {:ok, numero}
      _ -> {:error, :no_numerico}
    end
  end
end
