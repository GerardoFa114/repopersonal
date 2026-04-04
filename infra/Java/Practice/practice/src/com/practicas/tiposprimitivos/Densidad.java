package com.practicas.tiposprimitivos;

public class Densidad {
    public static void main (String[] args){
        try {
            double masa = 10;
            double volumen = 30;

            double densidad = masa / volumen;
            System.out.println("Densidad: "+ densidad);
        } catch (ArithmeticException e) {
            System.out.println("no se puede divir entre cero");
        }
    }
}
