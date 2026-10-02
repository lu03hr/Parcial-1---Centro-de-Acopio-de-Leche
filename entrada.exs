defmodule Entrada do
    # Parsea una línea de texto con los datos de una entrega.
    # Formato esperado: productor;tanque;dia;litros;grasa
  def parsear_entrega(texto) do
    # Limpia espacios y separa los campos usando ";"
    campos = texto |> String.trim() |> String.split(";") |> Enum.map(&String.trim/1)

    # Verifica que existan exactamente 5 campos y convierte
    # día, litros y grasa a valores numéricos.
    with [productor, tanque, dia_texto, litros_texto, grasa_texto] <- campos,
         {:ok, dia} <- a_entero(dia_texto),
         {:ok, litros} <- a_numero(litros_texto),
         {:ok, grasa} <- a_numero(grasa_texto) do
    # Si todo es correcto, devuelve los datos en un mapa.
      {:ok, %{productor: productor, tanque: tanque, dia: dia, litros: litros, grasa: grasa}}
    else
        # Si algún dato es inválido, devuelve un error.
      _ -> {:error, :formato_invalido}
    end
  end

  def a_entero(texto) do
    case Integer.parse(texto) do
        # Conversión exitosa.
      {numero, ""} -> {:ok, numero}
      # El texto no representa un entero válido.
      _ -> {:error, :no_entero}
    end
  end

  # Convierte un texto a un número entero.
  def a_numero(texto) do
    case Integer.parse(texto) do
        # Si es entero, devuelve el valor.
      {entero, ""} ->
        {:ok, entero}

        # Si no es entero, intenta convertirlo a decimal.
      _ ->
        case Float.parse(texto) do
          {decimal, ""} -> {:ok, decimal}
          # El texto no es un número válido.
          _ -> {:error, :no_numerico}
        end
    end
  end
end
