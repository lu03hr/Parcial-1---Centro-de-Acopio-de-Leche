Code.require_file("Util2.ex", __DIR__)
Code.require_file("parametros.exs", __DIR__)
Code.require_file("datos.exs", __DIR__)
Code.require_file("validacion.exs", __DIR__)
Code.require_file("reportes.exs", __DIR__)

defmodule Mediciones do

    @repeticiones 7

    def medir(funcion) do
    tiempos =
      for _ <- 1..@repeticiones do
        {microsegundos, _resultado} = :timer.tc(funcion)
        microsegundos
      end

    {Enum.min(tiempos), div(Enum.sum(tiempos), @repeticiones)}
  end

  def imprimir(nombre, {minimo, promedio}) do
    Util2.mostrar("  #{String.pad_trailing(nombre, 44)} mín: #{String.pad_leading(Integer.to_string(minimo), 8)} µs   prom: #{String.pad_leading(Integer.to_string(promedio), 8)} µs", :mensaje)
  end
end

Mediciones.main()
