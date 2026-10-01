defmodule Entrada do
def parsear_entrega(texto) do
    campos = texto |> String.trim() |> String.split(";") |> Enum.map(&String.trim/1)

    with [productor, tanque, dia_texto, litros_texto, grasa_texto] <- campos,
         {:ok, dia} <- a_entero(dia_texto),
         {:ok, litros} <- a_numero(litros_texto),
         {:ok, grasa} <- a_numero(grasa_texto) do
      {:ok, %{productor: productor, tanque: tanque, dia: dia, litros: litros, grasa: grasa}}
    else
      _ -> {:error, :formato_invalido}
    end
  end

  def a_entero(texto) do
    case Integer.parse(texto) do
      {numero, ""} -> {:ok, numero}
      _ -> {:error, :no_entero}
    end
  end

  def a_numero(texto) do
    case Integer.parse(texto) do
      {entero, ""} ->
        {:ok, entero}
      end
    end 
end
