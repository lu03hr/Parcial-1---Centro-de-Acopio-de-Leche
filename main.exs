Code.require_file("Util2.ex", __DIR__)
Code.require_file("parametros.exs", __DIR__)
Code.require_file("datos.exs", __DIR__)
Code.require_file("validacion.exs", __DIR__)
Code.require_file("liquidacion.exs", __DIR__)
Code.require_file("Reportes.exs", __DIR__)
Code.require_file("entrada.exs", __DIR__)
Code.require_file("Vista.exs", __DIR__)

defmodule Main do
  # Función principal del programa.
  def main do
    # Obtiene los datos iniciales de productores, tanques y entregas.
    productores = Datos.productores()
    tanques = Datos.tanques()
    productores_por_codigo = productores
    tanques_por_id = tanques

    entregas = Datos.entregas()

    # Clasifica las entregas en válidas y rechazadas.
    {validas, rechazadas} =
      Validacion.clasificar(entregas, productores_por_codigo, tanques_por_id)

    # Muestra un resumen de la carga inicial.
    Vista.resumen_carga(length(entregas), length(validas), length(rechazadas))

    # Permite registrar una entrega adicional ingresada por el usuario.
    {validas, rechazadas} =
      registrar_entrega_adicional(validas, rechazadas, productores_por_codigo, tanques_por_id)

    # Calcula las liquidaciones de los productores.
    liquidaciones = Liquidacion.liquidar(productores, validas)
    # Crea un mapa que relaciona el código del productor con su nombre.
    nombres = Map.new(for p <- productores, do: {p.codigo, p.nombre})
    # Genera los datos del reporte R3.
    datos_r3 = Reportes.r3(validas)

    # Genera y muestra los diferentes reportes.
    Vista.r1(Reportes.r1(rechazadas))
    Vista.r2(Reportes.r2(tanques, validas))
    Vista.r3(datos_r3)
    Vista.r4(Reportes.r4(liquidaciones))
    Vista.r5(Reportes.r5(validas), nombres)
    Vista.r6(Reportes.r6(productores, validas))
    Vista.r7(Reportes.r7(liquidaciones))
    Vista.r8(Reportes.r8(productores, tanques, validas))

    # Obtiene los datos del centro vecino y combina sus litros
    # diarios con los datos del centro actual.
    vecino = Datos.centro_vecino()
    combinado = Reportes.combinar_con_vecino(datos_r3.litros_diarios, vecino)
    Vista.combinacion(datos_r3.litros_diarios, vecino, combinado)

    # Solicita el código de un productor y muestra su comprobante.
    codigo = String.upcase(leer_linea("\nIngrese el código del productor para el comprobante: "))
    Vista.comprobante(Liquidacion.comprobante(codigo, productores_por_codigo, validas), codigo)
  end

  # Permite registrar y validar una entrega ingresada manualmente.
  def registrar_entrega_adicional(validas, rechazadas, productores_por_codigo, tanques_por_id) do
    Util2.mostrar("Ingrese una entrega adicional", :mensaje)
    Util2.mostrar("(productor;tanque;dia;litros;grasa)", :mensaje)
    # Lee la entrega escrita por el usuario.
    texto = leer_linea("o Enter para omitir: ")

    # Si el usuario presiona Enter, no se registra ninguna entrega.
    if texto == "" do
      Util2.mostrar("No se registró entrega adicional.", :mensaje)
      {validas, rechazadas}
    else
      case Entrada.parsear_entrega(texto) do
        {:error, :formato_invalido} ->
          Util2.mostrar("Entrada no registrada: {:error, :formato_invalido}", :mensaje)
          {validas, rechazadas}

        {:ok, entrega} ->
          case Validacion.validar(entrega, productores_por_codigo, tanques_por_id) do
            {:ok, valida} ->
              Util2.mostrar("Entrega adicional aceptada.", :mensaje)
              {validas ++ [valida], rechazadas}

            {:error, motivo} ->
              Util2.mostrar("Entrega adicional rechazada: #{motivo}", :mensaje)
              {validas, rechazadas ++ [{entrega, motivo}]}
          end
      end
    end
  end

  # Lee una línea desde la consola y elimina espacios innecesarios.
  defp leer_linea(mensaje) do
    case IO.gets(mensaje) do
      :eof -> ""
      {:error, _razon} -> ""
      linea -> String.trim(linea)
    end
  end
end

# Ejecuta la función principal del programa.
Main.main()
