package com.practicas.tiposprimitivos.contabilidad;

public class Utilidad {
    public static void main(String[] args){
        try{
            double ingresos = 5000;
            double gastos   = 3200;

            double utilidad = ingresos - gastos;
            System.out.println("utilidad: "+ utilidad);
        }catch(Exception e){
            System.out.println("Error en el calculo");
        }
    }
}
