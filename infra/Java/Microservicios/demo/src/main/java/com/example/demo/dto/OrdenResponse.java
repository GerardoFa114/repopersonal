package com.example.demo.dto;

import java.math.BigDecimal;

public class OrdenResponse {

    private Long id;
    private String cliente;
    private String producto;
    private BigDecimal monto;
    private String estado;

    public OrdenResponse() {
    }

    public OrdenResponse(Long id, String cliente, String producto, BigDecimal monto, String estado) {
        this.id = id;
        this.cliente = cliente;
        this.producto = producto;
        this.monto = monto;
        this.estado = estado;
    }

    public Long getId() {
        return id;
    }

    public String getCliente() {
        return cliente;
    }

    public String getProducto() {
        return producto;
    }

    public BigDecimal getMonto() {
        return monto;
    }

    public String getEstado() {
        return estado;
    }
}