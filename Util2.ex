defmodule Util2 do
  @moduledoc """
  Módulo con funciones que se reutilizan
  - autor: Camila Gonzalez, Isabella Hincapié, Luisa Hernández
  - fecha: 2026
  - licencia: GNU GPL V3
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

  def ordenar(coleccion, sentido \\:asc, obtener_campo \\ & &1) do
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
  iex> Util2.convertir_coleccion_mensaje([1, 2], fn numero -> "Número: {numero}" end)

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
  Función para ingresar datos desde el teclado
  ## Parámetro
  - pregunta / mensaje: texto que se le presenta al usuario
  - atomo: identifica el tipo de dato.
     :texto: para ingresar un texto
     :entero: para ingresar un número entero
     :real: para ingresar un número real
     :boolean: para responder s (true) o n (false)
     :coleccion_textos: para ingresar una lista de textos
     :coleccion_enteros: para ingresar una lista de números enteros
     :coleccion_reales: para ingresar una lista de números reales
     :coleccion: para ingresar una lista; en este caso el primer parámetro
      no es un texto sino una función que ingresa cada elemento

  ## Ejemplo
  iex> Util2.ingresar("Ingrese un texto: ", :texto)
  iex> Util2.ingresar("Ingrese un número entero: ", :entero)
  iex> Util2.ingresar("Ingrese un número real: ", :real)
  iex> Util2.ingresar("¿Desea continuar (s/n)? ", :boolean)
  iex> Util2.ingresar("Ingrese un nombre: ", :coleccion_textos)
  iex> Util2.ingresar("Ingrese una edad: ", :coleccion_enteros)
  iex> Util2.ingresar("Ingrese una nota: ", :coleccion_reales)
  iex> Util2.ingresar(fn -> Util2.ingresar("Ingrese un número: ", :entero) end, :coleccion)

  o puede usar
  "Ingrese un texto: " |> Util2.ingresar(:texto)
  "Ingrese un número entero: " |> Util2.ingresar(:entero)
  "Ingrese una nota: " |> Util2.ingresar(:coleccion_reales)
  """

  def ingresar(pregunta, :coleccion_textos) do
    ingresar(fn -> ingresar(pregunta, :texto) end, :coleccion)
  end

   def ingresar(pregunta, :coleccion_enteros) do
    ingresar(fn -> ingresar(pregunta, :entero) end, :coleccion)
  end

   def ingresar(pregunta, :coleccion_reales) do
    ingresar(fn -> ingresar(pregunta, :real) end, :coleccion)
  end

  def ingresar(ingresar_elemento, :coleccion) do
    ingresar_coleccion(ingresar_elemento, [])
  end

  def ingresar(mensaje, :boolean) do
    ingresar(
      mensaje,
      fn texto ->
        case String.downcase(texto) do
          "s" -> {true, ""}
          "n" -> {false, ""}
          _ -> :error
        end
      end,

      :boolean
    )
    ## el parser devuelve {true, ""} o {false, ""} para que tenga la misma forma que Integer.parse y Float.parse
  end

    def ingresar(mensaje, :entero) do
    ingresar(mensaje,
    &Integer.parse/1,
    :entero)
  end

   def ingresar(mensaje, :real) do
    ingresar(mensaje,
    &Float.parse/1,
    :real)
  end

  def ingresar(pregunta, :texto) do
   pregunta
   |> IO.gets()
   |> String.trim()
  end


  ## Función privada para ingresar un dato y convertirlo al tipo indicado
  ## Parámetro
  ## - pregunta: texto que se le presenta al usuario
  ## - parser: función que convierte el texto (Integer.parse, Float.parse o el parser de :boolean)
  ## - tipo_dato: átomo con el tipo de dato, se usa en el mensaje de error y para volver a preguntar
  defp ingresar(pregunta, parser, tipo_dato) do
    resultado =
      pregunta
     |> ingresar(:texto)
     |> parser.()

      case resultado do
        {valor, ""} ->
          valor
        _ ->
          mostrar("El valor ingresado no es un número #{tipo_dato}\n",
          :error
          )
          ingresar(pregunta, tipo_dato)
          ## Recursividad, función que se llama a sí misma hasta que el usuario ingrese un valor correcto
    end
  end

  ## Función privada para ingresar los elementos de una colección
  ## Parámetro
  ## - ingresar_elemento: función que pide un elemento al usuario
  ## - coleccion_actual: elementos ingresados hasta el momento
  ## Cada elemento se agrega al inicio de la lista y al final se invierte
  ## con Enum.reverse para que quede en el orden en que se ingresó
  defp ingresar_coleccion(ingresar_elemento, coleccion_actual)do
    elemento = ingresar_elemento.()
    nueva_coleccion = [elemento | coleccion_actual]

    case ingresar("\n¿Hay más datos (s/n)? ", :boolean) do
      true ->
        ingresar_coleccion(ingresar_elemento, nueva_coleccion)
        ## Recursividad, sigue pidiendo elementos mientras el usuario responda s
      false ->
        Enum.reverse(nueva_coleccion)
    end
  end

end
