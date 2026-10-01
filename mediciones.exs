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
end

Mediciones.main()
