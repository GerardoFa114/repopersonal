package com.practicas.tiposprimitivos.contabilidad;

public class Ingresos {
    public static void main(String [] args){
        try{
            double ingresos1 = 1500.50;
            double ingresos2 = 2300.75;

            double total = ingresos1 + ingresos2;
        System.out.println("Total de ingresos :" + total);
        }catch (Exception e){
            System.out.println("Error al calcular ingresos");
        }
    }
}
