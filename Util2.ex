# Integrantes: Luisa Hernández, Isabella Hincapié, Camila González

defmodule Util2 do
  @moduledoc """
  Módulo con funciones que se reutilizan
  - autor: Camila Gonzalez, Isabella Hincapié, Luisa Hernández
  - fecha: 2026
  - licencia: GNU GPL V3

  Para el parcial se dejaron solo las funciones que no usan recursividad.
  """

  @doc """
  Función para mostrar un mensaje o un error en pantalla
  ## Parámetro
  - mensaje: texto que se le presenta al usuario
  - atomo: identifica el tipo de mensaje.
     :mensaje: muestra el texto en la salida estándar
     :error: muestra el texto en el dispositivo estándar de error

  ## Ejemplo
  iex> Util2.mostrar("Hola Mundo", :mensaje)
  iex> Util2.mostrar("Error: El valor ingresado no es válido", :error)

  o puede usar
  "Hola Mundo" |> Util2.mostrar(:mensaje)
  "Error: El valor ingresado no es válido" |> Util2.mostrar(:error)
  """

  def mostrar(mensaje, :mensaje), do: IO.puts(mensaje)
  def mostrar(mensaje, :error), do: IO.puts(:standard_error, mensaje)
  ## con :error se manda al dispositivo estándar de error, en este caso la pantalla

  @doc """
  Función para ordenar una colección
  ## Parámetro
  - coleccion: lista de elementos que se van a ordenar
  - sentido: orden del resultado, :asc (ascendente, valor por defecto) o :desc (descendente)
  - obtener_campo: función que indica por cuál valor se ordena cada elemento.
     Por defecto es & &1, es decir, se ordena por el mismo elemento

  ## Ejemplo
  iex> Util2.ordenar([3, 1, 2])
  iex> Util2.ordenar([3, 1, 2], :desc)
  iex> Util2.ordenar(["ana", "sebastian", "luis"], :asc, &String.length/1)

  o puede usar
  [3, 1, 2] |> Util2.ordenar()
  ["ana", "sebastian", "luis"] |> Util2.ordenar(:desc, &String.length/1)
  """

  def ordenar(coleccion, sentido \\ :asc, obtener_campo \\ & &1) do
    Enum.sort_by(coleccion, obtener_campo, sentido)
  end

  @doc """
  Función para filtrar los textos de una colección según su longitud
  ## Parámetro
  - coleccion: lista de textos
  - longitud: cantidad máxima de caracteres que puede tener un texto para quedar en el resultado

  ## Ejemplo
  iex> Util2.aplicar_filtro_longitud(["sol", "montaña", "mar"], 4)

  o puede usar
  ["sol", "montaña", "mar"] |> Util2.aplicar_filtro_longitud(4)
  """

  def aplicar_filtro_longitud(coleccion, longitud) do
    Enum.filter(coleccion, &(String.length(&1) <= longitud))
  end

  @doc """
  Función para filtrar los textos de una colección que comienzan con una inicial
  ## Parámetro
  - coleccion: lista de textos
  - inicial: texto con el que deben comenzar los elementos para quedar en el resultado

  ## Ejemplo
  iex> Util2.aplicar_filtro_inicial(["casa", "perro", "carro"], "c")

  o puede usar
  ["casa", "perro", "carro"] |> Util2.aplicar_filtro_inicial("c")
  """

  def aplicar_filtro_inicial(coleccion, inicial) do
    coleccion
    |> Enum.filter(&String.starts_with?(&1, inicial))
  end

  @doc """
  Función para convertir cada elemento de una colección en un texto para mostrar
  ## Parámetro
  - coleccion: lista de elementos
  - formato: función que convierte cada elemento en texto.
     Por defecto convierte cada elemento en "- elemento" con salto de línea

  ## Ejemplo
  iex> Util2.convertir_coleccion_mensaje(["Ana", "Luis"])
  iex> Util2.convertir_coleccion_mensaje([1, 2], fn numero -> "Número: \#{numero}" end)

  o puede usar
  ["Ana", "Luis"] |> Util2.convertir_coleccion_mensaje()
  """

  def convertir_coleccion_mensaje(
        coleccion,
        formato \\ fn elemento -> "- #{elemento}\n" end
      ) do
    Enum.map(coleccion, formato)
  end

  @doc """
  Función para ingresar un texto desde el teclado
  ## Parámetro
  - pregunta: texto que se le presenta al usuario

  Devuelve lo que escribió el usuario sin espacios al inicio ni al final.

  ## Ejemplo
  iex> Util2.ingresar("Ingrese un texto: ", :texto)

  o puede usar
  "Ingrese un texto: " |> Util2.ingresar(:texto)
  """

  def ingresar(pregunta, :texto) do
    pregunta
    |> IO.gets()
    |> String.trim()
  end
end
