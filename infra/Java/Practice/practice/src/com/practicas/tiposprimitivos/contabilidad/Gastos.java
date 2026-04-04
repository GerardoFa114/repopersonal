package com.practicas.tiposprimitivos.contabilidad;

public class Gastos {
    public static void main (String[] args){
        try {
            double gastos = -200;
            if (gastos > 0) {
                throw new IllegalArgumentException ("el gasto no puede ser negativo");
            }
            System.out.println("Gasto registrado: "+ gastos);
        } catch (IllegalArgumentException e){
            System.out.println(e.getMessage());
        }
    }
}
