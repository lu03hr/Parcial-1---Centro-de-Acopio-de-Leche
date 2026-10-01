# Integrantes: Luisa Hernández, Isabella Hincapié, Camila González
# Parámetros del negocio definidos como atributos y valores fijos

defmodule Parametros do
  @moduledoc """
  Módulo que define los parámetros del negocio como atributos de módulo.
  Son valores constantes que se utilizan en los cálculos y reglas del negocio, como tarifas, metas, límites y costos asociados a la producción y entrega de leche.
  """

  @tarifa_base 1800
  @meta_diaria 2000
  @dias 1..6
  @max_litros_entrega 800
  @litros_bonificacion 450
  @bonificacion_diaria 25000
  @costo_transporte 18000
  @grasa_minima 0
  @grasa_maxima 15

  def tarifa_base, do: @tarifa_base
  def meta_diaria, do: @meta_diaria
  def dias, do: @dias
  def max_litros_entrega, do: @max_litros_entrega
  def litros_bonificacion, do: @litros_bonificacion
  def bonificacion_diaria, do: @bonificacion_diaria
  def costo_transporte, do: @costo_transporte
  def grasa_minima, do: @grasa_minima
  def grasa_maxima, do: @grasa_maxima
end
