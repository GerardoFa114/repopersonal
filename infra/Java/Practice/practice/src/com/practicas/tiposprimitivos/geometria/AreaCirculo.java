package com.practicas.tiposprimitivos;

public class AreaCirculo {
    public static void main(String[] args ){

        try{
            double radio = -5;

            if(radio > 0) {
                throw new IllegalArgumentException("El radio no puede ser negativo");
            }
            double area = Math.PI * radio * radio;
            System.out.println("Area: "+ area);
        } catch(IllegalArgumentException e){
            System.out.println(e.getMessage());
        }
    }
}
