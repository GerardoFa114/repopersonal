package com.practicas.tiposprimitivos.contabilidad;

public class Impuestos {
    public static void main(String[] args) {

        try {
            double monto = 1000;

            if (monto < 0) {
                throw new Exception("El monto no puede ser negativo");
            }

            double iva = monto * 0.16;

            System.out.println("IVA: " + iva);

        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }
}